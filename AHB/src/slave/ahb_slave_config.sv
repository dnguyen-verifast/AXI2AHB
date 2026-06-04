`ifndef AHB_SLAVE_CONFIG_INCLUDE_
`define AHB_SLAVE_CONFIG_INCLUDE_
class ahb_slave_config extends uvm_object;
    `uvm_object_utils(ahb_slave_config)
    uvm_active_passive_enum is_active=UVM_ACTIVE;
    bit has_coverage = 1;
    response_mode_e slave_response_mode = RANDOM_RESP;

    extern function new(string name="ahb_slave_config");
    extern function void do_print(uvm_printer printer);
endclass : ahb_slave_config
function ahb_slave_config::new(string name="ahb_slave_config");
    super.new(name);
endfunction : new
function void ahb_slave_config::do_print(uvm_printer printer);
    super.do_print(printer);
     printer.print_string ("is_active",is_active.name());
    printer.print_field ("has_coverage",  has_coverage, $bits(has_coverage),  UVM_BIN);
    printer.print_string("slave_response_mode",slave_response_mode.name());
endfunction : do_print
`endif