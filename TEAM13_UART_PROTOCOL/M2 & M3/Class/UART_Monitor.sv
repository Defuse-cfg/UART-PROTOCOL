
// UART Input Monitor Class
class uart_input_monitor;
    virtual uart_if vif;

    function new(virtual uart_if vif_input);
        vif = vif_input;
    endfunction

    task monitor();
        if (vif.valid) begin
            $display("[iMon] - Input Monitor: Burst ID = %0d, Data = 8'h%h", vif.burst_id, vif.data_in);
        end
    endtask
endclass

// UART Output Monitor Class
class uart_output_monitor;
    virtual uart_if vif;

    function new(virtual uart_if vif_input);
        vif = vif_input;
    endfunction

    task monitor();
        @(posedge vif.clk);
        if (vif.valid) begin
            $display("[oMon] - Output Monitor: Burst ID = %0d, Data = 8'h%h", vif.burst_id, vif.data_out);
        end
    endtask
endclass