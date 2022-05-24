module fetch (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic         branch_taken_ixif_p1,
    input logic [15:0]  branch_target_ixif_p1,
    input logic         illegal_op_idif_p1,
    input logic         return_execution_idif_p1,

    // Outputs
    output logic [15:0] pc_p1,
    output logic [15:0] nxt_pc_p1,
    output logic [15:0] inst_ifid_p1,
    output logic        err_p1,
    output logic [15:0] epc_p1
);

logic [15:0]    addr;
logic           enable;
logic [15:0]    data_in;
logic           wr;
logic           wr_success_ix_p1;

assign nxt_pc_p1 = pc_p1 + 16'd2;

// ----
// PC Update
// ----
always_ff @ (posedge clk) begin
    // Start execution from 16'h0
    if (rst)
        pc_p1 <= 'b0;
    // Branch taken, go to branch target
    else if (branch_taken_ixif_p1)
        pc_p1 <= branch_target_ixif_p1;
    // Illegal op, go to exception handler at 0x0002
    else if (illegal_op_idif_p1)
        pc_p1 <= 16'h2;
    // Return from execution, load EPC
    else if (return_execution_idif_p1)
        pc_p1 <= epc_p1;
    // Normal execution, 2 byte instruction - pc , pc + 2 ..
    else 
        pc_p1 <= nxt_pc_p1;
end

// ----
// EPC Update
// ----
always_ff @ (posedge clk) begin
    // Reset all registers to 0
    if (rst)
        epc_p1 <= 16'b0;
    else if (illegal_op_idif_p1)
        epc_p1 <= nxt_pc_p1;
end

// Addr to read or write in the instruction memory
assign addr = pc_p1;

// Do we enable read or write? Always set to default 1
assign enable = 1;

// Read or write
// Default 0 for now
assign wr = 0;

// Write data
assign data_in = 'h0;

memory_ram if_mem (
    // Inputs
    .clk            (clk),
    .rst            (rst),
    .addr           (addr),
    .enable         (enable),
    .data_in        (data_in),
    .wr             (wr),

    // Outputs
    .data_out       (inst_ifid_p1),
    .err            (err_p1),
    .wr_success     (wr_success_ix_p1)
);

endmodule
