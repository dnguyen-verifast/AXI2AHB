`ifndef AHB_ENV_CONFIG_INCLUDE_
`define AHB_ENV_CONFIG_INCLUDE_

class ahb_env_config extends uvm_object;
    `uvm_object_utils(ahb_env_config)
    bit has_scoreboard = 1;
    bit has_virtual_seqr = 1;
    int no_of_slaves = 1;
    int no_of_masters = 1;

    ahb_slave_config ahb_slave_config_h [];
    ahb_master_config ahb_master_config_h [];

    extern function new(string name = "ahb_env_config");
    extern function void do_print(uvm_printer printer);
endclass : ahb_env_config

function ahb_env_config::new(string name = "ahb_env_config");
  super.new(name);
endfunction : new

function void ahb_env_config::do_print(uvm_printer printer);
  super.do_print(printer);
  
  printer.print_field ("has_scoreboard",has_scoreboard,1, UVM_DEC);
  printer.print_field ("has_virtual_sqr",has_virtual_seqr,1, UVM_DEC);
  printer.print_field ("no_of_masters",no_of_masters,$bits(no_of_masters), UVM_HEX);
  printer.print_field ("no_of_slaves",no_of_slaves,$bits(no_of_slaves), UVM_HEX);
endfunction : do_print
`endif