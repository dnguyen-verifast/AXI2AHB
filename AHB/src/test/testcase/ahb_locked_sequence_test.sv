`ifndef AHB_LOCKED_SEQUENCE_TEST_INCLUDE_
`define AHB_LOCKED_SEQUENCE_TEST_INCLUDE_
class ahb_locked_sequence_test extends ahb_test_base;
    `uvm_component_utils(ahb_locked_sequence_test)

    ahb_virtual_locked_sequence_seq ahb_virtual_locked_sequence_seq_h;

    extern function new(string name = "ahb_locked_sequence_test", uvm_component parent = null);
    extern virtual task run_phase(uvm_phase phase);
endclass : ahb_locked_sequence_test

function ahb_locked_sequence_test::new(string name = "ahb_locked_sequence_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

task ahb_locked_sequence_test::run_phase(uvm_phase phase);
  ahb_virtual_locked_sequence_seq_h= ahb_virtual_locked_sequence_seq::type_id::create("ahb_virtual_locked_sequence_seq_h");
  `uvm_info(get_type_name(),$sformatf("ahb_locked_sequence_test"),UVM_LOW);
  phase.raise_objection(this);
  ahb_virtual_locked_sequence_seq_h.start(ahb_env_h.ahb_virtual_seqr_h);
  phase.drop_objection(this);
endtask : run_phase
`endif
