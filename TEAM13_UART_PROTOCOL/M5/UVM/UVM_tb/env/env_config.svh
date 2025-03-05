`ifndef env_config_exists
`define env_config_exists

`include "uvm_macros.svh" // Include UVM macros for all UVM features
import uvm_pkg::*;         // Import the UVM package
import uart_class_package::*;


class env_config extends uvm_object;

  `uvm_object_utils(env_config)
  function new(string name="env_config");
    super.new(name);
  endfunction: new

  tx_agent_config tx_agent_cfg;
  bit enable_scoreboard = 1;

endclass: env_config
`endif