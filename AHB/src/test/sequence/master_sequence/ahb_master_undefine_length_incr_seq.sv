`ifndef AHB_MASTER_UNDEFINE_LENGTH_INCR_SEQ_INCLUDE_
`define AHB_MASTER_UNDEFINE_LENGTH_INCR_SEQ_INCLUDE_

class ahb_master_undefine_length_incr_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_undefine_length_incr_seq)

    extern function new(string name = "ahb_master_undefine_length_incr_seq");
    extern task body();
endclass : ahb_master_undefine_length_incr_seq

function ahb_master_undefine_length_incr_seq::new(string name = "ahb_master_undefine_length_incr_seq");
    super.new(name);
endfunction : new

task ahb_master_undefine_length_incr_seq::body();
   // Undefined length INCR burst with 8 transfers
   do_burst_transfer(32'h1000_0000, HWRITE_WRITE, INCR, HSIZE_BYTE, 0, 8);
   do_idle(2, 32'h1000_0000);
   
   // Undefined length INCR burst with 12 transfers
   do_burst_transfer(32'h1000_0100, HWRITE_READ, INCR, HSIZE_HWORD, 0, 12);
   do_idle(2, 32'h1000_0100);

    do_burst_transfer(32'h1000_0100, HWRITE_READ, INCR, HSIZE_WORD, 0, 12);
   do_idle(2, 32'h1000_0100);

    do_burst_transfer(32'h1000_0000, HWRITE_WRITE, INCR, HSIZE_BYTE, 0, 20);
   do_idle(2, 32'h1000_0000);
   
endtask : body

`endif
