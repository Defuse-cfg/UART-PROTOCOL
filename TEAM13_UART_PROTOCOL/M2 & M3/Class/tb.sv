// Define Transaction Structure
typedef struct {
    int burst_id;
    logic [7:0] data;
    logic valid;
} transaction_t;

// UART Interface
interface uart_if;
    logic clk, reset;
    logic valid;
    logic [3:0] burst_id;
    logic [7:0] data_in, data_out;
endinterface

// UART Generator Class
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

// UART Driver Class
class uart_driver;
    virtual uart_if vif;

    function new(virtual uart_if vif_input);
        vif = vif_input;
    endfunction

    task drive(input transaction_t txn);
        vif.burst_id = txn.burst_id;
        vif.data_in = txn.data;
        vif.valid = txn.valid;
        $display("[DRIVER] - Driving transaction: Burst ID = %0d, Data = 8'h%h", txn.burst_id, txn.data);
        @(posedge vif.clk); // Ensure DUT processes
    endtask
endclass

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

// UART Scoreboard Class
class uart_scoreboard;
    virtual uart_if vif;

    function new(virtual uart_if vif_input);
        vif = vif_input;
    endfunction

    task check_match(input transaction_t expected);
        @(posedge vif.clk);
        #5; // Allow small delay to ensure stable output
        if (expected.data == vif.data_out && expected.burst_id == vif.burst_id) begin
            $display("[SCB] - Match: Burst ID = %0d, Data = 8'h%h", expected.burst_id, expected.data);
        end else begin
            $display("[SCB] - Mismatch: Expected Burst ID = %0d, Data = 8'h%h | Got Burst ID = %0d, Data = 8'h%h",
                      expected.burst_id, expected.data, vif.burst_id, vif.data_out);
        end
    endtask
endclass

// Functional Coverage Class
// Functional Coverage Class
class uart_coverage;
    virtual uart_if vif;

    covergroup burst_id_cg @(posedge vif.clk);
        coverpoint vif.burst_id;
    endgroup

    covergroup data_in_cg @(posedge vif.clk);
        coverpoint vif.data_in;
    endgroup

    covergroup data_out_cg @(posedge vif.clk);
        coverpoint vif.data_out;
    endgroup

    covergroup functional_cg @(posedge vif.clk);
        coverpoint vif.burst_id;
        coverpoint vif.data_in;
        coverpoint vif.valid;
        cross vif.burst_id, vif.data_in, vif.valid;
    endgroup

    function new(virtual uart_if vif_input);
        vif = vif_input;
        burst_id_cg = new();
        data_in_cg = new();
        data_out_cg = new();
        functional_cg = new();
    endfunction

    function void report_coverage();
        $display("--------------------------------------------------");
        $display("[COVERAGE] - Burst ID Coverage: %0.2f%%", burst_id_cg.get_coverage());
        $display("[COVERAGE] - Data In Coverage: %0.2f%%", data_in_cg.get_coverage());
        $display("[COVERAGE] - Data Out Coverage: %0.2f%%", data_out_cg.get_coverage());
        $display("[COVERAGE] - Functional Coverage: %0.2f%%", functional_cg.get_coverage());
        $display("--------------------------------------------------");
    endfunction
endclass

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