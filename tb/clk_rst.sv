module clk_rst (
    output logic        clk,
    output logic        rst
);

task automatic reset_task (ref rst, ref clk);
    rst = 1;
    repeat (3) @ (negedge clk);
    rst = 0;
endtask //automatic

initial begin
    clk = 0;
    reset_task(rst, clk);
end

always
    #10 clk = ~clk;

endmodule