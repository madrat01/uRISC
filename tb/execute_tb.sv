module execute_tb(input logic clk, input logic rst);

logic [2:0]     rs_in;  // Source register
logic [2:0]     rt_in;  // 2nd source register
logic [2:0]     rd_in;  // Destination register
logic           wr;     // Write desitination register?
logic           en;
logic [15:0]    data_in;
logic           excep;
logic [15:0]    pc;

logic [15:0]    rs_p1;
logic [15:0]    rt_p1;
logic [15:0]    alu_output_data;
logic           wr_success_p1;
logic [15:0]    epc_p1;

logic           alu_write_valid;

logic [25:0]    uop_cnt_idix_p3;
logic           execute_valid_idix_p3;
logic           ldst_valid_idix_p3;
logic           jmp_idix_p3;
logic           jmp_displacement_idix_p3;
logic           branch_idix_p3;
logic [4:0]     opcode_idix_p3;
logic           rotate_shift_right_idix_p3;
logic [15:0]    pc_p1;
logic [2:0]     rs_idix_p3;
logic [2:0]     rt_idix_p3;
logic [2:0]     rd_idix_p3;
logic [2:0]     dest_reg_idix_p3;
logic           reg_write_valid_idix_p3;
logic [15:0]    dest_reg_value_ixmem_p4;
logic [2:0]     dest_reg_index_ixmem_p4;
logic           dest_reg_write_valid_ixmem_p4;
logic [15:0]    mem_addr_ixmem_p4;
logic           ldst_valid_ixmem_p4;
logic [1:0]     store_valid_ixmem_p4;
logic [1:0]     store_valid_idix_p3;
logic [15:0]    mem_data_in_ixmem_p4;
logic [2:0]     dest_reg_index_memwb_p5;
logic [15:0]    dest_reg_value_memwb_p5;
logic           dest_reg_write_valid_memwb_p5;

logic [15:0]    inst_idix_p3;

task automatic shifter_check (ref logic [15:0] A, ref logic [3:0] amt, ref logic [25:0] rotate, ref logic right, ref logic [15:0] result);
    logic [4:0] amt_ext;
    $display("--- Shifter Check Started --- ");
    @ (negedge clk);
    A = 16'h8FFF;
    rotate = 26'h0000000;
    right = 1'b1;
    for (amt_ext = 0; amt_ext <= 4'd15; amt_ext++) begin
        amt = amt_ext[3:0];
        #2
        assert (result === A >> amt)
        else $error("Logical Left Shift Failed, Shift Amt %d, I/P Value %b, O/P Value %b, Actual %b", amt, A, result, A << amt);
        @ (negedge clk);
    end
    A = 16'h8FFF;
    right = 1'b0;
    for (amt_ext = 0; amt_ext <= 4'd15; amt_ext++) begin
        amt = amt_ext[3:0];
        #2
        assert (result === A << amt)
        else $error("Logical Right Shift Failed, Shift Amt %d, I/P Value %b, O/P Value %b, Actual %b", amt, A, result, A >> amt);
        @ (negedge clk);
    end
    $display("--- Shifter Check Completed --- ");
endtask

execute u_execute (.*);

initial begin
    shifter_check(u_execute.rs_p1, u_execute.u_alu.shift_rotate_val, uop_cnt_idix_p3, rotate_shift_right_idix_p3, u_execute.u_alu.shift_rotate_out);
    repeat (5) @ (posedge clk);
end

endmodule