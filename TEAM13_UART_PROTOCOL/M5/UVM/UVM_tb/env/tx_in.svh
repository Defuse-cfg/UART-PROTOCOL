`ifndef TX_IN_EXISTS
`define TX_IN_EXISTS

`include "uvm_macros.svh" // Include UVM macros for all UVM features
import uvm_pkg::*;         // Import the UVM package
import uart_class_package::*;

class tx_in extends tx_base;

  `uvm_object_utils(tx_in)

  function new (string name = "tx_in");
    super.new(name);
  endfunction

  constraint c_i_TX_Byte  {
    i_TX_Byte inside {[0:255]};
  }

endclass: tx_in

`endif
