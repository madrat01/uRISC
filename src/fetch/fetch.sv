module fetch (
    input logic         clk,
    input logic         rst,
    input logic [15:0]  pc,

    output logic [15:0] inst_ifid,
    output logic        err
);

logic [15:0]    addr;
logic           enable;
logic           data_in;
logic           wr;

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