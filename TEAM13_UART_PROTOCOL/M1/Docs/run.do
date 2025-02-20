
if [file exists "work"] {vdel -all}
vlib work
vlog *.sv +acc
vsim uart_tb -voptargs="+cover=bcesf"

add wave -r /*

vsim -coverage uart_top -voptargs="+cover=bcesfx"
vlog -cover bcst uart.sv
vsim -coverage uart_top -do "run -all; exit"
run -all
coverage report -code bcesft
coverage report -assert -binrhs -details -cvg
vcover report -html coverage_results
coverage report -codeAll
