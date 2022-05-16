module execute (
    input logic         clk,
    input logic         rst,
    input logic [2:0]   rs_idix_p1,
    input logic [2:0]   rt_idix_p1,
    input logic [2:0]   rd_idix_p1,
    input logic [25:0]  uop_cnt_idix_p1,
    input logic         execute_valid_idix_p1,
    input logic         ldst_valid_idix_p1,
    input logic         jmp_idix_p1,
    input logic         branch_idix_p1,
    input logic [4:0]   opcode_idix_p1
);


endmodule