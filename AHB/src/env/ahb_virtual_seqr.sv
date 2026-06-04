`ifndef AHB_VIRTUAL_SEQR_INCLUDE_
`define AHB_VIRTUAL_SEQR_INCLUDE_

class ahb_virtual_seqr extends uvm_sequencer;
    `uvm_component_utils(ahb_virtual_seqr)
    
    ahb_master_sequencer ahb_master_sequencer_h;
    ahb_slave_sequencer ahb_slave_sequencer_h;


    extern function new(string name ="ahb_virtual_seqr", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
endclass

function ahb_virtual_seqr::new(string name = "ahb_virtual_seqr",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void ahb_virtual_seqr::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

function void ahb_virtual_seqr::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase

function void ahb_virtual_seqr::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
endfunction  : end_of_elaboration_phase

function void ahb_virtual_seqr::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase

task ahb_virtual_seqr::run_phase(uvm_phase phase);

endtask : run_phase

`endif