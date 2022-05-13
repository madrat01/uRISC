module top (
    // Inputs
    input logic             clk,
    input logic             rst,

    // Outputs
    output logic            err
);

logic [15:0]    pc;
logic [15:0]    inst_ifid;

fetch ifetch
(
    // Inputs
    .clk        (clk),
    .rst        (rst),
    .pc         (pc),

    // Outputs
    .inst_ifid  (inst_ifid),
    .err        (err)
);

//decode idec
//(
//    .clk        (clk),
//    .rst        (rst)
//);
//
//execute iexe
//(
//    .clk        (clk),
//    .rst        (rst)
//);
//
//mem mem
//(
//    .clk        (clk),
//    .rst        (rst)
//);
//
//writeback wb
//(
//    .clk        (clk),
//    .rst        (rst)
//);

endmodule