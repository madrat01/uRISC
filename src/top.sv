module top 
    import defines_pkg::*;
(
    // Inputs
    input logic             clk,
    input logic             rst,

    // Outputs
    output logic            err,
    output logic            halt_idif_p3
);

// Fetch output signals
logic [15:0]    pc_p1;
logic [15:0]    pc_p2;
logic [15:0]    nxt_pc_p2;
logic [15:0]    epc_p1;
logic [15:0]    inst_ifid_p2;
logic           err_p1;

// Decode output signals
logic [15:0]    pc_p3;
logic [15:0]    inst_idix_p3;
logic [15:0]    rd_idix_p3;
logic [15:0]    rs_idix_p3;
logic [15:0]    rt_idix_p3;
logic           ldst_valid_idix_p3;
logic           nop_idif_p3;
logic           illegal_op_idif_p3;
logic           return_execution_idif_p3;
logic           jmp_idix_p3;
logic           branch_idix_p3;
logic           jmp_displacement_idif_p3;
logic           jmp_displacement_idix_p3;
logic [15:0]    jmp_displacement_value_idif_p3;
logic [4:0]     opcode_idix_p3;
logic           execute_valid_idix_p3;
logic [25:0]    uop_cnt_idix_p3;
logic [25:0]    uop_cnt_ixmem_p4;
logic           rotate_shift_right_idix_p3;
logic [2:0]     dest_reg_idix_p3;
logic           reg_write_valid_idix_p3;
logic [1:0]     store_valid_idix_p3;
inst_t          curr_inst_idix_p3;
logic [15:0]    nxt_pc_p3;

// Execute output signals
logic [15:0]    pc_p4;
logic [15:0]    dest_reg_value_ixmem_p4;
logic [2:0]     dest_reg_index_ixmem_p4;
logic           dest_reg_write_valid_ixmem_p4;
logic [15:0]    mem_addr_ixmem_p4;
logic [1:0]     store_valid_ixmem_p4;
logic [15:0]    mem_data_in_ixmem_p4;
logic           ldst_valid_ixmem_p4;
logic           branch_taken_ixif_p3;
logic [15:0]    branch_target_ixif_p3;

// Mem output signals
logic [15:0]    pc_p5;
logic [15:0]    dest_reg_value_memwb_p5;
logic [2:0]     dest_reg_index_memwb_p5;
logic           dest_reg_write_valid_memwb_p5;
logic           err_p4;

assign err = err_p1 | err_p4;

fetch u_fetch
(
    // Inputs
    .clk                        (clk),
    .rst                        (rst),
    .branch_taken_ixif_p3       (branch_taken_ixif_p3),
    .branch_target_ixif_p3      (branch_target_ixif_p3),
    .illegal_op_idif_p3         (illegal_op_idif_p3),
    .return_execution_idif_p3   (return_execution_idif_p3),

    // Outputs
    .pc_p1                      (pc_p1),
    .pc_p2                      (pc_p2),
    .nxt_pc_p2                  (nxt_pc_p2),
    .inst_ifid_p2               (inst_ifid_p2),
    .err_p1                     (err_p1)
);

decode u_decode(
    // Inputs
    .clk                            (clk                            ),
    .rst                            (rst                            ),
    .pc_p2                          (pc_p2                          ),
    .inst_ifid_p2                   (inst_ifid_p2                   ),
    .nxt_pc_p2                      (nxt_pc_p2                      ),
    .dest_reg_value_memwb_p5        (dest_reg_value_memwb_p5        ),
    .dest_reg_index_memwb_p5        (dest_reg_index_memwb_p5        ),
    .dest_reg_write_valid_memwb_p5  (dest_reg_write_valid_memwb_p5  ), 

    // Outputs
    .pc_p3                          (pc_p3                          ),
    .nxt_pc_p3                      (nxt_pc_p3                      ),
    .inst_idix_p3                   (inst_idix_p3                   ),
    .rd_idix_p3                     (rd_idix_p3                     ),
    .rs_idix_p3                     (rs_idix_p3                     ),
    .rt_idix_p3                     (rt_idix_p3                     ),
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
    .rotate_shift_right_idix_p3     (rotate_shift_right_idix_p3     ),
    .dest_reg_idix_p3               (dest_reg_idix_p3               ),
    .reg_write_valid_idix_p3        (reg_write_valid_idix_p3        ),
    .store_valid_idix_p3            (store_valid_idix_p3            ),
    .curr_inst_idix_p3              (curr_inst_idix_p3              )
);

