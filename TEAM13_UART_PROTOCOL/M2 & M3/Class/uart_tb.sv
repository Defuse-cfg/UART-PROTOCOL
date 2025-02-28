`include "UART_Interface.sv"
`include "UART_Monitor.sv"
`include "UART_Generator_Class.sv"
`include "UART_Driver_Class.sv"
`include "UART_Scoreboard_Class.sv"
`include "UART_Coverage_Class.sv"

// Define Transaction Structure
import trans::*;
module uart_tb;
    uart_if vif(); // Instantiate Interface

    // Instantiate Testbench Components
    uart_generator gen;
    uart_driver drv;
    uart_input_monitor imon;
    uart_output_monitor omon;
    uart_scoreboard scb;
    uart_coverage cov; // Coverage class instance

    // Clock Generation
    always #5 vif.clk = ~vif.clk;

    initial begin
        gen = new(vif);
        drv = new(vif);
        imon = new(vif);
        omon = new(vif);
        scb = new(vif);
        cov = new(vif); // Pass vif to coverage

        // Initialize Signals
        vif.clk = 0;
        vif.reset = 1;
        vif.valid = 0;
        vif.burst_id = 0;
        vif.data_in = 0;
        vif.data_out = 0;

        #10 vif.reset = 0; // Release reset

        $display("[TESTBENCH] - Starting Simulation...");
        
        // Start collecting coverage
       

      repeat (500) begin
            transaction_t txn;
            gen.generate_transaction(txn);
            drv.drive(txn);
            @(posedge vif.clk);
            imon.monitor();
            omon.monitor();
            scb.check_match(txn);
            #10;
        end

        // Display Functional Coverage Results
        cov.report_coverage();

        $display("Test completed.");
        $finish;
    end

    // Dump waveform for debugging
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars;
    end
endmodule
