`ifndef x2h_NON_BLOCKING_64B_DATA_READ_TEST_INCLUDED_
`define x2h_NON_BLOCKING_64B_DATA_READ_TEST_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_64b_data_read_test
// Extends the base test and starts the virtual sequenceof write
//--------------------------------------------------------------------------------------------
class x2h_non_blocking_64b_data_read_test extends x2h_base_test;
  `uvm_component_utils(x2h_non_blocking_64b_data_read_test)

  //Variable : x2h_virtual_write_seq_h
  //Instatiation of x2h_virtual_write_seq
  x2h_virtual_nbk_64b_data_read_seq x2h_virtual_nbk_64b_data_read_seq_h;
  
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_non_blocking_64b_data_read_test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : x2h_non_blocking_64b_data_read_test

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - x2h_64b_data_read_test
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function x2h_non_blocking_64b_data_read_test::new(string name = "x2h_non_blocking_64b_data_read_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: run_phase
// Creates the x2h_virtual_write_data_read_seq sequence and starts the write virtual sequences
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task x2h_non_blocking_64b_data_read_test::run_phase(uvm_phase phase);

  x2h_virtual_nbk_64b_data_read_seq_h=x2h_virtual_nbk_64b_data_read_seq::type_id::create("x2h_virtual_nbk_64b_data_read_seq_h");
  `uvm_info(get_type_name(),$sformatf("x2h_non_blocking_64b_data_read_test"),UVM_LOW);
  phase.raise_objection(this);
  x2h_virtual_nbk_64b_data_read_seq_h.start(x2h_env_h.x2h_virtual_seqr_h);
  phase.drop_objection(this);

endtask : run_phase

`endif

