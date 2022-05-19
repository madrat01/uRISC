module decode_tb(input logic clk, input logic rst);

logic [15:0]     pc_p1;
logic [15:0]     inst_ifid_p1;
logic [15:0]     epc_p1;

logic [2:0]     rd_idix_p1;
logic [2:0]     rs_idix_p1;
logic [2:0]     rt_idix_p1;
logic           ldst_valid_idix_p1;
logic           ldst_valid_idmem_p1;
logic           halt_idif_p1;
logic           nop_idif_p1;
logic           illegal_op_idif_p1;
logic           return_execution_idif_p1;
logic           jmp_idix_p1;
logic           branch_idix_p1;
logic           jmp_displacement_idif_p1;
logic [15:0]    jmp_displacement_value_idif_p1;
logic [4:0]     opcode_idix_p1;
logic           execute_valid_idix_p1;
logic [25:0]    uop_cnt_idix_p1;
logic           rotate_shift_right_idix_p1;
logic [15:0]    inst_idix_p1;

task automatic force_inst (input logic [15:0] inst, output logic [15:0] inst_f);
    inst_f = inst;
endtask

task automatic decode_check (ref logic [15:0] inst_f, ref logic [25:0] uop_cnt);
    $display("--- Decode Check Started --- ");
    @ (negedge clk);
    force_inst(16'h0000, inst_f);  // HALT
    #2
    assert (uop_cnt[0] == 0) 
    else $error("HALT: Inst Valid");
    @ (negedge clk);
    force_inst(16'h0800, inst_f);  // NOP
    #2
    assert (uop_cnt[0] == 0) 
    else $error("NOP: Inst Valid");
    @ (negedge clk);
    force_inst(16'h481F, inst_f);  // SUBI
    #2
    assert (uop_cnt[18] == 1) 
    else $error("SUBI: Inst Invalid");
    @ (negedge clk);
    force_inst(16'hA81F, inst_f);  // SLLI
    #2
    assert (uop_cnt[20] == 1) 
    else $error("SLLI: Inst Invalid");
    @ (negedge clk);
    force_inst(16'h8810, inst_f);  // LD
    #2
    assert (uop_cnt[25:18] == 'b0) 
    else $error("LD: Inst Invalid");
    @ (negedge clk);
    force_inst(16'hC810, inst_f);  // BTR
    #2
    assert (uop_cnt[22] == 1) 
    else $error("BTR: Inst Invalid");
    @ (negedge clk);
    force_inst(16'hD813, inst_f);  // ANDN
    #2
    assert (uop_cnt[23] == 'b1) 
    else $error("ANDN: Inst Invalid");
    @ (negedge clk);
    force_inst(16'hD710, inst_f);  // ROL
    #2
    assert (uop_cnt[24] == 'b1) 
    else $error("ROL: Inst Invalid");
    @ (negedge clk);
    force_inst(16'hF710, inst_f);  // SLE
    #2
    assert (uop_cnt[25] == 'b1) 
    else $error("SLE: Inst Invalid");
    @ (negedge clk);
    force_inst(16'h78FF, inst_f);  // BGEZ
    #2
    assert (uop_cnt[25:18] == 'b0) 
    else $error("BGEZ: Inst Invalid");
    @ (negedge clk);
    force_inst(16'hC000, inst_f);  // LBI
    #2
    assert (uop_cnt[21] == 'b1) 
    else $error("LBI: Inst Invalid");
    @ (negedge clk);
    force_inst(16'h90FF, inst_f);  // SLBI
    #2
    assert (uop_cnt[19] == 'b1) 
    else $error("SLBI: Inst Invalid");
    @ (negedge clk);
    force_inst(16'h20FF, inst_f);  // J
    #2
    assert (uop_cnt[1] == 'b0) 
    else $error("J: Inst Invalid");
    @ (negedge clk);
    force_inst(16'h30FF, inst_f);  // JALR
    #2
    assert (uop_cnt[1] == 'b1) 
    else $error("JALR: Inst Invalid");
    @ (negedge clk);
    force_inst(16'h10FF, inst_f);  // IllegalOp
    #2
    assert (uop_cnt[0] == 'b0) 
    else $error("Illegal Op: Inst Invalid");
    @ (negedge clk);
    force_inst(16'h18FF, inst_f);  // Return from exception
    @ (negedge clk);
    $display("--- Decode Check Completed --- ");
endtask //automatic

decode u_decode (.*);

initial begin
    decode_check(inst_ifid_p1, uop_cnt_idix_p1);
    repeat (5) @ (posedge clk);
end

endmodule