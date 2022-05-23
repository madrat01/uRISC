module clk_rst (
    output logic        clk,
    output logic        rst
);
    
int cycle_count;

task automatic reset_task (ref rst, ref clk);
    rst = 1;
    repeat (2) @ (negedge clk);
    rst = 0;
endtask //automatic

initial begin
    clk = 0;
    reset_task(rst, clk);
end

always
    #10 clk = ~clk;

always_ff @ (posedge clk)
    cycle_count <= cycle_count + 1;

endmodule