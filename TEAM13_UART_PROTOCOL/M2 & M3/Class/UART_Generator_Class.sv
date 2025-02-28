// UART Generator Class
import trans::*;
class uart_generator;
    virtual uart_if vif;

    function new(virtual uart_if vif_input);
        vif = vif_input;
    endfunction

    task generate_transaction(output transaction_t txn);
      txn.burst_id = $urandom_range(1, 100);
        txn.data = $urandom_range(0, 255);
        txn.valid = 1;
        $display("[GENERATOR] - Generated transaction: Burst ID = %0d, Data = 8'h%h", txn.burst_id, txn.data);
    endtask
endclass