`ifndef AHB_MASTER_LOCKED_SEQUENCE_SEQ_INCLUDE_
`define AHB_MASTER_LOCKED_SEQUENCE_SEQ_INCLUDE_

class ahb_master_locked_sequence_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_locked_sequence_seq)

    extern function new(string name = "ahb_master_locked_sequence_seq");
    extern task body();
endclass : ahb_master_locked_sequence_seq
function ahb_master_locked_sequence_seq::new(string name = "ahb_master_locked_sequence_seq");
    super.new(name);
endfunction : new

task ahb_master_locked_sequence_seq::body();
    int locked_addr = 32'h01000000;
    super.body(); 
    start_item(req_m);
    if(!req_m.randomize() with {
        hmastlock == 1'b1;
        hwrite == HWRITE_READ;
        htrans == HTRANS_NONSEQ;
        haddr == locked_addr;
    }) 
    begin
        `uvm_fatal("ahb_slave","Rand failed");
    end
    finish_item(req_m);

    start_item(req_m);
    if(!req_m.randomize() with {
        hmastlock == 1'b1;
        hwrite == HWRITE_WRITE;
        htrans == HTRANS_NONSEQ;
        haddr == locked_addr;
    }) 
    begin
        `uvm_fatal("ahb_slave","Rand failed");
    end
    finish_item(req_m);
    do_idle(2,32'h1000_0000);
endtask : body
`endif
