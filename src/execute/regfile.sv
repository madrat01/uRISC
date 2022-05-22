module regfile (
    // Inputs
    input logic         clk,
    input logic         rst,
    input logic [2:0]   rs_in,  // Read Source register
    input logic [2:0]   rt_in,  // Read 2nd source register
    input logic [2:0]   rd_in,  // Read Destination register
    input logic [2:0]   dest_in,// Write Destination register
    input logic         wr,     // Write desitination register?
    input logic         en,
    input logic [15:0]  data_in,
    input logic         excep,
    input logic [15:0]  pc,

    // Outputs
    output logic [15:0] rs_out,
    output logic [15:0] rt_out,
    output logic [15:0] rd_out,
    output logic        wr_success,
    output logic [15:0] epc
);

// 8 16-bit GPRs
// R0-R6 used for normal execution
// R7 used for JAL and JALR
logic [15:0]    gpr[0:7];

// ----
// Read Register
// ----
assign rs_out = en ? gpr[rs_in] : 'bx;
assign rt_out = en ? gpr[rt_in] : 'bx;
assign rd_out = en ? gpr[rd_in] : 'bx;

// ----
// Write Register
// ----
always_ff @ (posedge clk) begin
    // Reset all registers to 0
    if (rst) begin
        gpr[0] <= 16'b0;
        gpr[1] <= 16'b0;
        gpr[2] <= 16'b0;
        gpr[3] <= 16'b0;
        gpr[4] <= 16'b0;
        gpr[5] <= 16'b0;
        gpr[6] <= 16'b0;
        gpr[7] <= 16'b0;
        wr_success <= 1'b0;
    // Actul write to the register
    end else if (wr) begin
        gpr[dest_in] <= data_in; 
        wr_success <= 1'b1;
    // Default write success to 0
    end else
        wr_success <= 1'b0;
end

// ----
// Write EPC Register
// ----
always_ff @ (posedge clk) begin
    // Reset all registers to 0
    if (rst)
        epc <= 16'b0;
    else if (excep)
        epc <= pc;
end

endmodule