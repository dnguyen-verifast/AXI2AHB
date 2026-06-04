`ifndef AHB_MASTER_BASIC_SINGLE_R_SEQ_INCLUDE_
`define AHB_MASTER_BASIC_SINGLE_R_SEQ_INCLUDE_

class ahb_master_basic_single_r_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_basic_single_r_seq)

    extern function new(string name = "ahb_master_basic_single_r_seq");
    extern task body();
endclass : ahb_master_basic_single_r_seq

function ahb_master_basic_single_r_seq::new(string name = "ahb_master_basic_single_r_seq");
    super.new(name);
endfunction : new

task ahb_master_basic_single_r_seq::body();
   do_burst_transfer(32'h2000_0000, HWRITE_READ, INCR4, HSIZE_WORD, 0);
   do_idle(2, 32'h2000_0000);
   do_burst_transfer(32'h2000_0004, HWRITE_READ, INCR8, HSIZE_WORD, 0);
   do_idle(2, 32'h2000_0004);
   do_burst_transfer(32'h2000_0008, HWRITE_READ, INCR16, HSIZE_WORD, 0);
   do_idle(2, 32'h2000_0008);
endtask : body

`endif
