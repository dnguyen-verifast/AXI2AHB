`ifndef AHB_MASTER_IDLE_TRANSFER_SEQ_INCLUDE_
`define AHB_MASTER_IDLE_TRANSFER_SEQ_INCLUDE_

class ahb_master_idle_transfer_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_idle_transfer_seq)

    extern function new(string name = "ahb_master_idle_transfer_seq");
    extern task body();
endclass : ahb_master_idle_transfer_seq
function ahb_master_idle_transfer_seq::new(string name = "ahb_master_idle_transfer_seq");
    super.new(name);
endfunction : new

task ahb_master_idle_transfer_seq::body();
    super.body();
    start_item(req_m);
    if(!req_m.randomize()) begin
        `uvm_fatal("ahb_master","Rand failed");
    end
    finish_item(req_m);
endtask : body
`endif
