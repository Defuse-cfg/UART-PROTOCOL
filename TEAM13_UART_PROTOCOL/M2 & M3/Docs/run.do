vdel -all

vlog -source transaction.sv uart.sv uart_tb.sv


vsim -coverage uart_tb -voptargs="+cover=bcesfx"
run -all
coverage report -code bcesft
coverage report -assert -binrhs -details -cvg
vcover report -html coverage_results
coverage report -codeAll