execute u_execute(
    // Inputs
    .clk                            (clk                   ),
    .rst                            (rst                   ),
    .pc_p3                          (pc_p3                 ),
    .inst_idix_p3                   (inst_idix_p3          ),
    .rs_idix_p3                     (rs_idix_p3            ),
    .rt_idix_p3                     (rt_idix_p3            ),
    .rd_idix_p3                     (rd_idix_p3            ),
    .uop_cnt_idix_p3                (uop_cnt_idix_p3       ),
    .execute_valid_idix_p3          (execute_valid_idix_p3 ),
    .ldst_valid_idix_p3             (ldst_valid_idix_p3    ),
    .store_valid_idix_p3            (store_valid_idix_p3   ),
    .jmp_idix_p3                    (jmp_idix_p3           ),
    .branch_idix_p3                 (branch_idix_p3        ),
    .opcode_idix_p3                 (opcode_idix_p3        ),
    .rotate_shift_right_idix_p3     (rotate_shift_right_idix_p3),
    .dest_reg_idix_p3               (dest_reg_idix_p3               ),
    .reg_write_valid_idix_p3        (reg_write_valid_idix_p3        ),
    .jmp_displacement_idix_p3       (jmp_displacement_idix_p3       ),
    .nxt_pc_p3                      (nxt_pc_p3            ),

    // Outputs
    .pc_p4                          (pc_p4                         ),
    .dest_reg_value_ixmem_p4        (dest_reg_value_ixmem_p4       ),            
    .dest_reg_index_ixmem_p4        (dest_reg_index_ixmem_p4       ),
    .dest_reg_write_valid_ixmem_p4  (dest_reg_write_valid_ixmem_p4 ),
    .mem_addr_ixmem_p4              (mem_addr_ixmem_p4             ),
    .ldst_valid_ixmem_p4            (ldst_valid_ixmem_p4           ),
    .store_valid_ixmem_p4           (store_valid_ixmem_p4          ),
    .mem_data_in_ixmem_p4           (mem_data_in_ixmem_p4          ),
    .branch_taken_ixif_p3           (branch_taken_ixif_p3          ),
    .branch_target_ixif_p3          (branch_target_ixif_p3         )
);

mem u_mem (
    // Inputs
    .clk                            (clk),
    .rst                            (rst),
    .pc_p4                          (pc_p4),
    .mem_addr_ixmem_p4              (mem_addr_ixmem_p4),
    .mem_data_in_ixmem_p4           (mem_data_in_ixmem_p4),
    .ldst_valid_ixmem_p4            (ldst_valid_ixmem_p4),
    .store_valid_ixmem_p4           (store_valid_ixmem_p4),
    .dest_reg_value_ixmem_p4        (dest_reg_value_ixmem_p4),
    .dest_reg_index_ixmem_p4        (dest_reg_index_ixmem_p4),
    .dest_reg_write_valid_ixmem_p4  (dest_reg_write_valid_ixmem_p4),

    // Outputs
    .pc_p5                          (pc_p5),
    .err_p4                         (err_p4),
    .dest_reg_value_memwb_p5        (dest_reg_value_memwb_p5),
    .dest_reg_index_memwb_p5        (dest_reg_index_memwb_p5),
    .dest_reg_write_valid_memwb_p5  (dest_reg_write_valid_memwb_p5) 
);

endmodule