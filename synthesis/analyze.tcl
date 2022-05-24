lappend search_path "../src/"

analyze -library work -format sverilog -define SYNTH \
{   ../src/defines_pkg.sv \
    ../src/memory_ram.sv \
    ../src/fetch/fetch.sv \
    ../src/decode/uop_control.sv \
    ../src/decode/regfile.sv \
    ../src/decode/decode.sv \
    ../src/execute/barrel_shift_rotate.sv \
    ../src/execute/alu.sv \
    ../src/execute/execute.sv \
    ../src/mem/mem.sv \
    ../src/top.sv
}