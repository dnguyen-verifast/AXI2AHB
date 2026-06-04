`ifndef AHB_MASTER_HSIZE_BYTE_STRB_SEQ_INCLUDE_
`define AHB_MASTER_HSIZE_BYTE_STRB_SEQ_INCLUDE_

class ahb_master_hsize_byte_strb_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_hsize_byte_strb_seq)

    extern function new(string name = "ahb_master_hsize_byte_strb_seq");
    extern task body();
endclass : ahb_master_hsize_byte_strb_seq

function ahb_master_hsize_byte_strb_seq::new(string name = "ahb_master_hsize_byte_strb_seq");
    super.new(name);
endfunction : new

task ahb_master_hsize_byte_strb_seq::body();
   // Byte transfers (HSIZE=0) with sparse write strobes
   do_burst_transfer(32'h4000_0000, HWRITE_WRITE, INCR4, HSIZE_BYTE, 0);
   do_idle(2, 32'h4000_0004);
   
   do_burst_transfer(32'h4000_0004, HWRITE_WRITE, INCR8, HSIZE_BYTE, 0);
   do_idle(2, 32'h4000_000C);
   
   do_burst_transfer(32'h4000_000C, HWRITE_READ, INCR4, HSIZE_BYTE, 0);
   do_idle(2, 32'h4000_000F);

endtask : body

`endif
