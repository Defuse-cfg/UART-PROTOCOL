// UART Interface
interface uart_if;
    logic clk, reset;
    logic valid;
    logic [3:0] burst_id;
    logic [7:0] data_in, data_out;
endinterface