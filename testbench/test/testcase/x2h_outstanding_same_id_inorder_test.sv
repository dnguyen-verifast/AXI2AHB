`ifndef x2h_OUTSTANDING_SAME_ID_INORDER_TEST_INCLUDED_
`define x2h_OUTSTANDING_SAME_ID_INORDER_TEST_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_outstanding_same_id_inorder_test
// Extends the base test and starts the virtual sequence for the same-ID in-order scenario
//--------------------------------------------------------------------------------------------
class x2h_outstanding_same_id_inorder_test extends x2h_base_test;
  `uvm_component_utils(x2h_outstanding_same_id_inorder_test)

  //Variable : x2h_virtual_bk_outstanding_same_id_inorder_seq_h
  //Instantiation of x2h_virtual_bk_outstanding_same_id_inorder_seq
  x2h_virtual_bk_outstanding_same_id_inorder_seq x2h_virtual_bk_outstanding_same_id_inorder_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_outstanding_same_id_inorder_test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : x2h_outstanding_same_id_inorder_test

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - x2h_outstanding_same_id_inorder_test
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function x2h_outstanding_same_id_inorder_test::new(string name = "x2h_outstanding_same_id_inorder_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: run_phase
// Creates and starts the x2h_virtual_bk_outstanding_same_id_inorder_seq virtual sequence
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task x2h_outstanding_same_id_inorder_test::run_phase(uvm_phase phase);

  x2h_virtual_bk_outstanding_same_id_inorder_seq_h = x2h_virtual_bk_outstanding_same_id_inorder_seq::type_id::create("x2h_virtual_bk_outstanding_same_id_inorder_seq_h");
  `uvm_info(get_type_name(),$sformatf("x2h_outstanding_same_id_inorder_test"),UVM_LOW);
  phase.raise_objection(this);
  x2h_virtual_bk_outstanding_same_id_inorder_seq_h.start(x2h_env_h.x2h_virtual_sequencer_h);
  phase.drop_objection(this);

endtask : run_phase

`endif
