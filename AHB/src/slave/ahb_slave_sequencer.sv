`ifndef AHB_SLAVE_SEQUENCER_INLCUDE_
`define AHB_SLAVE_SEQUENCER_INLCUDE_

class ahb_slave_sequencer extends uvm_sequencer#(ahb_slave_tx);
    `uvm_component_utils(ahb_slave_sequencer)
    uvm_analysis_port#(ahb_slave_tx) seq_expect_item_port;
extern function new(string name = "ahb_slave_sequencer", uvm_component parent =null);
extern virtual function void build_phase(uvm_phase phase);
extern virtual function void connect_phase(uvm_phase phase);
extern virtual function void end_of_elaboration_phase(uvm_phase phase);
extern virtual function void start_of_simulation_phase (uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
endclass : ahb_slave_sequencer
function ahb_slave_sequencer::new(string name = "ahb_slave_sequencer", uvm_component parent =null);
    super.new(name,parent);
    seq_expect_item_port = new("seq_expect_item_port",this);
endfunction : new
function void ahb_slave_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase
function void ahb_slave_sequencer::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase
function void ahb_slave_sequencer::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase
function void ahb_slave_sequencer::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase
task ahb_slave_sequencer::run_phase(uvm_phase phase);

endtask : run_phase
`endif