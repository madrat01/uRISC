module execute (
    input logic         clk,
    input logic         rst,
    input logic [15:0]  pc_p3,
    input logic [15:0]  inst_idix_p3,
    input logic [15:0]  rs_idix_p3,
    input logic [15:0]  rt_idix_p3,
    input logic [15:0]  rd_idix_p3,
    input logic [25:0]  uop_cnt_idix_p3,
    input logic         execute_valid_idix_p3,
    input logic         ldst_valid_idix_p3,
    input logic [1:0]   store_valid_idix_p3,
    input logic         jmp_idix_p3,
    input logic         branch_idix_p3,
    input logic [4:0]   opcode_idix_p3,
    input logic         rotate_shift_right_idix_p3,
    input logic [2:0]   dest_reg_idix_p3,
    input logic         reg_write_valid_idix_p3,
    input logic         jmp_displacement_idix_p3,
    input logic [15:0]  nxt_pc_p3,

    // Outputs
    output logic [15:0] dest_reg_value_ixmem_p4,
    output logic [2:0]  dest_reg_index_ixmem_p4,
    output logic        dest_reg_write_valid_ixmem_p4,
    output logic [15:0] mem_addr_ixmem_p4,
    output logic        ldst_valid_ixmem_p4,
    output logic [1:0]  store_valid_ixmem_p4,
    output logic [15:0] mem_data_in_ixmem_p4,
    output logic        branch_taken_ixif_p3,
    output logic [15:0] branch_target_ixif_p3,
    output logic [15:0] pc_p4
);

logic           alu_write_valid;
logic [15:0]    alu_output_data;
logic [15:0]    pc_nxt_p3;

always_ff @ (posedge clk)
    pc_p4 <= pc_p3;

// WB reg write from execute stage
always_ff @ (posedge clk) begin
    dest_reg_index_ixmem_p4         <= dest_reg_idix_p3;
    dest_reg_value_ixmem_p4         <= uop_cnt_idix_p3[1] ? nxt_pc_p3 : alu_output_data; //JL, JAL or Alu Output
    dest_reg_write_valid_ixmem_p4   <= reg_write_valid_idix_p3;
end

// Memory load/store address
always_ff @ (posedge clk) begin
    mem_addr_ixmem_p4       <= alu_output_data;
    ldst_valid_ixmem_p4     <= ldst_valid_idix_p3;
    store_valid_ixmem_p4    <= store_valid_idix_p3;
    mem_data_in_ixmem_p4    <= rd_idix_p3;
end

alu u_alu(
    // Inputs
    .clk                        (clk                   ),
    .rst                        (rst                   ),
    .rs_p3                      (rs_idix_p3            ),
    .rt_p3                      (rt_idix_p3            ),
    .inst_idix_p3               (inst_idix_p3          ),
    .opcode_idix_p3             (opcode_idix_p3        ),
    .uop_cnt_idix_p3            (uop_cnt_idix_p3       ),
    .execute_valid_idix_p3      (execute_valid_idix_p3 ),
    .ldst_valid_idix_p3         (ldst_valid_idix_p3    ),
    .jmp_idix_p3                (jmp_idix_p3           ),
    .branch_idix_p3             (branch_idix_p3        ),
    .pc_p3                      (pc_p3                 ),
    .rotate_shift_right_idix_p3 (rotate_shift_right_idix_p3 ),
    .dest_reg_idix_p3           (dest_reg_idix_p3           ),
    .reg_write_valid_idix_p3    (reg_write_valid_idix_p3    ),
    .jmp_displacement_idix_p3   (jmp_displacement_idix_p3   ),
    .nxt_pc_p3                  (nxt_pc_p3                  ),

    // Outputs
    .alu_output_data            (alu_output_data            ),
    .pc_nxt_p3                  (pc_nxt_p3                  )
);

assign branch_target_ixif_p3 = pc_nxt_p3;
assign branch_taken_ixif_p3 = branch_idix_p3 & alu_output_data[0] | jmp_idix_p3 | jmp_displacement_idix_p3;

endmodule