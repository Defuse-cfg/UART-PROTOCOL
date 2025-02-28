// UART Driver Class
import trans::*;

class uart_driver;
    virtual uart_if vif;

    function new(virtual uart_if vif_input);
      begin
        vif = vif_input;
      end
    endfunction

    task drive(input transaction_t txn);
     begin
        vif.burst_id = txn.burst_id;
        vif.data_in = txn.data;
        vif.valid = txn.valid;
        $display("[DRIVER] - Driving transaction: Burst ID = %0d, Data = 8'h%h", txn.burst_id, txn.data);
        @(posedge vif.clk); // Ensure DUT processes
    end 
    endtask
endclass