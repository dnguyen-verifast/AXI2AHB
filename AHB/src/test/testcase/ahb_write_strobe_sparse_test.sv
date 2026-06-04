`ifndef AHB_WRITE_STROBE_SPARSE_TEST_INCLUDE_
`define AHB_WRITE_STROBE_SPARSE_TEST_INCLUDE_
class ahb_write_strobe_sparse_test extends ahb_test_base;
    `uvm_component_utils(ahb_write_strobe_sparse_test)

    ahb_virtual_write_strobe_sparse_seq ahb_virtual_write_strobe_sparse_seq_h;

    extern function new(string name = "ahb_write_strobe_sparse_test", uvm_component parent = null);
    extern virtual task run_phase(uvm_phase phase);
endclass : ahb_write_strobe_sparse_test

function ahb_write_strobe_sparse_test::new(string name = "ahb_write_strobe_sparse_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

task ahb_write_strobe_sparse_test::run_phase(uvm_phase phase);
  ahb_virtual_write_strobe_sparse_seq_h= ahb_virtual_write_strobe_sparse_seq::type_id::create("ahb_virtual_write_strobe_sparse_seq_h");
  `uvm_info(get_type_name(),$sformatf("ahb_write_strobe_sparse_test"),UVM_LOW);
  phase.raise_objection(this);
  ahb_virtual_write_strobe_sparse_seq_h.start(ahb_env_h.ahb_virtual_seqr_h);
  phase.drop_objection(this);
endtask : run_phase
`endif
