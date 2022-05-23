module decode 
    import defines_pkg::*;    
(
    // Inputs
    input logic             clk,
    input logic             rst,
    input logic [15:0]      pc_p1,
    input logic [15:0]      inst_ifid_p1,
    input logic [15:0]      epc_p1,

    // Outputs
    output logic [15:0]     inst_idix_p1,
    output logic [2:0]      rd_idix_p1,
    output logic [2:0]      rs_idix_p1,
    output logic [2:0]      rt_idix_p1,
    output logic            ldst_valid_idix_p1,
    output logic            halt_idif_p1,
    output logic            nop_idif_p1,
    output logic            illegal_op_idif_p1,
    output logic            return_execution_idif_p1,
    output logic            jmp_idix_p1,
    output logic            branch_idix_p1,
    output logic            jmp_displacement_idif_p1,
    output logic            jmp_displacement_idix_p1,
    output logic [15:0]     jmp_displacement_value_idif_p1,
    output logic [4:0]      opcode_idix_p1,
    output logic            execute_valid_idix_p1,
    output logic [25:0]     uop_cnt_idix_p1,
    output logic            rotate_shift_right_idix_p1,
    output logic [2:0]      dest_reg_idix_p1,
    output logic            reg_write_valid_idix_p1,
    output logic [1:0]      store_valid_idix_p1, // 0-Store, 1-Store with update
    output inst_t           curr_inst_idix_p1
);

logic imm5_valid_idix_p1;

assign inst_idix_p1 = inst_ifid_p1;

// Source register
// Rs always 10:8
assign rs_idix_p1 = inst_ifid_p1[10:8];

// 2nd Source register
// Rt always 7:5
assign rt_idix_p1 = inst_ifid_p1[7:5];

// Jump displacement
// 00100 ddddddddddd    J displacement      PC <- PC + 2 + D(sign ext.) 
// 00110 ddddddddddd    JAL displacement    R7 <- PC + 2 PC <- PC + 2 + D(sign ext.)
assign jmp_displacement_value_idif_p1 = {{5{inst_ifid_p1[10]}}, inst_ifid_p1[10:0]};

// Opcode is the 5-bits of MSB
assign opcode_idix_p1 = inst_ifid_p1[15:11];

