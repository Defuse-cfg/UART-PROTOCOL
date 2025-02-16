
if [file exists "work"] {vdel -all}
vlib work
vlog *.sv +acc
vsim uart_tb -voptargs="+cover=bcesf"

add wave -r /*

run -all