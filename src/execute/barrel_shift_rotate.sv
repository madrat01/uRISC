module barrel_shift_rotate (
    // Inputs
    input logic             clk,
    input logic [15:0]      A,
    input logic [3:0]       amt,
    input logic             rotate,
    input logic             right,

    // Outputs
    output logic [15:0]     result
);

logic [15:0]    stg1_shft, stg2_shft, stg3_shft, shift_r;
logic [15:0]    stg1_rot, stg2_rot, stg3_rot, rotate_r;

assign stg1_rot = amt[0] ? (~right ? {A[14:0], A[15]}                   : {A[0], A[15:1]})                  : A;
assign stg2_rot = amt[1] ? (~right ? {stg1_rot[13:0], stg1_rot[15:14]}  : {stg1_rot[1:0], stg1_rot[15:2]})  : stg1_rot;
assign stg3_rot = amt[2] ? (~right ? {stg2_rot[11:0], stg2_rot[15:12]}  : {stg2_rot[3:0], stg2_rot[15:4]})  : stg2_rot;
assign rotate_r = amt[3] ? (~right ? {stg3_rot[7:0], stg3_rot[15:8]}    : {stg3_rot[7:0], stg3_rot[15:8]})  : stg3_rot;

assign stg1_shft = amt[0] ? (~right ? {A[14:0], 1'b0}           : {1'b0, A[15:1]})          : A;
assign stg2_shft = amt[1] ? (~right ? {stg1_shft[13:0], 2'b0}   : {2'b0, stg1_shft[15:2]})  : stg1_shft;
assign stg3_shft = amt[2] ? (~right ? {stg2_shft[11:0], 4'b0}   : {4'b0, stg2_shft[15:4]})  : stg2_shft;
assign shift_r   = amt[3] ? (~right ? {stg3_shft[7:0], 8'b0}    : {8'b0, stg3_shft[15:8]})  : stg3_shft;

assign result = rotate ? rotate_r : shift_r;

endmodule