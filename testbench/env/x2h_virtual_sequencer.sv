`ifndef x2h_virtual_sequencer_INCLUDED_
`define x2h_virtual_sequencer_INCLUDED_

//--------------------------------------------------------------------------------------------
// class: x2h_virtual_sequencer
// This class contains the handle of actual sequencer pointing towards them
//--------------------------------------------------------------------------------------------
class x2h_virtual_sequencer extends uvm_sequencer#(uvm_sequence_item);
  `uvm_component_utils(x2h_virtual_sequencer)

  // Variable: master_write_seqr_h
  // Declaring master write sequencer handle
  axi4_master_write_sequencer axi4_master_write_seqr_h;

  // Variable: master_read_seqr_h
  // Declaring master read sequencer handle
  axi4_master_read_sequencer axi4_master_read_seqr_h;
  
  // Variable: slave_write_seqr_h
  // Declaring slave write sequencer handle
  axi4_slave_write_sequencer axi4_slave_write_seqr_h;

  // Variable: slave_read_seqr_h
  // Declaring slave read sequencer handle
  axi4_slave_read_sequencer axi4_slave_read_seqr_h;

  reset_sequencer reset_sequencer_h;

  
  ahb_master_sequencer ahb_master_sequencer_h;
  ahb_slave_sequencer ahb_slave_sequencer_h;

  queue_info_ctrl_s queue_info_ctrl[$];
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_sequencer", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

endclass : x2h_virtual_sequencer

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - x2h_virtual_sequencer
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function x2h_virtual_sequencer::new(string name = "x2h_virtual_sequencer",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: build_phase
// creates the required ports
//
// Parameters:
//  phase - stores the current phase
//--------------------------------------------------------------------------------------------
function void x2h_virtual_sequencer::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

//--------------------------------------------------------------------------------------------
// Function: connect_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void x2h_virtual_sequencer::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase

//--------------------------------------------------------------------------------------------
// Function: end_of_elaboration_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void x2h_virtual_sequencer::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
endfunction  : end_of_elaboration_phase

//--------------------------------------------------------------------------------------------
// Function: start_of_simulation_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void x2h_virtual_sequencer::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase

//--------------------------------------------------------------------------------------------
// Task: run_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task x2h_virtual_sequencer::run_phase(uvm_phase phase);

  // Work here
  // ...

endtask : run_phase

`endif

