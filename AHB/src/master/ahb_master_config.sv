`ifndef AHB_MASTER_CONFIG_INCLUDE_
`define AHB_MASTER_CONFIG_INCLUDE_
class ahb_master_config extends uvm_object;
    `uvm_object_utils(ahb_master_config)
    uvm_active_passive_enum is_active=UVM_ACTIVE;
    bit has_coverage = 1;
    bit has_convert_waitstate = 0;
    extern function new(string name="ahb_master_config");
    extern function void do_print(uvm_printer printer);
endclass : ahb_master_config
function ahb_master_config::new(string name="ahb_master_config");
    super.new(name);
endfunction : new
function void ahb_master_config::do_print(uvm_printer printer);
    super.do_print(printer);
     printer.print_string ("is_active",is_active.name());
    printer.print_field ("has_coverage",  has_coverage, $bits(has_coverage),  UVM_BIN);
    printer.print_field("has_convert_waitstate",has_convert_waitstate,$bits(has_convert_waitstate),UVM_BIN);
endfunction : do_print
`endif