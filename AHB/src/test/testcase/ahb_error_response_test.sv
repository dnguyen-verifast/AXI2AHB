`ifndef AHB_ERROR_RESPONSE_TEST_INCLUDE_
`define AHB_ERROR_RESPONSE_TEST_INCLUDE_
class ahb_error_response_test extends ahb_test_base;
    `uvm_component_utils(ahb_error_response_test)

    ahb_virtual_error_response_seq ahb_virtual_error_response_seq_h;

    extern function new(string name = "ahb_error_response_test", uvm_component parent = null);
    extern virtual task run_phase(uvm_phase phase);
endclass : ahb_error_response_test

function ahb_error_response_test::new(string name = "ahb_error_response_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

task ahb_error_response_test::run_phase(uvm_phase phase);
  ahb_virtual_error_response_seq_h= ahb_virtual_error_response_seq::type_id::create("ahb_virtual_error_response_seq_h");
  `uvm_info(get_type_name(),$sformatf("ahb_error_response_test"),UVM_LOW);
  phase.raise_objection(this);
  ahb_virtual_error_response_seq_h.start(ahb_env_h.ahb_virtual_seqr_h);
  phase.drop_objection(this);
endtask : run_phase
`endif
