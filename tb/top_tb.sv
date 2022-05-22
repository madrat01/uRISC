module top_tb();

logic           clk;
logic           rst;
logic           err_p1;
logic [15:0]    inst_count;
logic           halt_idif_p1;

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
    fork
        begin : run_test
            repeat (10000) @ (posedge clk);
            $display ("10k Instructions Run: Stop!");
            $stop;
        end
        begin
            if (halt_idif_p1) begin
                disable run_test;
                $display ("Halt Instruction! Instruction Count %d", inst_count);
                $stop;
            end
        end
    join
end

always_ff @(posedge clk) begin
    if (~rst)
        inst_count <= inst_count + 1;
end

endmodule