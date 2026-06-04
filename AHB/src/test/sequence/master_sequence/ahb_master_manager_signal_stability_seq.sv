`ifndef AHB_MASTER_MANAGER_SIGNAL_STABILITY_SEQ_INCLUDE_
`define AHB_MASTER_MANAGER_SIGNAL_STABILITY_SEQ_INCLUDE_

class ahb_master_manager_signal_stability_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_manager_signal_stability_seq)

    extern function new(string name = "ahb_master_manager_signal_stability_seq");
    extern task body();
endclass : ahb_master_manager_signal_stability_seq
function ahb_master_manager_signal_stability_seq::new(string name = "ahb_master_manager_signal_stability_seq");
    super.new(name);
endfunction : new

task ahb_master_manager_signal_stability_seq::body();
    super.body();
    start_item(req_m);
    if(!req_m.randomize()) begin
        `uvm_fatal("ahb_master","Rand failed");
    end
    finish_item(req_m);
endtask : body
`endif
