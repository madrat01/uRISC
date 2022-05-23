module mem (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic [15:0]  mem_addr_ixmem_p1,
    input logic [15:0]  mem_data_in_ixmem_p1,
    input logic         ldst_valid_ixmem_p1,
    input logic [1:0]   store_valid_ixmem_p1,
    input logic [15:0]  dest_reg_value_ixmem_p1,
    input logic [2:0]   dest_reg_index_ixmem_p1,
    input logic         dest_reg_write_valid_ixmem_p1,

    // Outputs
    output logic [15:0] dest_reg_value_memwb_p1,
    output logic [2:0]  dest_reg_index_memwb_p1,
    output logic        dest_reg_write_valid_memwb_p1 
);

logic [15:0]    addr;
logic           enable;
logic [15:0]    data_in;
logic           wr;
logic           err;
logic [15:0]    mem_read_output;

// Address to read/write
assign addr = mem_addr_ixmem_p1;

// Enable memory acccess when LD/ST instruction
assign enable = ldst_valid_ixmem_p1;

// Data to be written in to memory
assign data_in = mem_data_in_ixmem_p1;

// wr enable when store instruction valid
assign wr = store_valid_ixmem_p1;

ldst_mem ldst_mem (
    // Inputs
    .clk            (clk),
    .rst            (rst),
    .addr           (addr),
    .enable         (enable),
    .data_in        (data_in),
    .wr             (wr),

    // Outputs
    .data_out       (mem_read_output),
    .err            (err),
    .wr_success     (wr_success)
);

assign dest_reg_index_memwb_p1 = dest_reg_index_ixmem_p1;
assign dest_reg_value_memwb_p1 = ldst_valid_ixmem_p1 & ~|store_valid_ixmem_p1 ? mem_read_output : dest_reg_value_ixmem_p1;
assign dest_reg_write_valid_memwb_p1 = dest_reg_write_valid_ixmem_p1;

endmodule