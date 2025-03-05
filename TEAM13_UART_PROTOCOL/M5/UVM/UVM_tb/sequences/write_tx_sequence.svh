`ifndef write_TX_SEQUENCE_exists
`define write_TX_SEQUENCE_exists

`include "uvm_macros.svh"  // Include UVM macros before using any UVM macros
import uvm_pkg::*;         // Import UVM package
import uart_class_package::*;  // Import package containing tx_base


class write_tx_sequence extends uvm_sequence #(tx_in);

  `uvm_object_utils(write_tx_sequence)
  function new (string name = "write_tx_sequence");
    super.new (name);
  endfunction 

  task body();

  tx_in tx;  
  
  repeat(270) begin
      tx = tx_in::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize()) `uvm_fatal(get_type_name(), "tx_in::randomize failed")
      finish_item(tx);
  end

  endtask: body 

endclass: write_tx_sequence 
`endif