`ifndef AHB_MASTER_HSIZE_HALFWORD_STRB_SEQ_INCLUDE_
`define AHB_MASTER_HSIZE_HALFWORD_STRB_SEQ_INCLUDE_

class ahb_master_hsize_halfword_strb_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_hsize_halfword_strb_seq)

    extern function new(string name = "ahb_master_hsize_halfword_strb_seq");
    extern task body();
endclass : ahb_master_hsize_halfword_strb_seq

function ahb_master_hsize_halfword_strb_seq::new(string name = "ahb_master_hsize_halfword_strb_seq");
    super.new(name);
endfunction : new

task ahb_master_hsize_halfword_strb_seq::body();
   // Halfword transfers (HSIZE=1) with sparse write strobes
   do_burst_transfer(32'h5000_0000, HWRITE_WRITE, INCR4, HSIZE_HWORD, 0);
   do_idle(2, 32'h5000_0008);
   
   do_burst_transfer(32'h5000_0008, HWRITE_WRITE, INCR8, HSIZE_HWORD, 0);
   do_idle(2, 32'h5000_0018);
   
   do_burst_transfer(32'h5000_0018, HWRITE_READ, INCR4, HSIZE_HWORD, 0);
   do_idle(2, 32'h5000_001F);

endtask : body

`endif
