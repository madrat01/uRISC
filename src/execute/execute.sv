module execute (
    input logic         clk,
    input logic         rst,
    input logic [15:0]  pc_p1,
    input logic [15:0]  inst_idix_p1,
    input logic [15:0]  rs_idix_p1,
    input logic [15:0]  rt_idix_p1,
    input logic [15:0]  rd_idix_p1,
    input logic [25:0]  uop_cnt_idix_p1,
    input logic         execute_valid_idix_p1,
    input logic         ldst_valid_idix_p1,
    input logic [1:0]   store_valid_idix_p1,
    input logic         jmp_idix_p1,
    input logic         branch_idix_p1,
    input logic [4:0]   opcode_idix_p1,
    input logic         rotate_shift_right_idix_p1,
    input logic [2:0]   dest_reg_idix_p1,
    input logic         reg_write_valid_idix_p1,
    input logic         jmp_displacement_idix_p1,
    input logic [15:0]  nxt_pc_p1,

    // Outputs
    output logic [15:0] dest_reg_value_ixmem_p1,
    output logic [2:0]  dest_reg_index_ixmem_p1,
    output logic        dest_reg_write_valid_ixmem_p1,
    output logic [15:0] mem_addr_ixmem_p1,
    output logic        ldst_valid_ixmem_p1,
    output logic [1:0]  store_valid_ixmem_p1,
    output logic [15:0] mem_data_in_ixmem_p1,
    output logic        branch_taken_ixif_p1,
    output logic [15:0] branch_target_ixif_p1
);

logic           alu_write_valid;
logic [15:0]    alu_output_data;
logic [15:0]    pc_nxt_p1;

// WB reg write from execute stage
assign dest_reg_index_ixmem_p1 = dest_reg_idix_p1;
assign dest_reg_value_ixmem_p1 = uop_cnt_idix_p1[1] ? nxt_pc_p1 : alu_output_data; //JL, JAL or Alu Output
assign dest_reg_write_valid_ixmem_p1 = reg_write_valid_idix_p1;

// Memory load/store address
assign mem_addr_ixmem_p1 = alu_output_data;
assign ldst_valid_ixmem_p1 = ldst_valid_idix_p1;
assign store_valid_ixmem_p1 = store_valid_idix_p1;
assign mem_data_in_ixmem_p1 = rd_idix_p1;

alu u_alu(
    // Inputs
    .clk                        (clk                   ),
    .rst                        (rst                   ),
    .rs_p1                      (rs_idix_p1            ),
    .rt_p1                      (rt_idix_p1            ),
    .inst_idix_p1               (inst_idix_p1          ),
    .opcode_idix_p1             (opcode_idix_p1        ),
    .uop_cnt_idix_p1            (uop_cnt_idix_p1       ),
    .execute_valid_idix_p1      (execute_valid_idix_p1 ),
    .ldst_valid_idix_p1         (ldst_valid_idix_p1    ),
    .jmp_idix_p1                (jmp_idix_p1           ),
    .branch_idix_p1             (branch_idix_p1        ),
    .pc_p1                      (pc_p1                 ),
    .rotate_shift_right_idix_p1 (rotate_shift_right_idix_p1 ),
    .dest_reg_idix_p1           (dest_reg_idix_p1           ),
    .reg_write_valid_idix_p1    (reg_write_valid_idix_p1    ),
    .jmp_displacement_idix_p1   (jmp_displacement_idix_p1   ),
    .nxt_pc_p1                  (nxt_pc_p1                  ),

    // Outputs
    .alu_output_data            (alu_output_data            ),
    .pc_nxt_p1                  (pc_nxt_p1                  )
);

assign branch_target_ixif_p1 = pc_nxt_p1;
assign branch_taken_ixif_p1 = branch_idix_p1 & alu_output_data[0] | jmp_idix_p1 | jmp_displacement_idix_p1;

endmodule