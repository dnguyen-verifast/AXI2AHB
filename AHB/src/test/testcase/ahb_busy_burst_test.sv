`ifndef AHB_BUSY_BURST_TEST_INCLUDE_
`define AHB_BUSY_BURST_TEST_INCLUDE_
class ahb_busy_burst_test extends ahb_test_base;
    `uvm_component_utils(ahb_busy_burst_test)

    ahb_virtual_busy_burst_seq ahb_virtual_busy_burst_seq_h;

    extern function new(string name = "ahb_busy_burst_test", uvm_component parent = null);
    extern virtual task run_phase(uvm_phase phase);
endclass : ahb_busy_burst_test

function ahb_busy_burst_test::new(string name = "ahb_busy_burst_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

task ahb_busy_burst_test::run_phase(uvm_phase phase);
  ahb_virtual_busy_burst_seq_h= ahb_virtual_busy_burst_seq::type_id::create("ahb_virtual_busy_burst_seq_h");
  `uvm_info(get_type_name(),$sformatf("ahb_busy_burst_test"),UVM_LOW);
  phase.raise_objection(this);
  ahb_virtual_busy_burst_seq_h.start(ahb_env_h.ahb_virtual_seqr_h);
  phase.drop_objection(this);
endtask : run_phase
`endif
