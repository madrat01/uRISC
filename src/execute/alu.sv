module alu (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic [15:0]  rs_p1,
    input logic [15:0]  rt_p1,
    input logic [15:0]  inst_idix_p1,
    input logic [4:0]   opcode_idix_p1,
    input logic [25:0]  uop_cnt_idix_p1,
    input logic         execute_valid_idix_p1,
    input logic         ldst_valid_idix_p1,
    input logic         jmp_idix_p1,
    input logic         branch_idix_p1,
    input logic [15:0]  pc_p1,
    input logic         rotate_shift_right_idix_p1,
    input logic [2:0]   dest_reg_idix_p1,
    input logic         reg_write_valid_idix_p1,
    input logic         jmp_displacement_idix_p1,
    input logic [15:0]  nxt_pc_p1,

    // Outputs
    output logic [15:0] alu_output_data,
    output logic [15:0] pc_nxt_p1
);

logic [15:0]        SExt15;
logic [15:0]        add1, add2;
logic [15:0]        add_out;
logic               carry;
logic               adder_in_use;
logic [3:0]         shift_rotate_val;
logic [15:0]        shift_rotate_out;
logic [15:0]        logical_out;
logic signed [15:0] eq1, eq2;
logic               eq_out;
logic               rotate;
logic               eq_out_valid;
logic               logical_out_valid;
logic               add_out_valid;
logic               shift_rotate_out_valid;
logic               btr_out_valid;

assign SExt15 = uop_cnt_idix_p1[17:2]; 

