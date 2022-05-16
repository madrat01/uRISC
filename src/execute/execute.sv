module execute (
    input logic         clk,
    input logic         rst,
    input logic [15:0]  pc_p1,
    input logic [2:0]   rs_idix_p1,
    input logic [2:0]   rt_idix_p1,
    input logic [2:0]   rd_idix_p1,
    input logic [25:0]  uop_cnt_idix_p1,
    input logic         execute_valid_idix_p1,
    input logic         ldst_valid_idix_p1,
    input logic         jmp_idix_p1,
    input logic         branch_idix_p1,
    input logic [4:0]   opcode_idix_p1
);

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
logic [15:0]    rd_p1;
logic           wr_success_p1;
logic [15:0]    epc_p1;

logic           alu_output_valid;

// Rs, Rt and Rd registers
assign rs_in = rs_idix_p1;
assign rt_in = rt_idix_p1;
assign rd_in = rd_idix_p1;

// Enable read of registers when instruction valid
assign en = uop_cnt_idix_p1[0];

assign pc = pc_p1;

regfile u_regfile(
    // Inputs
    .clk                (clk        ),
    .rst                (rst        ),
    .rs_in              (rs_in      ),
    .rt_in              (rt_in      ),
    .rd_in              (rd_in      ),
    .wr                 (wr         ),
    .en                 (en         ),
    .data_in            (data_in    ),
    .excep              (excep      ),
    .pc                 (pc         ),

    // Outputs
    .rs_out             (rs_p1      ),
    .rt_out             (rt_p1      ),
    .wr_success         (wr_success_p1 ),
    .epc                (epc_p1     )
);

alu u_alu(
    // Inputs
    .clk                   (clk                   ),
    .rst                   (rst                   ),
    .rs_p1                 (rs_p1                 ),
    .rt_p1                 (rt_p1                 ),
    .opcode_idix_p1        (opcode_idix_p1        ),
    .uop_cnt_idix_p1       (uop_cnt_idix_p1       ),
    .execute_valid_idix_p1 (execute_valid_idix_p1 ),
    .ldst_valid_idix_p1    (ldst_valid_idix_p1    ),
    .jmp_idix_p1           (jmp_idix_p1           ),
    .branch_idix_p1        (branch_idix_p1        ),
    .pc_p1                 (pc_p1                 ),

    // Outputs
    .rd_p1                 (rd_p1                 ),
    .alu_output_valid      (alu_output_valid      )
);

endmodule