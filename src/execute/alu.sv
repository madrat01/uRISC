module alu (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic [15:0]  rs_p1,
    input logic [15:0]  rt_p1,
    input logic [4:0]   opcode_idix_p1,
    input logic         uop_cnt_idix_p1,
    input logic         execute_valid_idix_p1,
    input logic         ldst_valid_idix_p1,
    input logic         jmp_idix_p1,
    input logic         branch_idix_p1,
    input logic [15:0]  pc_p1,

    // Outputs
    output logic [15:0] rd_p1,
    output logic        alu_output_valid
);

logic [15:0]    add1, add2;
logic [15:0]    add_out;
logic           carry;
logic           adder_in_use;

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

endmodule