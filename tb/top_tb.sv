module top_tb();

logic clk;
logic rst;
logic err_p1;

top uRISC(.*);

initial begin
    clk = 0;
end

always
    #10 clk = ~clk;

initial begin
    rst = 1;
    repeat (3) @ (negedge clk);
    rst = 0;
    repeat (5) @ (posedge clk);
    $stop;
end

endmodule