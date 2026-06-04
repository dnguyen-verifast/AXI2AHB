`ifndef AHB_BASIC_SINGLE_R_TEST_INCLUDE_
`define AHB_BASIC_SINGLE_R_TEST_INCLUDE_

class ahb_basic_single_r_test extends ahb_test_base;
    `uvm_component_utils(ahb_basic_single_r_test)

    ahb_virtual_basic_single_r_seq ahb_virtual_basic_single_r_seq_h;

    extern function new(string name = "ahb_basic_single_r_test", uvm_component parent = null);
    extern virtual task run_phase(uvm_phase phase);
endclass : ahb_basic_single_r_test

function ahb_basic_single_r_test::new(string name = "ahb_basic_single_r_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

task ahb_basic_single_r_test::run_phase(uvm_phase phase);
  ahb_virtual_basic_single_r_seq_h = ahb_virtual_basic_single_r_seq::type_id::create("ahb_virtual_basic_single_r_seq_h");
  `uvm_info(get_type_name(),$sformatf("ahb_basic_single_r_test"),UVM_LOW);
  phase.raise_objection(this);
  ahb_virtual_basic_single_r_seq_h.start(ahb_env_h.ahb_virtual_seqr_h);
  phase.drop_objection(this);
endtask : run_phase

`endif
