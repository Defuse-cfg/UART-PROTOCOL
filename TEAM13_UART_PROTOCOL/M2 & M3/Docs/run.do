vdel -all

vlog -source -lint uart.sv
vlog -source -lint tb.sv


vsim  uart_top


vsim -coverage uart_top -voptargs="+cover=bcesfx"
vlog -cover bcst uart.sv
vsim -coverage uart_top -do "run -all; exit"
run -all
coverage report -code bcesft
coverage report -assert -binrhs -details -cvg
vcover report -html coverage_results
coverage report -codeAll