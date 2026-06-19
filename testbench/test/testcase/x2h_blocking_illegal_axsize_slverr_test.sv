`ifndef x2h_BLOCKING_ILLEGAL_AXSIZE_SLVERR_TEST_INCLUDED_
`define x2h_BLOCKING_ILLEGAL_AXSIZE_SLVERR_TEST_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_blocking_illegal_axsize_slverr_test
// Extends the base test and starts the virtual sequence for the illegal AXSIZE SLVERR scenario
//--------------------------------------------------------------------------------------------
class x2h_blocking_illegal_axsize_slverr_test extends x2h_base_test;
  `uvm_component_utils(x2h_blocking_illegal_axsize_slverr_test)

  //Variable : x2h_virtual_bk_illegal_axsize_slverr_seq_h
  //Instantiation of x2h_virtual_bk_illegal_axsize_slverr_seq
  x2h_virtual_bk_illegal_axsize_slverr_seq x2h_virtual_bk_illegal_axsize_slverr_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_blocking_illegal_axsize_slverr_test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : x2h_blocking_illegal_axsize_slverr_test

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - x2h_blocking_illegal_axsize_slverr_test
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function x2h_blocking_illegal_axsize_slverr_test::new(string name = "x2h_blocking_illegal_axsize_slverr_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: run_phase
// Creates and starts the x2h_virtual_bk_illegal_axsize_slverr_seq virtual sequence
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task x2h_blocking_illegal_axsize_slverr_test::run_phase(uvm_phase phase);

  x2h_virtual_bk_illegal_axsize_slverr_seq_h = x2h_virtual_bk_illegal_axsize_slverr_seq::type_id::create("x2h_virtual_bk_illegal_axsize_slverr_seq_h");
  `uvm_info(get_type_name(),$sformatf("x2h_blocking_illegal_axsize_slverr_test"),UVM_LOW);
  phase.raise_objection(this);
  x2h_virtual_bk_illegal_axsize_slverr_seq_h.start(x2h_env_h.x2h_virtual_sequencer_h);
  phase.drop_objection(this);

endtask : run_phase

`endif
