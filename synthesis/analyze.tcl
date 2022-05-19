lappend search_path "../src/"

analyze -library work -format sverilog -define SYNTH \
{   ../src/top.sv \
    ../src/fetch/fetch.sv \
    ../src/fetch/if_mem.sv \
    ../src/decode/decode.sv \
    ../src/execute/execute.sv \
    ../src/execute/alu.sv \
    ../src/execute/regfile.sv \
    ../src/execute/barrel_shift_rotate.sv
}