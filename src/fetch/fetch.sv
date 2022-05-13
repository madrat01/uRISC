module fetch (
    // Inputs
    input logic         clk,
    input logic         rst,

    // Outputs
    output logic [15:0] pc,
    output logic [15:0] inst_ifid,
    output logic        err
);

logic [15:0]    addr;
logic           enable;
logic [15:0]    data_in;
logic           wr;

always_ff @ (posedge clk, posedge rst) begin
    if (rst)
        pc <= 'b0;
    // Normal execution, 2 byte instruction - pc , pc + 2 ..
    else 
        pc <= pc + 2;
end

// Addr to read or write in the instruction memory
assign addr = pc;

// Do we enable read or write? Always set to default 1
assign enable = 1;

// Read or write
// Default 0 for now
assign wr = 0;

if_mem if_mem (
    // Inputs
    .clk            (clk),
    .rst            (rst),
    .addr           (addr),
    .enable         (enable),
    .data_in        (data_in),
    .wr             (wr),

    // Outputs
    .data_out       (inst_ifid),
    .err            (err)
);

endmodule
