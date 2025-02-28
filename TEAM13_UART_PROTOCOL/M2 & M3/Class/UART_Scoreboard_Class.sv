import trans::*;

class uart_scoreboard;
    virtual uart_if vif;

    function new(virtual uart_if vif_input);
        vif = vif_input;
    endfunction

    task check_match (input transaction_t expected);
        @(posedge vif.clk);
        #5; // Allow small delay to ensure stable output
        if (expected.data == vif.data_out && expected.burst_id == vif.burst_id) begin
            $display("[SCB] - Match: Burst ID = %0d, Data = 8'h%h", expected.burst_id, expected.data);
        end
       else begin
            $display("[SCB] - Mismatch: Expected Burst ID = %0d, Data = 8'h%h | Got Burst ID = %0d, Data = 8'h%h", expected.burst_id, expected.data, vif.burst_id,                   vif.data_out);
        end
    endtask
endclass