// Adder input calculation
assign add1 =   (opcode_idix_p1[1:0] == 2'b00 & uop_cnt_idix_p1[18])      ? rs_p1                   :   // ADDI
                (opcode_idix_p1[1:0] == 2'b01 & uop_cnt_idix_p1[18])      ? uop_cnt_idix_p1[17:2]   :   // SUBI
                (branch_idix_p1 | jmp_displacement_idix_p1)               ? nxt_pc_p1               :   // BEQZ, BNEZ, BLTZ, BGEZ, J, JAL
                (ldst_valid_idix_p1)                                      ? rs_p1                   :   // LD ST
                (inst_idix_p1[1:0] == 2'b00 & uop_cnt_idix_p1[23])        ? rs_p1                   :   // ADD
                (inst_idix_p1[1:0] == 2'b01 & uop_cnt_idix_p1[23])        ? rt_p1                   :   // SUB
                (uop_cnt_idix_p1[25])                                     ? rs_p1                   :   // SCO
                (opcode_idix_p1[0] & jmp_idix_p1)                         ? rs_p1                   :   // JR, JALR
                                                                            16'b0;                      // Default

assign add2 =   (opcode_idix_p1[1:0] == 2'b00 & uop_cnt_idix_p1[18])      ? uop_cnt_idix_p1[17:2]   :   // ADDI
                (opcode_idix_p1[1:0] == 2'b01 & uop_cnt_idix_p1[18])      ? ~rs_p1 + 16'b1          :   // SUBI
                (branch_idix_p1 | jmp_displacement_idix_p1)               ? uop_cnt_idix_p1[17:2]   :   // BEQZ, BNEZ, BLTZ, BGEZ, J, JAL
                (ldst_valid_idix_p1)                                      ? uop_cnt_idix_p1[17:2]   :   // LD ST
                (inst_idix_p1[1:0] == 2'b00 & uop_cnt_idix_p1[23])        ? rt_p1                   :   // ADD
                (inst_idix_p1[1:0] == 2'b01 & uop_cnt_idix_p1[23])        ? ~rs_p1 + 16'b1          :   // SUB
                (uop_cnt_idix_p1[25])                                     ? rt_p1                   :   // SCO
                (opcode_idix_p1[0] & jmp_idix_p1)                         ? uop_cnt_idix_p1[17:2]   :   // JR, JALR
                                                                            16'b0;                      // Default

// The actual addition
assign {carry, add_out} = add1 + add2;

// Rotate or shift
assign rotate = uop_cnt_idix_p1[20] & ~opcode_idix_p1[0] | uop_cnt_idix_p1[24] & ~inst_idix_p1[0];

// Value to shift/rotate by 
assign shift_rotate_val = uop_cnt_idix_p1[20] ? uop_cnt_idix_p1[5:2] : rt_p1[3:0];

// Barrel shifter, rotate
barrel_shift_rotate bsr (.clk(clk), .A(rs_p1), .amt(shift_rotate_val), .rotate(rotate), .right(rotate_shift_right_idix_p1), .result(shift_rotate_out));

always_comb begin : logical_ops
    if (execute_valid_idix_p1) begin
        logical_out = uop_cnt_idix_p1[18] & opcode_idix_p1[1] & ~opcode_idix_p1[0] ? rs_p1 ^ uop_cnt_idix_p1[17:2]  :   // XORI
                      uop_cnt_idix_p1[18] & opcode_idix_p1[1] &  opcode_idix_p1[0] ? rs_p1 & ~uop_cnt_idix_p1[17:2] :   // ANDI
                      uop_cnt_idix_p1[23] & inst_idix_p1[1] & ~inst_idix_p1[0]     ? rs_p1 ^ rt_p1                  :   // XOR
                      uop_cnt_idix_p1[23] & inst_idix_p1[1] &  inst_idix_p1[0]     ? rs_p1 & ~rt_p1                 :   // ANDN
                      uop_cnt_idix_p1[21]                                          ? uop_cnt_idix_p1[17:2]          :   // LBI
                      uop_cnt_idix_p1[19]                                          ? (rs_p1 << 8) | uop_cnt_idix_p1[17:2] :  16'b0; // SLBI
    end else
        logical_out = 16'b0;
end

// Compare checks
// SEQ, SLT, SLE, BEQZ, BNEZ, BLTZ, BGEZ
assign eq1 = $signed(rs_p1);
assign eq2 = $signed(rt_p1);

assign eq_out = uop_cnt_idix_p1[25] ? (opcode_idix_p1[1:0] == 2'b00 ? eq1 == eq2 :              // SEQ
                                       opcode_idix_p1[1:0] == 2'b01 ? eq1 < eq2  :              // SLT
                                       opcode_idix_p1[1:0] == 2'b10 ? eq1 <= eq2 : carry) :     // SLE, SCO
                branch_idix_p1      ? (opcode_idix_p1[1:0] == 2'b00 ? ~|eq1      :              // BEQZ // TODO Right?
                                       opcode_idix_p1[1:0] == 2'b01 ? |eq1       :              // BNEZ
                                       opcode_idix_p1[1:0] == 2'b10 ? eq1[15]    : ~eq1[15]) : 1'b0;  // BLTZ, BGEZ

// Branch and jump target
assign pc_nxt_p1 = add_out;

assign eq_out_valid = uop_cnt_idix_p1[25] | branch_idix_p1;
assign logical_out_valid = (uop_cnt_idix_p1[18] & opcode_idix_p1[1])   |   
                           (uop_cnt_idix_p1[23] & inst_idix_p1[1])     |   
                           uop_cnt_idix_p1[21]                         |    
                           uop_cnt_idix_p1[19]                         ;
assign add_out_valid = (uop_cnt_idix_p1[18] & ~opcode_idix_p1[1])  |   
                       (branch_idix_p1 | jmp_displacement_idix_p1) |   
                       (uop_cnt_idix_p1[23] & ~inst_idix_p1[1])    | 
                       (uop_cnt_idix_p1[25])                       |
                       (ldst_valid_idix_p1)                        |   
                       (opcode_idix_p1[0] & jmp_idix_p1)           ;
assign shift_rotate_out_valid = uop_cnt_idix_p1[20] | uop_cnt_idix_p1[24]; 
assign btr_out_valid = uop_cnt_idix_p1[22];

assign alu_output_data =    eq_out_valid            ? {15'b0, eq_out}  :        // SEQ, SLT, SLE, BEQZ, BNEZ, BLTZ, BGEZ
                            logical_out_valid       ? logical_out      :        // Logical ops used
                            add_out_valid           ? add_out          :        // Adder used
                            btr_out_valid           ? {rs_p1[0], rs_p1[1], rs_p1[2], rs_p1[3], rs_p1[4], rs_p1[5], rs_p1[6], rs_p1[7], rs_p1[8], rs_p1[9], rs_p1[10], rs_p1[11], rs_p1[12], rs_p1[13], rs_p1[14], rs_p1[15]} : // BTR
                            shift_rotate_out_valid  ? shift_rotate_out : 16'b0; // Shift/Rotate          
                                                                                      
endmodule