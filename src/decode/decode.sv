module decode 
    import defines_pkg::*;    
(
    // Inputs
    input logic             clk,
    input logic             rst,
    input logic [15:0]      pc_p2,
    input logic [15:0]      inst_ifid_p2,
    input logic [15:0]      nxt_pc_p2,
    input logic [2:0]       dest_reg_index_memwb_p5,
    input logic [15:0]      dest_reg_value_memwb_p5,
    input logic             dest_reg_write_valid_memwb_p5,

    // Outputs
    output logic [15:0]     pc_p3,
    output logic [15:0]     nxt_pc_p3,
    output logic [15:0]     inst_idix_p3,
    output logic            ldst_valid_idix_p3,
    output logic            halt_idif_p3,
    output logic            nop_idif_p3,
    output logic            illegal_op_idif_p3,
    output logic            return_execution_idif_p3,
    output logic            jmp_idix_p3,
    output logic            branch_idix_p3,
    output logic            jmp_displacement_idif_p3,
    output logic            jmp_displacement_idix_p3,
    output logic [15:0]     jmp_displacement_value_idif_p3,
    output logic [4:0]      opcode_idix_p3,
    output logic            execute_valid_idix_p3,
    output logic [25:0]     uop_cnt_idix_p3,
    output logic            rotate_shift_right_idix_p3,
    output logic [2:0]      dest_reg_idix_p3,
    output logic            reg_write_valid_idix_p3,
    output logic [1:0]      store_valid_idix_p3, // 0-Store, 1-Store with update
    output inst_t           curr_inst_idix_p3,
    output logic [15:0]     rs_idix_p3,
    output logic [15:0]     rt_idix_p3,
    output logic [15:0]     rd_idix_p3
);

// Decode
logic [2:0]     rs_index;  // Read Source register
logic [2:0]     rt_index;  // Read 2nd source register
logic [2:0]     rd_index;  // Read Destination register
logic [2:0]     dest_index;// Write Destination register
logic           wr;     // Write desitination register?
logic           en;
logic [15:0]    data_in;
logic [25:0]    uop_cnt_idix_p2;

// Writeback
logic           wr_success_wb_p6;

always_ff @ (posedge clk) begin
    pc_p3 <= pc_p2;
    nxt_pc_p3 <= nxt_pc_p2;
end

// Enable read of registers when instruction valid
assign en = uop_cnt_idix_p2[0];

// ----------------
// Write back state
// ----------------
// Index of register to write
assign dest_index = dest_reg_index_memwb_p5;

// Write enable
assign wr = dest_reg_write_valid_memwb_p5;

// Data to write
assign data_in = dest_reg_value_memwb_p5;

always_ff @ (posedge clk)
    inst_idix_p3 <= inst_ifid_p2;

regfile u_regfile(
    // Inputs
    .clk                (clk        ),
    .rst                (rst        ),
    .rs_in              (rs_index   ),
    .rt_in              (rt_index   ),
    .rd_in              (rd_index   ),
    .dest_in            (dest_index ),
    .wr                 (wr         ),
    .en                 (en         ),
    .data_in            (data_in    ),

    // Outputs
    .rs_out             (rs_idix_p3      ),
    .rt_out             (rt_idix_p3      ),
    .rd_out             (rd_idix_p3      ),
    .wr_success         (wr_success_wb_p6)
);

uop_control u_uop_control (
    // Inputs
    .clk                            (clk                            ),
    .rst                            (rst                            ),
    .pc_p2                          (pc_p2                          ),
    .inst_ifid_p2                   (inst_ifid_p2                   ),
    .nxt_pc_p2                      (nxt_pc_p2                      ),

    // Outputs
    .rd_index                       (rd_index                       ),
    .rs_index                       (rs_index                       ),
    .rt_index                       (rt_index                       ),
    .ldst_valid_idix_p3             (ldst_valid_idix_p3             ),
    .halt_idif_p3                   (halt_idif_p3                   ),
    .nop_idif_p3                    (nop_idif_p3                    ),
    .illegal_op_idif_p3             (illegal_op_idif_p3             ),
    .return_execution_idif_p3       (return_execution_idif_p3       ),
    .jmp_idix_p3                    (jmp_idix_p3                    ),
    .branch_idix_p3                 (branch_idix_p3                 ),
    .jmp_displacement_idif_p3       (jmp_displacement_idif_p3       ),
    .jmp_displacement_idix_p3       (jmp_displacement_idix_p3       ),
    .jmp_displacement_value_idif_p3 (jmp_displacement_value_idif_p3 ),
    .opcode_idix_p3                 (opcode_idix_p3                 ),
    .execute_valid_idix_p3          (execute_valid_idix_p3          ),
    .uop_cnt_idix_p3                (uop_cnt_idix_p3                ),
    .uop_cnt_idix_p2                (uop_cnt_idix_p2                ),
    .rotate_shift_right_idix_p3     (rotate_shift_right_idix_p3     ),
    .dest_reg_idix_p3               (dest_reg_idix_p3               ),
    .reg_write_valid_idix_p3        (reg_write_valid_idix_p3        ),
    .store_valid_idix_p3            (store_valid_idix_p3            ),
    .curr_inst_idix_p3              (curr_inst_idix_p3              )
);

endmodule