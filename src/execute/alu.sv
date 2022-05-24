module alu (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic [15:0]  rs_p3,
    input logic [15:0]  rt_p3,
    input logic [15:0]  inst_idix_p3,
    input logic [4:0]   opcode_idix_p3,
    input logic [25:0]  uop_cnt_idix_p3,
    input logic         execute_valid_idix_p3,
    input logic         ldst_valid_idix_p3,
    input logic         jmp_idix_p3,
    input logic         branch_idix_p3,
    input logic [15:0]  pc_p3,
    input logic         rotate_shift_right_idix_p3,
    input logic [2:0]   dest_reg_idix_p3,
    input logic         reg_write_valid_idix_p3,
    input logic         jmp_displacement_idix_p3,
    input logic [15:0]  nxt_pc_p3,

    // Outputs
    output logic [15:0] alu_output_data,
    output logic [15:0] pc_nxt_p3
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

assign SExt15 = uop_cnt_idix_p3[17:2]; 

// Adder input calculation
assign add1 =   (opcode_idix_p3[1:0] == 2'b00 & uop_cnt_idix_p3[18])      ? rs_p3                   :   // ADDI
                (opcode_idix_p3[1:0] == 2'b01 & uop_cnt_idix_p3[18])      ? uop_cnt_idix_p3[17:2]   :   // SUBI
                (branch_idix_p3 | jmp_displacement_idix_p3)               ? nxt_pc_p3               :   // BEQZ, BNEZ, BLTZ, BGEZ, J, JAL
                (ldst_valid_idix_p3)                                      ? rs_p3                   :   // LD ST
                (inst_idix_p3[1:0] == 2'b00 & uop_cnt_idix_p3[23])        ? rs_p3                   :   // ADD
                (inst_idix_p3[1:0] == 2'b01 & uop_cnt_idix_p3[23])        ? rt_p3                   :   // SUB
                (uop_cnt_idix_p3[25])                                     ? rs_p3                   :   // SCO
                (opcode_idix_p3[0] & jmp_idix_p3)                         ? rs_p3                   :   // JR, JALR
                                                                            16'b0;                      // Default

assign add2 =   (opcode_idix_p3[1:0] == 2'b00 & uop_cnt_idix_p3[18])      ? uop_cnt_idix_p3[17:2]   :   // ADDI
                (opcode_idix_p3[1:0] == 2'b01 & uop_cnt_idix_p3[18])      ? ~rs_p3 + 16'b1          :   // SUBI
                (branch_idix_p3 | jmp_displacement_idix_p3)               ? uop_cnt_idix_p3[17:2]   :   // BEQZ, BNEZ, BLTZ, BGEZ, J, JAL
                (ldst_valid_idix_p3)                                      ? uop_cnt_idix_p3[17:2]   :   // LD ST
                (inst_idix_p3[1:0] == 2'b00 & uop_cnt_idix_p3[23])        ? rt_p3                   :   // ADD
                (inst_idix_p3[1:0] == 2'b01 & uop_cnt_idix_p3[23])        ? ~rs_p3 + 16'b1          :   // SUB
                (uop_cnt_idix_p3[25])                                     ? rt_p3                   :   // SCO
                (opcode_idix_p3[0] & jmp_idix_p3)                         ? uop_cnt_idix_p3[17:2]   :   // JR, JALR
                                                                            16'b0;                      // Default

// The actual addition
assign {carry, add_out} = add1 + add2;

// Rotate or shift
assign rotate = uop_cnt_idix_p3[20] & ~opcode_idix_p3[0] | uop_cnt_idix_p3[24] & ~inst_idix_p3[0];

// Value to shift/rotate by 
assign shift_rotate_val = uop_cnt_idix_p3[20] ? uop_cnt_idix_p3[5:2] : rt_p3[3:0];

// Barrel shifter, rotate
barrel_shift_rotate bsr (.clk(clk), .A(rs_p3), .amt(shift_rotate_val), .rotate(rotate), .right(rotate_shift_right_idix_p3), .result(shift_rotate_out));

always_comb begin : logical_ops
    if (execute_valid_idix_p3) begin
        logical_out = uop_cnt_idix_p3[18] & opcode_idix_p3[1] & ~opcode_idix_p3[0] ? rs_p3 ^ uop_cnt_idix_p3[17:2]  :   // XORI
                      uop_cnt_idix_p3[18] & opcode_idix_p3[1] &  opcode_idix_p3[0] ? rs_p3 & ~uop_cnt_idix_p3[17:2] :   // ANDI
                      uop_cnt_idix_p3[23] & inst_idix_p3[1] & ~inst_idix_p3[0]     ? rs_p3 ^ rt_p3                  :   // XOR
                      uop_cnt_idix_p3[23] & inst_idix_p3[1] &  inst_idix_p3[0]     ? rs_p3 & ~rt_p3                 :   // ANDN
                      uop_cnt_idix_p3[21]                                          ? uop_cnt_idix_p3[17:2]          :   // LBI
                      uop_cnt_idix_p3[19]                                          ? (rs_p3 << 8) | uop_cnt_idix_p3[17:2] :  16'b0; // SLBI
    end else
        logical_out = 16'b0;
end

// Compare checks
// SEQ, SLT, SLE, BEQZ, BNEZ, BLTZ, BGEZ
assign eq1 = $signed(rs_p3);
assign eq2 = $signed(rt_p3);

assign eq_out = uop_cnt_idix_p3[25] ? (opcode_idix_p3[1:0] == 2'b00 ? eq1 == eq2 :              // SEQ
                                       opcode_idix_p3[1:0] == 2'b01 ? eq1 < eq2  :              // SLT
                                       opcode_idix_p3[1:0] == 2'b10 ? eq1 <= eq2 : carry) :     // SLE, SCO
                branch_idix_p3      ? (opcode_idix_p3[1:0] == 2'b00 ? ~|eq1      :              // BEQZ // TODO Right?
                                       opcode_idix_p3[1:0] == 2'b01 ? |eq1       :              // BNEZ
                                       opcode_idix_p3[1:0] == 2'b10 ? eq1[15]    : ~eq1[15]) : 1'b0;  // BLTZ, BGEZ

// Branch and jump target
assign pc_nxt_p3 = add_out;

assign eq_out_valid = uop_cnt_idix_p3[25] | branch_idix_p3;
assign logical_out_valid = (uop_cnt_idix_p3[18] & opcode_idix_p3[1])   |   
                           (uop_cnt_idix_p3[23] & inst_idix_p3[1])     |   
                           uop_cnt_idix_p3[21]                         |    
                           uop_cnt_idix_p3[19]                         ;
assign add_out_valid = (uop_cnt_idix_p3[18] & ~opcode_idix_p3[1])  |   
                       (branch_idix_p3 | jmp_displacement_idix_p3) |   
                       (uop_cnt_idix_p3[23] & ~inst_idix_p3[1])    | 
                       (uop_cnt_idix_p3[25])                       |
                       (ldst_valid_idix_p3)                        |   
                       (opcode_idix_p3[0] & jmp_idix_p3)           ;
assign shift_rotate_out_valid = uop_cnt_idix_p3[20] | uop_cnt_idix_p3[24]; 
assign btr_out_valid = uop_cnt_idix_p3[22];

assign alu_output_data =    eq_out_valid            ? {15'b0, eq_out}  :        // SEQ, SLT, SLE, BEQZ, BNEZ, BLTZ, BGEZ
                            logical_out_valid       ? logical_out      :        // Logical ops used
                            add_out_valid           ? add_out          :        // Adder used
                            btr_out_valid           ? {rs_p3[0], rs_p3[1], rs_p3[2], rs_p3[3], rs_p3[4], rs_p3[5], rs_p3[6], rs_p3[7], rs_p3[8], rs_p3[9], rs_p3[10], rs_p3[11], rs_p3[12], rs_p3[13], rs_p3[14], rs_p3[15]} : // BTR
                            shift_rotate_out_valid  ? shift_rotate_out : 16'b0; // Shift/Rotate          
                                                                                      
endmodule