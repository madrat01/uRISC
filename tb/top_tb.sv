module top_tb();

logic           clk;
logic           rst;
logic           err_p1;
logic           halt_idif_p1;

logic [15:0]    PC;
logic [15:0]    Inst;           /* This should be the 15 bits of the FF that
                                   stores instructions fetched from instruction memory
                                */
logic           RegWrite;       /* Whether register file is being written to */
logic [2:0]     WriteRegister;  /* What register is written */
logic [15:0]    WriteData;      /* Data */
logic           MemWrite;       /* Similar as above but for memory */
logic           MemRead;
logic [15:0]    MemAddress;
logic [15:0]    MemData;

logic           Halt;         /* Halt executed and in Memory or writeback stage */
     
int             inst_count;
int             trace_file;
int             sim_log_file;

logic           Error;

// Clk and Reset generation block
clk_rst clk_rst (.*);

// --- DUT ---
//decode_tb decode_tb (.*);
//execute_tb execute_tb (.*);

top uRISC (.*);
// -----------

initial begin
    trace_file = $fopen("verilogsim.trace");
    sim_log_file = $fopen("verilogsim.log");
end

initial begin
    fork
        begin : run_test
            repeat (10000) @ (posedge clk);
            $display ("10k Instructions Run: Stop!");
            $stop;
        end
        begin
            if (Error) begin
                disable run_test;
                $display ("Instruction Error! Instruction Count %d", inst_count);
                $stop;
            end
        end
    join
end

always_ff @(posedge clk) begin
    if (rst)
        inst_count <= 'b0;
    else begin
        if (Halt || RegWrite || MemWrite)
            inst_count <= inst_count + 1;
        $fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %8x R: %d %3d %8x M: %d %d %8x %8x",
                  clk_rst.cycle_count,
                  PC,
                  Inst,
                  RegWrite,
                  WriteRegister,
                  WriteData,
                  MemRead,
                  MemWrite,
                  MemAddress,
                  MemData);
        if (RegWrite) begin
            if (MemWrite) begin
               // stu
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x ADDR: 0x%04x VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData,
                        MemAddress,
                        MemData);
            end else if (MemRead) begin
               // ld
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x ADDR: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData,
                        MemAddress);
            end else begin
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData );
            end
        end else if (Halt) begin
            $fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
            $fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", clk_rst.cycle_count);
            $fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);
            $fdisplay(trace_file, "INUM: %8d PC: 0x%04x",
                      (inst_count-1),
                      PC );

            $fclose(trace_file);
            $fclose(sim_log_file);

            $finish;
        end else begin // if (RegWrite)
            if (MemWrite) begin
               // st
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x ADDR: 0x%04x VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        MemAddress,
                        MemData);
            end else begin
               // conditional branch or NOP
               // Need better checking in pipelined testbench
               inst_count <= inst_count + 1;
               $fdisplay(trace_file, "INUM: %8d PC: 0x%04x",
                         (inst_count-1),
                         PC );
            end
        end 
    end
end

assign PC = uRISC.pc_p1;

assign Inst = uRISC.inst_ifid_p1;

assign RegWrite = uRISC.reg_write_valid_idix_p1;
// Is register being written, one bit signal (1 means yes, 0 means no)

assign WriteRegister = uRISC.dest_reg_idix_p1;
// The name of the register being written to. (3 bit signal)

assign WriteData = uRISC.dest_reg_value_ixmem_p1;
// Data being written to the register. (16 bits)

assign MemRead =  uRISC.ldst_valid_ixmem_p1 & ~uRISC.store_valid_ixmem_p1;
// Is memory being read, one bit signal (1 means yes, 0 means no)

assign MemWrite = uRISC.ldst_valid_ixmem_p1 & uRISC.store_valid_ixmem_p1;
// Is memory being written to (1 bit signal)

assign MemAddress = uRISC.mem_addr_ixmem_p1;
// Address to access memory with (for both reads and writes to memory, 16 bits)

assign MemData = uRISC.dest_reg_value_ixmem_p1;
// Data to be written to memory for memory writes (16 bits)

assign Halt = uRISC.halt_idif_p1;

assign Error = err_p1;

endmodule