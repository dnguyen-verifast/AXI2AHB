`ifndef AHB_MASTER_WRAP_BURST_SEQ_INCLUDE_
`define AHB_MASTER_WRAP_BURST_SEQ_INCLUDE_

class ahb_master_wrap_burst_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_wrap_burst_seq)

    extern function new(string name = "ahb_master_wrap_burst_seq");
    extern task body();
endclass : ahb_master_wrap_burst_seq
function ahb_master_wrap_burst_seq::new(string name = "ahb_master_wrap_burst_seq");
    super.new(name);
endfunction : new

task ahb_master_wrap_burst_seq::body();
   do_burst_transfer(32'h1000_0000, HWRITE_WRITE, WRAP4, HSIZE_WORD, 0);
   do_idle(2,32'h1000_0000);
   do_burst_transfer(32'h1001_0000, HWRITE_WRITE, WRAP8, HSIZE_WORD, 0);
   do_idle(2,32'h1000_0000);
   do_burst_transfer(32'h1002_0000, HWRITE_WRITE, WRAP16, HSIZE_WORD, 0);
   do_idle(2,32'h1000_0000);

   do_burst_transfer(32'h100_0000, HWRITE_READ, WRAP4, HSIZE_WORD, 0);
   do_idle(2,32'h1000_0000);
   do_burst_transfer(32'h1001_0000, HWRITE_READ, WRAP8, HSIZE_WORD, 0);
   do_idle(2,32'h1000_0000);
   do_burst_transfer(32'h1002_0000, HWRITE_READ, WRAP16, HSIZE_WORD, 0);
   do_idle(2,32'h1000_0000);
endtask : body
`endif
