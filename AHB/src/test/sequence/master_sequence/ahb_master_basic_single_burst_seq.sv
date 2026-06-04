`ifndef AHB_MASTER_BASIC_SINGLE_BURST_SEQ_INCLUDE_
`define AHB_MASTER_BASIC_SINGLE_BURST_SEQ_INCLUDE_

class ahb_master_basic_single_burst_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_basic_single_burst_seq)

    extern function new(string name = "ahb_master_basic_single_burst_seq");
    extern task body();
endclass : ahb_master_basic_single_burst_seq

function ahb_master_basic_single_burst_seq::new(string name = "ahb_master_basic_single_burst_seq");
    super.new(name);
endfunction : new

task ahb_master_basic_single_burst_seq::body();
   repeat(100) begin
    start_item(req_m);
    assert(req_m.randomize() with {
            htrans == SINGLE;
            hexcl == HEXCL_NORMAL;
            hnonsec == HNONSEC_NONSECURE;
            htrans  == HTRANS_NONSEQ;
    });
    finish_item(req_m);

    do_idle(2, 32'h3000_0010);
   end
endtask : body

`endif
