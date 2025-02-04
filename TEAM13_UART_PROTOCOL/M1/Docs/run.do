vlog -source uart_tb.sv
vlog -source uart.sv
vsim -novopt work.uart_tb

add wave -r /*
run -all

quit
