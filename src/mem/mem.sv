module mem (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic [15:0]  pc_p4,
    input logic [15:0]  mem_addr_ixmem_p4,
    input logic [15:0]  mem_data_in_ixmem_p4,
    input logic         ldst_valid_ixmem_p4,
    input logic [1:0]   store_valid_ixmem_p4,
    input logic [15:0]  dest_reg_value_ixmem_p4,
    input logic [2:0]   dest_reg_index_ixmem_p4,
    input logic         dest_reg_write_valid_ixmem_p4,

    // Outputs
    output logic [15:0] pc_p5,
    output logic        err_p4,
    output logic [15:0] dest_reg_value_memwb_p5,
    output logic [2:0]  dest_reg_index_memwb_p5,
    output logic        dest_reg_write_valid_memwb_p5 
);

logic [15:0]    addr;
logic           enable;
logic [15:0]    data_in;
logic           wr;
logic [15:0]    mem_read_output;
logic           wr_success_mem_p5;

// Address to read/write
assign addr = mem_addr_ixmem_p4;

// Enable memory acccess when LD/ST instruction
assign enable = ldst_valid_ixmem_p4;

// Data to be written in to memory
assign data_in = mem_data_in_ixmem_p4;

// wr enable when store instruction valid
assign wr = |store_valid_ixmem_p4;

memory_ram ldst_mem (
    // Inputs
    .clk            (clk),
    .rst            (rst),
    .addr           (addr),
    .enable         (enable),
    .data_in        (data_in),
    .wr             (wr),

    // Outputs
    .data_out       (mem_read_output),
    .err            (err_p4),
    .wr_success     (wr_success_mem_p5)
);

always_ff @(posedge clk) begin
    dest_reg_index_memwb_p5         <= dest_reg_index_ixmem_p4;
    dest_reg_value_memwb_p5         <= ldst_valid_ixmem_p4 & ~|store_valid_ixmem_p4 ? mem_read_output : dest_reg_value_ixmem_p4;
    dest_reg_write_valid_memwb_p5   <= dest_reg_write_valid_ixmem_p4;
end

always_ff @ (posedge clk)
    pc_p5 <= pc_p4;

endmodule