// uop control
// 0    -   uop valid
// 1    -   jal
// 2:17 -   16-bit sign extended or unsign extended immediate
// 18   -   immediate execute
// 19   -   SLBI
// 20   -   rotate/shift immediate
// 21   -   LBI
// 22   -   BTR
// 23   -   non immediate execute
// 24   -   rotate/shift non immediate
// 25   -   equivalence checks 
assign uop_cnt_idix_p1[0] = ~(halt_idif_p1 | nop_idif_p1 | illegal_op_idif_p1);
assign uop_cnt_idix_p1[17:2] =  (uop_cnt_idix_p1[19])                       ? {8'b0, inst_ifid_p1[7:0]}                     : 
                                (uop_cnt_idix_p1[18] & opcode_idix_p1[1])   ? {11'b0, inst_ifid_p1[4:0]}                    :
                                (jmp_displacement_idif_p1)                  ? {{5{inst_ifid_p1[10]}}, inst_ifid_p1[10:0]}   :
                                (imm5_valid_idix_p1)                        ? {{11{inst_ifid_p1[4]}}, inst_ifid_p1[4:0]}    :
                                                                              {{8{inst_ifid_p1[7]}}, inst_ifid_p1[7:0]}     ; 

always_comb begin : decode_inst

    jmp_displacement_idif_p1 = 1'b0;
    jmp_displacement_idix_p1 = 1'b0;
    branch_idix_p1 = 1'b0;
    execute_valid_idix_p1 = 1'b0;
    imm5_valid_idix_p1 = 1'b0;
    ldst_valid_idix_p1 = 1'b0;
    illegal_op_idif_p1 = 1'b0;
    nop_idif_p1 = 1'b0;
    halt_idif_p1 = 1'b0;
    return_execution_idif_p1 = 1'b0;
    rd_idix_p1 = 3'b0;
    uop_cnt_idix_p1[1] = 1'b0;
    uop_cnt_idix_p1[25:18] = 'b0;
    rotate_shift_right_idix_p1 = 1'b0;
    reg_write_valid_idix_p1 = 1'b0;
    store_valid_idix_p1 = 2'b0;
    jmp_idix_p1 = 1'b0;
    curr_inst_idix_p1 = inst_t'({opcode_idix_p1, 2'b00});

    case (opcode_idix_p1) inside
        // Halt execution
        5'b00000 :  halt_idif_p1 = 1'b1;
        // NOP
        5'b00001 :  nop_idif_p1 = 1'b1;
        // produce IllegalOp exception. Must provide one source register.
        5'b00010 :  illegal_op_idif_p1 = 1'b1;
        // Return from exception PC <- EPC
        5'b00011 :  return_execution_idif_p1 = 1'b1;
        // Jump instructions
        // 00100 ddddddddddd    J displacement      PC <- PC + 2 + D(sign ext.) 
        // 00101 sss iiiiiiii   JR Rs, immediate    PC <- Rs + I(sign ext.)
        // 00110 ddddddddddd    JAL displacement    R7 <- PC + 2 PC <- PC + 2 + D(sign ext.)
        // 00111 sss iiiiiiii   JALR Rs, immediate  R7 <- PC + 2 PC <- Rs + I(sign ext.)
        5'b001xx :  begin 
                        jmp_displacement_idif_p1 = ~opcode_idix_p1[0]; 
                        jmp_displacement_idix_p1 = ~opcode_idix_p1[0]; 
                        jmp_idix_p1 = |opcode_idix_p1[1:0];
                        uop_cnt_idix_p1[1] = opcode_idix_p1[1];
                        reg_write_valid_idix_p1 = uop_cnt_idix_p1[1]; 
                    end
        // Immediate execute
        // 01000 sss ddd iiiii ADDI Rd, Rs, immediate Rd <- Rs + I(sign ext.)
        // 01001 sss ddd iiiii SUBI Rd, Rs, immediate Rd <- I(sign ext.) - Rs
        // 01010 sss ddd iiiii XORI Rd, Rs, immediate Rd <- Rs XOR I(zero ext.)
        // 01011 sss ddd iiiii ANDNI Rd, Rs, immediate Rd <- Rs AND ~I(zero ext.)
        5'b010xx :  begin 
                        execute_valid_idix_p1 = 1'b1; 
                        imm5_valid_idix_p1 = 1'b1; 
                        rd_idix_p1 = inst_ifid_p1[7:5];
                        uop_cnt_idix_p1[18] = 1'b1;
                        reg_write_valid_idix_p1 = 1'b1; 
                    end
        // Branch instructions
        // 01100 sss iiiiiiii BEQZ Rs, immediate if (Rs == 0) then PC <- PC + 2 + I(sign ext.)
        // 01101 sss iiiiiiii BNEZ Rs, immediate if (Rs != 0) then PC <- PC + 2 + I(sign ext.)
        // 01110 sss iiiiiiii BLTZ Rs, immediate if (Rs < 0) then PC <- PC + 2 + I(sign ext.)
        // 01111 sss iiiiiiii BGEZ Rs, immediate if (Rs >= 0) then PC <- PC + 2 + I(sign ext.)`
        5'b011xx :  begin
                        branch_idix_p1 = 1'b1; 
                    end
        // Memory instructions
        // 10000 sss ddd iiiii ST Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd
        // 10001 sss ddd iiiii LD Rd, Rs, immediate Rd <- Mem[Rs + I(sign ext.)]
        // 10011 sss ddd iiiii STU Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd Rs <- Rs + I(sign ext.)
        
        // Shift and load byte
        // 10010 sss iiiiiiii SLBI Rs, immediate Rs <- (Rs << 8) | I(zero ext.)
        5'b100xx :  begin 
                        execute_valid_idix_p1 = opcode_idix_p1[2:0] == 2'b10;
                        uop_cnt_idix_p1[19] = opcode_idix_p1[2:0] == 2'b10; 
                        ldst_valid_idix_p1 = ~uop_cnt_idix_p1[19];
                        imm5_valid_idix_p1 = ~uop_cnt_idix_p1[19];
                        rd_idix_p1 = inst_ifid_p1[7:5];
                        store_valid_idix_p1[0] = ~|opcode_idix_p1[1:0];
                        store_valid_idix_p1[1] = &opcode_idix_p1[1:0];
                        reg_write_valid_idix_p1 = |opcode_idix_p1[1:0];
                    end
        // Rotate execute
        // 10100 sss ddd iiiii ROLI Rd, Rs, immediate Rd <- Rs <<(rotate) I(lowest 4 bits)
        // 10101 sss ddd iiiii SLLI Rd, Rs, immediate Rd <- Rs << I(lowest 4 bits)
        // 10110 sss ddd iiiii RORI Rd, Rs, immediate Rd <- Rs >>(rotate) I(lowest 4 bits)
        // 10111 sss ddd iiiii SRLI Rd, Rs, immediate Rd <- Rs >> I(lowest 4 bits)
        5'b101xx :  begin 
                        execute_valid_idix_p1 = 1'b1; 
                        imm5_valid_idix_p1 = 1'b1; 
                        rd_idix_p1 = inst_ifid_p1[7:5];
                        uop_cnt_idix_p1[20] = 1'b1;
                        rotate_shift_right_idix_p1 = opcode_idix_p1[1];
                        reg_write_valid_idix_p1 = 1'b1;
                    end
        // Load Byte immediate 
        // 11000 sss iiiiiiii LBI Rs, immediate Rs <- I(sign ext.)
        5'b11000 :  begin 
                        execute_valid_idix_p1 = 1'b1;
                        uop_cnt_idix_p1[21] = 1'b1;
                        reg_write_valid_idix_p1 = 1'b1;
                    end
        // BTR
        // 11001 sss xxx ddd xx BTR Rd, Rs Rd[bit i] <- Rs[bit 15-i] for i=0..15
        5'b11001 :  begin 
                        execute_valid_idix_p1 = 1'b1; 
                        rd_idix_p1 = inst_ifid_p1[4:2];
                        uop_cnt_idix_p1[22] = 1'b1;
                        reg_write_valid_idix_p1 = 1'b1;
                    end
        // Execute and rotate
        // 11011 sss ttt ddd 00 ADD Rd, Rs, Rt Rd <- Rs + Rt
        // 11011 sss ttt ddd 01 SUB Rd, Rs, Rt Rd <- Rt - Rs
        // 11011 sss ttt ddd 10 XOR Rd, Rs, Rt Rd <- Rs XOR Rt
        // 11011 sss ttt ddd 11 ANDN Rd, Rs, Rt Rd <- Rs AND ~Rt
        // 11010 sss ttt ddd 00 ROL Rd, Rs, Rt Rd <- Rs << (rotate) Rt (lowest 4 bits)
        // 11010 sss ttt ddd 01 SLL Rd, Rs, Rt Rd <- Rs << Rt (lowest 4 bits)
        // 11010 sss ttt ddd 10 ROR Rd, Rs, Rt Rd <- Rs >> (rotate) Rt (lowest 4 bits)
        // 11010 sss ttt ddd 11 SRL Rd, Rs, Rt Rd <- Rs >> Rt (lowest 4 bits)
        5'b1101x :  begin 
                        execute_valid_idix_p1 = 1'b1; 
                        rd_idix_p1 = inst_ifid_p1[4:2];
                        uop_cnt_idix_p1[23] = opcode_idix_p1[0];
                        uop_cnt_idix_p1[24] = ~opcode_idix_p1[0];
                        rotate_shift_right_idix_p1 = uop_cnt_idix_p1[24] & inst_ifid_p1[1];
                        reg_write_valid_idix_p1 = 1'b1;
                        curr_inst_idix_p1 = inst_t'({opcode_idix_p1, inst_idix_p1[1:0]});
                    end
        // Equalence checks
        // 11100 sss ttt ddd xx SEQ Rd, Rs, Rt if (Rs == Rt) then Rd <- 1 else Rd <- 0
        // 11101 sss ttt ddd xx SLT Rd, Rs, Rt if (Rs < Rt) then Rd <- 1 else Rd <- 0
        // 11110 sss ttt ddd xx SLE Rd, Rs, Rt if (Rs <= Rt) then Rd <- 1 else Rd <- 0
        // 11111 sss ttt ddd xx SCO Rd, Rs, Rt if (Rs + Rt) generates carry out then Rd <- 1 else Rd <- 0
        5'b111xx :  begin 
                        execute_valid_idix_p1 = 1'b1; 
                        rd_idix_p1 = inst_ifid_p1[4:2];
                        uop_cnt_idix_p1[25] = 1'b1;
                        reg_write_valid_idix_p1 = 1'b1; 
                    end
        default  :  nop_idif_p1 = 1'b1;
    endcase

end : decode_inst

assign dest_reg_idix_p1 = uop_cnt_idix_p1[1]                                       ? 3'b111     : //JL, JAL
                          opcode_idix_p1 == 5'b10011 || opcode_idix_p1 == 5'b11000 || opcode_idix_p1 == 5'b10010 ? rs_idix_p1 : rd_idix_p1; // STU LBI SLBI

endmodule