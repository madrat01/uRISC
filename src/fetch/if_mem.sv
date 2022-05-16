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

logic [7:0]     mem[0:65535];
logic           loaded;

`ifndef SYNTH
initial begin
    loaded = 0;
    for (int i = 0; i < 65536; i++)
        mem[i] = 'b0;
end
`endif

// Read data if enable set and not writing
assign data_out = enable & ~wr ? {mem[addr], mem[addr+1]} : 16'h0;

// Dosen't support unaligned accesses
assign err = enable & addr[0];

// Big-endian memory
always_ff @(posedge clk, posedge rst) begin : mem_write
    `ifndef SYNTH
    // Load memory at reset
    if (rst) begin
        if (!loaded) begin
            $readmemh("loadfile_all.img", mem);
            loaded = 1;
        end
    end
    `endif
    // Write memory when enable and write enable set
    if (enable & wr) begin
        mem[addr+1] <= data_in[7:0];
        mem[addr] <= data_in[15:8];
    end
end

endmodule