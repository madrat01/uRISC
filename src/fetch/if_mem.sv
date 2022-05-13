module if_mem (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic [15:0]  addr,
    input logic         enable,
    input logic [15:0]  data_in,
    input logic         wr,

    // Outputs
    output logic [15:0] data_out,
    output logic        err
);

logic [7:0]    mem[65536];

// Read data if enable set and not writing
assign data_out = enable & ~wr ? {mem[addr], mem[addr+1]} : 16'h0;

// Dosen't support unaligned accesses
assign err = enable & addr[0];

// Big-endian memory
always_ff @(posedge clk) begin : mem_write
    if (enable & wr) begin
        mem[addr+1] <= data_in[7:0];
        mem[addr] <= data_in[15:8];
    end
end

endmodule