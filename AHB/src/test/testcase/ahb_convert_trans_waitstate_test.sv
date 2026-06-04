`ifndef AHB_CONVERT_TRANS_WAITSTATE_TEST_INCLUDE_
`define AHB_CONVERT_TRANS_WAITSTATE_TEST_INCLUDE_

class ahb_convert_trans_waitstate_test extends ahb_test_base;
    `uvm_component_utils(ahb_convert_trans_waitstate_test)

    ahb_virtual_convert_trans_waitstate_seq ahb_virtual_convert_trans_waitstate_seq_h;

    extern function new(string name = "ahb_convert_trans_waitstate_test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
endclass : ahb_convert_trans_waitstate_test

function ahb_convert_trans_waitstate_test::new(string name = "ahb_convert_trans_waitstate_test",
                                               uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void ahb_convert_trans_waitstate_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_env_config_h.ahb_master_config_h[0].has_convert_waitstate = 1;
endfunction : build_phase

task ahb_convert_trans_waitstate_test::run_phase(uvm_phase phase);
    ahb_virtual_convert_trans_waitstate_seq_h = ahb_virtual_convert_trans_waitstate_seq::type_id::create("ahb_virtual_convert_trans_waitstate_seq_h");
    `uvm_info(get_type_name(), $sformatf("ahb_convert_trans_waitstate_test"), UVM_LOW);
    phase.raise_objection(this);
    ahb_virtual_convert_trans_waitstate_seq_h.start(ahb_env_h.ahb_virtual_seqr_h);
    phase.drop_objection(this);
endtask : run_phase

`endif
