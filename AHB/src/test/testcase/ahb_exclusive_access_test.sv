`ifndef AHB_EXCLUSIVE_ACCESS_TEST_INCLUDE_
`define AHB_EXCLUSIVE_ACCESS_TEST_INCLUDE_
class ahb_exclusive_access_test extends ahb_test_base;
    `uvm_component_utils(ahb_exclusive_access_test)

    ahb_virtual_exclusive_access_seq ahb_virtual_exclusive_access_seq_h;

    extern function new(string name = "ahb_exclusive_access_test", uvm_component parent = null);
    extern virtual task run_phase(uvm_phase phase);
endclass : ahb_exclusive_access_test

function ahb_exclusive_access_test::new(string name = "ahb_exclusive_access_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

task ahb_exclusive_access_test::run_phase(uvm_phase phase);
  ahb_virtual_exclusive_access_seq_h= ahb_virtual_exclusive_access_seq::type_id::create("ahb_virtual_exclusive_access_seq_h");
  `uvm_info(get_type_name(),$sformatf("ahb_exclusive_access_test"),UVM_LOW);
  phase.raise_objection(this);
  ahb_virtual_exclusive_access_seq_h.start(ahb_env_h.ahb_virtual_seqr_h);
  phase.drop_objection(this);
endtask : run_phase
`endif
