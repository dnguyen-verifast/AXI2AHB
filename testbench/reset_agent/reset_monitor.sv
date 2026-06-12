`ifndef reset_monitor_INCLUDE_
`define reset_monitor_INCLUDE_

class reset_monitor extends uvm_monitor;
    `uvm_component_utils(reset_monitor)

    virtual reset_if reset_if_h;
    extern function new(string name = "reset_monitor", uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

endclass : reset_monitor

function reset_monitor::new(string name = "reset_monitor", uvm_component parent =null);
    super.new(name, parent);
endfunction : new

function void reset_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual reset_if)::get(this,"","rst_vif",reset_if_h)) begin
        `uvm_fatal("MONITOR_slave","Dont get interface reset_if_h");
    end
endfunction :build_phase

function void reset_monitor::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase

function void reset_monitor::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase

task reset_monitor::run_phase(uvm_phase phase);
    uvm_event reset_ev = uvm_event_pool::get_global("RESET_EVENT");
    forever begin
        @(negedge reset_if_h.rst_n);
        @(posedge reset_if_h.clk); 
        reset_ev.trigger();
        @(posedge reset_if_h.rst_n);
    end
endtask : run_phase

`endif