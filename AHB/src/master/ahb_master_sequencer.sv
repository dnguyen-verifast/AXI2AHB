`ifndef AHB_MASTER_SEQUENCER_INLCUDE_
`define AHB_MASTER_SEQUENCER_INLCUDE_

class ahb_master_sequencer extends uvm_sequencer#(ahb_master_tx);
    `uvm_component_utils(ahb_master_sequencer)

    uvm_analysis_port#(ahb_master_tx) seq_expect_item_port;
    uvm_analysis_port#(ahb_master_tx) seq_expect_write_item_port;

extern function new(string name = "ahb_master_sequencer", uvm_component parent =null);
extern virtual function void build_phase(uvm_phase phase);
extern virtual function void connect_phase(uvm_phase phase);
extern virtual function void end_of_elaboration_phase(uvm_phase phase);
extern virtual function void start_of_simulation_phase (uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
endclass : ahb_master_sequencer
function ahb_master_sequencer::new(string name = "ahb_master_sequencer", uvm_component parent =null);
    super.new(name,parent);
    seq_expect_item_port = new("seq_expect_item_port",this);
    seq_expect_write_item_port = new("seq_expect_write_item_port",this);
endfunction : new
function void ahb_master_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase
function void ahb_master_sequencer::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase
function void ahb_master_sequencer::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase
function void ahb_master_sequencer::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase
task ahb_master_sequencer::run_phase(uvm_phase phase);

endtask : run_phase
`endif