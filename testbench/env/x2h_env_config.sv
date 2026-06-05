`ifndef X2H_ENV_CONFIG_INCLUDE_
`define X2H_ENV_CONFIG_INCLUDE_

class x2h_env_config extends uvm_object;
    `uvm_object_utils(x2h_env_config)
    bit has_scoreboard_ahb = 0;
    bit has_virtual_seqr_ahb = 0;
    int no_of_slaves_ahb = 1;
    int no_of_masters_ahb = 0;

    bit has_scoreboard_axi = 0;
    bit has_virtual_seqr_axi = 0;
    int no_of_slaves_axi = 0;
    int no_of_masters_axi = 1;


    extern function new(string name = "x2h_env_config");
    extern function void do_print(uvm_printer printer);
endclass : x2h_env_config

function x2h_env_config::new(string name = "x2h_env_config");
  super.new(name);
endfunction : new

function void x2h_env_config::do_print(uvm_printer printer);
  super.do_print(printer);
  printer.print_field ("has_scoreboard_ahb",has_scoreboard_ahb,1, UVM_DEC);
  printer.print_field ("has_virtual_seqr_ahb",has_virtual_seqr_ahb,1, UVM_DEC);
  printer.print_field ("no_of_slaves_ahb",no_of_slaves_ahb,$bits(no_of_slaves_ahb), UVM_HEX);
  printer.print_field ("no_of_masters_ahb",no_of_masters_ahb,$bits(no_of_masters_ahb), UVM_HEX);
  printer.print_field ("has_scoreboard_axi",has_scoreboard_axi,1, UVM_DEC);
  printer.print_field ("has_virtual_seqr_axi",has_virtual_seqr_axi,1, UVM_DEC);
  printer.print_field ("no_of_slaves_axi",no_of_slaves_axi,$bits(no_of_slaves_axi), UVM_HEX);
  printer.print_field ("no_of_masters_axi",no_of_masters_axi,$bits(no_of_masters_axi), UVM_HEX);
endfunction : do_print
`endif