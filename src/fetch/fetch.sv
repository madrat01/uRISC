module fetch (
    // Inputs
    input logic         clk,
    input logic         rst,

    // Outputs
    output logic [15:0] pc_p1,
    output logic [15:0] inst_ifid_p1,
    output logic        err_p1
);

logic [15:0]    addr;
logic           enable;
logic [15:0]    data_in;
logic           wr;

always_ff @ (posedge clk) begin
    // Start execution from 16'h0
    if (rst)
        pc_p1 <= 'b0;
    // Normal execution, 2 byte instruction - pc , pc + 2 ..
    else 
        pc_p1 <= pc_p1 + 2;
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

if_mem if_mem (
    // Inputs
    .clk            (clk),
    .rst            (rst),
    .addr           (addr),
    .enable         (enable),
    .data_in        (data_in),
    .wr             (wr),

    // Outputs
    .data_out       (inst_ifid_p1),
    .err            (err_p1)
);

endmodule
