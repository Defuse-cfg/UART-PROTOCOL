`ifndef TX_OUT_EXISTS
`define TX_OUT_EXISTS

`include "uvm_macros.svh" // Include UVM macros for all UVM features
import uvm_pkg::*;         // Import the UVM package
import uart_class_package::*;



class tx_out extends tx_base;

  `uvm_object_utils(tx_out)
  function new (string name = "tx_out");
    super.new(name);
  endfunction 

  bit i = 1'b1;

  virtual function void do_copy(uvm_object rhs);
    tx_out tx_rhs;
    if (!$cast(tx_rhs, rhs))
      `uvm_fatal("TX_CAST", "Illegal do_copy argument in tx_out")

    super.do_copy(rhs);
    o_RX_Byte = tx_rhs.o_RX_Byte;

  endfunction: do_copy

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    tx_out tx_rhs;
    if (!$cast(tx_rhs, rhs))
      `uvm_fatal("TX_CAST", "Illegal do_compare argument in tx_out")


    return (/*super.do_compare(rhs, comparer) &&*/
            (o_RX_Byte === tx_rhs.o_RX_Byte));

  endfunction : do_compare

  function string convert2string();
    string s;
    $sformat(s, "%s\n tx_out values (dec):", s);
    $sformat(s, "%s\n o_RX_Byte = %0d\n", s, o_RX_Byte);
    return s;
  endfunction: convert2string

  bit ignore_in_scoreboard = 0;

endclass: tx_out
`endif