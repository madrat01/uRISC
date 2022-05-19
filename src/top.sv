module top (
    // Inputs
    input logic             clk,
    input logic             rst,

    // Outputs
    output logic            err_p1
);

logic [15:0]    pc_p1;
logic [15:0]    epc_p1;
logic [15:0]    inst_ifid_p1;

logic [15:0]    inst_idix_p1;
logic [2:0]     rd_idix_p1;
logic [2:0]     rs_idix_p1;
logic [2:0]     rt_idix_p1;
logic           ldst_valid_idix_p1;
logic           ldst_valid_idmem_p1;
logic           halt_idif_p1;
logic           nop_idif_p1;
logic           illegal_op_idif_p1;
logic           return_execution_idif_p1;
logic           jmp_idix_p1;
logic           branch_idix_p1;
logic           jmp_displacement_idif_p1;
logic [15:0]    jmp_displacement_value_idif_p1;
logic [4:0]     opcode_idix_p1;
logic           execute_valid_idix_p1;
logic [25:0]    uop_cnt_idix_p1;
logic [25:0]    uop_cnt_ixmem_p1;
logic           rotate_shift_right_idix_p1;

fetch u_fetch
(
    // Inputs
    .clk                        (clk),
    .rst                        (rst),

    // Outputs
    .pc_p1                      (pc_p1),
    .inst_ifid_p1               (inst_ifid_p1),
    .err_p1                     (err_p1)
);

decode u_decode(
    // Inputs
    .clk                            (clk                            ),
    .rst                            (rst                            ),
    .pc_p1                          (pc_p1                          ),
    .inst_ifid_p1                   (inst_ifid_p1                   ),
    .epc_p1                         (epc_p1                         ),

    // Outputs
    .inst_idix_p1                   (inst_idix_p1                   ),
    .rd_idix_p1                     (rd_idix_p1                     ),
    .rs_idix_p1                     (rs_idix_p1                     ),
    .rt_idix_p1                     (rt_idix_p1                     ),
    .ldst_valid_idix_p1             (ldst_valid_idix_p1             ),
    .ldst_valid_idmem_p1            (ldst_valid_idmem_p1            ),
    .halt_idif_p1                   (halt_idif_p1                   ),
    .nop_idif_p1                    (nop_idif_p1                    ),
    .illegal_op_idif_p1             (illegal_op_idif_p1             ),
    .return_execution_idif_p1       (return_execution_idif_p1       ),
    .jmp_idix_p1                    (jmp_idix_p1                    ),
    .branch_idix_p1                 (branch_idix_p1                 ),
    .jmp_displacement_idif_p1       (jmp_displacement_idif_p1       ),
    .jmp_displacement_value_idif_p1 (jmp_displacement_value_idif_p1 ),
    .opcode_idix_p1                 (opcode_idix_p1                 ),
    .execute_valid_idix_p1          (execute_valid_idix_p1          ),
    .uop_cnt_idix_p1                (uop_cnt_idix_p1                ),
    .rotate_shift_right_idix_p1     (rotate_shift_right_idix_p1     )
);

execute u_execute(
    .clk                            (clk                   ),
    .rst                            (rst                   ),
    .pc_p1                          (pc_p1                 ),
    .inst_idix_p1                   (inst_idix_p1          ),
    .rs_idix_p1                     (rs_idix_p1            ),
    .rt_idix_p1                     (rt_idix_p1            ),
    .rd_idix_p1                     (rd_idix_p1            ),
    .uop_cnt_idix_p1                (uop_cnt_idix_p1       ),
    .execute_valid_idix_p1          (execute_valid_idix_p1 ),
    .ldst_valid_idix_p1             (ldst_valid_idix_p1    ),
    .jmp_idix_p1                    (jmp_idix_p1           ),
    .branch_idix_p1                 (branch_idix_p1        ),
    .opcode_idix_p1                 (opcode_idix_p1        ),
    .rotate_shift_right_idix_p1     (rotate_shift_right_idix_p1)
);

endmodule