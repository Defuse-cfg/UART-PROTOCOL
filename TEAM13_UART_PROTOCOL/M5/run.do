if [file exists "work"] {vdel -all}
vlib work

# Compiling the RTL & Testbench Files
vlog -source -sv UART_design.sv tb.sv 

vopt tb -o tb_Opt +acc +cover=sbfec
vsim tb_Opt -coverage +UVM_TESTNAME="test"
vcd file tb.vcd
vcd add -r tb/*

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all

coverage save tb.ucdb
quit -sim