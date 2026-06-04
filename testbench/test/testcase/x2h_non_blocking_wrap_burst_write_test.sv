`ifndef x2h_NON_BLOCKING_WRAP_BURST_WRITE_TEST_INCLUDED_
`define x2h_NON_BLOCKING_WRAP_BURST_WRITE_TEST_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_non_blocking_wrap_burst_write_test
// Extends the base test and starts the virtual sequenceof write
//--------------------------------------------------------------------------------------------
class x2h_non_blocking_wrap_burst_write_test extends x2h_base_test;
  `uvm_component_utils(x2h_non_blocking_wrap_burst_write_test)

  //Variable : x2h_virtual_nbk_wrap_burst_write_seq_h
  //Instatiation of x2h_virtual_nbk_wrap_burst_write_seq
  x2h_virtual_nbk_wrap_burst_write_seq x2h_virtual_nbk_wrap_burst_write_seq_h;
  
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_non_blocking_wrap_burst_write_test", uvm_component parent = null);
	extern virtual function void setup_x2h_slave_agent_cfg();
  extern virtual task run_phase(uvm_phase phase);

endclass : x2h_non_blocking_wrap_burst_write_test

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - x2h_non_blocking_wrap_burst_write_test
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function x2h_non_blocking_wrap_burst_write_test::new(string name = "x2h_non_blocking_wrap_burst_write_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new


function void x2h_non_blocking_wrap_burst_write_test::setup_x2h_slave_agent_cfg();
	super.setup_x2h_slave_agent_cfg();
	foreach(x2h_env_cfg_h.x2h_slave_agent_cfg_h[i]) begin
		x2h_env_cfg_h.x2h_slave_agent_cfg_h[i].read_data_mode = SLAVE_MEM_MODE;
		`uvm_info(get_type_name(), $sformatf("read_data_mode %d  to slave set to SLAVE_MEN", i), UVM_LOW)
	end
endfunction : setup_x2h_slave_agent_cfg
//--------------------------------------------------------------------------------------------
// Task: run_phase
// Creates the x2h_virtual_wrap_burst_write_seq sequence and starts the write virtual sequences
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task x2h_non_blocking_wrap_burst_write_test::run_phase(uvm_phase phase);
//	foreach(x2h_env_cfg_h.x2h_slave_agent_cfg_h[i]) begin
//		x2h_env_cfg_h.x2h_slave_agent_cfg_h[i].read_data_mode = SLAVE_MEM_MODE;
//		`uvm_info(get_type_name(), $sformatf("read_data_mode %d  to slave set to SLAVE_MEN", i), UVM_LOW)
//	end

  x2h_virtual_nbk_wrap_burst_write_seq_h=x2h_virtual_nbk_wrap_burst_write_seq::type_id::create("x2h_virtual_nbk_wrap_burst_write_seq_h");
  `uvm_info(get_type_name(),$sformatf("x2h_non_blocking_wrap_burst_write_test"),UVM_LOW);
  phase.raise_objection(this);
  x2h_virtual_nbk_wrap_burst_write_seq_h.start(x2h_env_h.x2h_virtual_seqr_h);
  phase.drop_objection(this);

endtask : run_phase

`endif

