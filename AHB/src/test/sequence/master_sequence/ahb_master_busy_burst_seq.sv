`ifndef AHB_MASTER_BUSY_BURST_SEQ_INCLUDE_
`define AHB_MASTER_BUSY_BURST_SEQ_INCLUDE_

class ahb_master_busy_burst_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_busy_burst_seq)

    extern function new(string name = "ahb_master_busy_burst_seq");
    extern task body();
endclass : ahb_master_busy_burst_seq
function ahb_master_busy_burst_seq::new(string name = "ahb_master_busy_burst_seq");
    super.new(name);
endfunction : new

task ahb_master_busy_burst_seq::body();
   do_burst_transfer(32'h1000_0000, HWRITE_WRITE, INCR4, HSIZE_WORD, 50);
   do_idle(2,32'h1000_0000);
   do_burst_transfer(32'h1000_0000, HWRITE_WRITE, INCR8, HSIZE_WORD, 50);
   do_idle(2,32'h1000_0000);
   do_burst_transfer(32'h1000_0000, HWRITE_WRITE, INCR16, HSIZE_WORD, 50);
   do_idle(2,32'h1000_0000);
endtask : body
`endif
