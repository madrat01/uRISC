module ldst_mem (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic [15:0]  addr,
    input logic         enable,
    input logic [15:0]  data_in,
    input logic         wr,

    // Outputs
    output logic [15:0] data_out,
    output logic        err,
    output logic        wr_success
);

`ifndef SYNTH
logic [7:0]     mem[0:65535];
`else
logic [7:0]     mem[0:63];
`endif
logic           loaded;
logic           wr_en;

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

assign wr_en = wr & enable;

// Big-endian memory
always @(posedge clk) begin
    // Load memory at reset
    if (rst) begin
        `ifndef SYNTH
        if (!loaded) begin
            $readmemh("loadfile_all.img", mem);
            loaded = 1;
        end
        `endif
        wr_success <= 1'b0;
    end
    // Write memory when enable and write enable set
    else if (wr_en & ~err) begin
        mem[addr+1] <= data_in[7:0];
        mem[addr] <= data_in[15:8];
        wr_success <= 1'b1;
    end
    else
        wr_success <= 1'b0;
end

endmodule