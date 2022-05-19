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

    // Outputs
    output logic [15:0] rd_p1,
    output logic        alu_output_valid,
    output logic [15:0] pc_nxt_p1
);

logic [15:0]    add1, add2;
logic [15:0]    add_out;
logic           carry;
logic           adder_in_use;
logic [3:0]     shift_rotate_val;
logic [15:0]    shift_rotate_out;
logic [15:0]    logical_out;

logic [15:0]    eq1, eq2;
logic           eq_out;

// Adder input calculation
assign add1 =   (opcode_idix_p1[1:0] & {2{uop_cnt_idix_p1[18]}}) == 2'b00 ? rs_p1                   :   // ADDI
                (opcode_idix_p1[1:0] & {2{uop_cnt_idix_p1[18]}}) == 2'b01 ? uop_cnt_idix_p1[17:2]   :   // SUBI
                (branch_idix_p1)                                          ? pc_p1 + 16'd2           :   // BEQZ, BNEZ, BLTZ, BGEZ
                (ldst_valid_idix_p1)                                      ? rs_p1                   :   // LD ST
                (opcode_idix_p1[1:0] & {2{uop_cnt_idix_p1[23]}}) == 2'b00 ? rs_p1                   :   // ADD
                (opcode_idix_p1[1:0] & {2{uop_cnt_idix_p1[23]}}) == 2'b01 ? rt_p1                   :   // SUB
                (uop_cnt_idix_p1[25])                                     ? rs_p1                   :   // SCO
                                                                            16'b0;                      // Default

assign add2 =   (opcode_idix_p1[1:0] & {2{uop_cnt_idix_p1[18]}}) == 2'b00 ? uop_cnt_idix_p1[17:2]   :   // ADDI
                (opcode_idix_p1[1:0] & {2{uop_cnt_idix_p1[18]}}) == 2'b01 ? ~rs_p1 + 16'b1          :   // SUBI
                (branch_idix_p1)                                          ? uop_cnt_idix_p1[17:2]   :   // BEQZ, BNEZ, BLTZ, BGEZ
                (ldst_valid_idix_p1)                                      ? uop_cnt_idix_p1[17:2]   :   // LD ST
                (opcode_idix_p1[1:0] & {2{uop_cnt_idix_p1[23]}}) == 2'b00 ? rt_p1                   :   // ADD
                (opcode_idix_p1[1:0] & {2{uop_cnt_idix_p1[23]}}) == 2'b01 ? ~rs_p1 + 16'b1          :   // SUB
                (uop_cnt_idix_p1[25])                                     ? rt_p1                   :   // SCO
                                                                            16'b0;                      // Default

// The actual addition
assign {carry, add_out} = add1 + add2;

// Value to shift/rotate by 
assign shift_rotate_val = uop_cnt_idix_p1[20] ? uop_cnt_idix_p1[5:2] : rt_p1[3:0];

// Barrel shifter, rotate
barrel_shift_rotate bsr (.clk(clk), .A(rs_p1), .amt(shift_rotate_val), .rotate(uop_cnt_idix_p1[20] | uop_cnt_idix_p1[24]), .right(rotate_shift_right_idix_p1), .result(shift_rotate_out));

always_comb begin : logical_ops
    if (execute_valid_idix_p1) begin
        logical_out = uop_cnt_idix_p1[18] & opcode_idix_p1[1] & ~opcode_idix_p1[0] ? rs_p1 ^ uop_cnt_idix_p1[17:2]  :   // XORI
                      uop_cnt_idix_p1[18] & opcode_idix_p1[1] &  opcode_idix_p1[0] ? rs_p1 & ~uop_cnt_idix_p1[17:2] :   // ANDI
                      uop_cnt_idix_p1[23] & inst_idix_p1[1] & ~inst_idix_p1[0]     ? rs_p1 ^ rt_p1                  :   // XOR
                      uop_cnt_idix_p1[23] & inst_idix_p1[1] &  inst_idix_p1[0]     ? rs_p1 & ~rt_p1                 :   'b0; // ANDN
                      
    end else
        logical_out = 16'b0;
end

// Equivalence checks
// SEQ, SLT, SLE, BEQZ, BNEZ, BLTZ, BGEZ
assign eq1 = rs_p1;
assign eq2 = branch_idix_p1 ? 'b0 : rt_p1;

assign eq_out = uop_cnt_idix_p1[25] ? (opcode_idix_p1[1:0] == 2'b00 ? eq1 == eq2 :              // SEQ
                                       opcode_idix_p1[1:0] == 2'b01 ? eq1 < eq2  :              // SLT
                                       opcode_idix_p1[1:0] == 2'b10 ? eq1 <= eq2 : carry) :     // SLE, SCO
                branch_idix_p1      ? (opcode_idix_p1[1:0] == 2'b00 ? eq1 == eq2 :              // BEQZ
                                       opcode_idix_p1[1:0] == 2'b01 ? eq1 != eq2 :              // BNEZ
                                       opcode_idix_p1[1:0] == 2'b10 ? eq1 < eq2  : eq1 >= eq2) : 1'b0;  // BLTZ, BGEZ

// Branch check passed
assign pc_nxt_p1 = branch_idix_p1 & eq_out ? add_out : 'b0;

endmodule