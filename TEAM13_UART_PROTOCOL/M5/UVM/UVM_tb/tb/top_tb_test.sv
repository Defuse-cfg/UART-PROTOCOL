module top_tb_test;
timeunit 1ns; timeprecision 10ps;
  import uvm_pkg::*;               // Import UVM framework
  import uart_class_package::*;    // Import UART-specific package

  logic clk;                       // Clock signal declaration

  // Instantiate the tb_ifc interface
  tb_ifc tb_if (.clk(clk));

  // Instantiate the DUT (UART)
  UART dut (
    .clk(clk),
    .i_TX_Data_Valid(tb_if.i_TX_Data_Valid),
    .i_TX_Byte(tb_if.i_TX_Byte),
    .o_RX_Data_Valid(tb_if.o_RX_Data_Valid),
    .o_RX_Byte(tb_if.o_RX_Byte),
    .o_TX_Done(tb_if.o_TX_Done)
  );

  initial begin
    $timeformat(-9, 0, "ns", 6);   // Set time format for debugging

    // Generate clock signal
    clk <= 0;
    forever #20 clk = ~clk;
  end

  initial begin
    // Set the tb_ifc interface in the UVM configuration database
    uvm_config_db #(virtual tb_ifc)::set(null, "uvm_test_top", "tb_if", tb_if);

    // Start the UVM test via the +UVM_TESTNAME argument
    run_test();
  end

endmodule: top_tb_test
