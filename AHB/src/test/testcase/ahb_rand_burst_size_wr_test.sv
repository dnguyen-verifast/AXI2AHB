`ifndef AHB_RAND_BURST_SIZE_WR_TEST_INCLUDE_
`define AHB_RAND_BURST_SIZE_WR_TEST_INCLUDE_

class ahb_rand_burst_size_wr_test extends ahb_test_base;
    `uvm_component_utils(ahb_rand_burst_size_wr_test)

    ahb_virtual_rand_burst_size_wr_seq ahb_virtual_rand_burst_size_wr_seq_h;

    extern function new(string name = "ahb_rand_burst_size_wr_test", uvm_component parent = null);
    extern virtual task run_phase(uvm_phase phase);
endclass : ahb_rand_burst_size_wr_test

function ahb_rand_burst_size_wr_test::new(string name = "ahb_rand_burst_size_wr_test",
                                          uvm_component parent = null);
  super.new(name, parent);
endfunction : new

task ahb_rand_burst_size_wr_test::run_phase(uvm_phase phase);
  ahb_virtual_rand_burst_size_wr_seq_h= ahb_virtual_rand_burst_size_wr_seq::type_id::create("ahb_virtual_rand_burst_size_wr_seq_h");
  `uvm_info(get_type_name(),$sformatf("ahb_rand_burst_size_wr_test"),UVM_LOW);
  phase.raise_objection(this);
  ahb_virtual_rand_burst_size_wr_seq_h.start(ahb_env_h.ahb_virtual_seqr_h);
  phase.drop_objection(this);
endtask : run_phase

`endif
