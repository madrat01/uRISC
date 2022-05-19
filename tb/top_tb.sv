module top_tb();

logic           clk;
logic           rst;
logic           err_p1;

task automatic reset_task (ref rst);
    rst = 1;
    repeat (3) @ (negedge clk);
    rst = 0;
endtask //automatic

decode_tb decode_tb (.*);
execute_tb execute_tb (.*);

top uRISC (.*);

initial begin
    clk = 0;
end

always
    #10 clk = ~clk;

initial begin
    reset_task(rst);
    repeat (10000) @ (posedge clk);
    $stop;
end

endmodule