`ifndef AHB_MASTER_1KB_BOUNDARY_VIOLATION_SEQ_INCLUDE_
`define AHB_MASTER_1KB_BOUNDARY_VIOLATION_SEQ_INCLUDE_

class ahb_master_1kb_boundary_violation_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_1kb_boundary_violation_seq)

    extern function new(string name = "ahb_master_1kb_boundary_violation_seq");
    extern task body();
endclass : ahb_master_1kb_boundary_violation_seq
function ahb_master_1kb_boundary_violation_seq::new(string name = "ahb_master_1kb_boundary_violation_seq");
    super.new(name);
endfunction : new

task ahb_master_1kb_boundary_violation_seq::body();

   do_burst_transfer(32'h3fff_fff8, HWRITE_WRITE, INCR4, HSIZE_WORD, 0);
   do_idle(1, 32'h3000_0010);

   do_burst_transfer(32'h3fff_fff8, HWRITE_WRITE, WRAP4, HSIZE_WORD, 0);
   do_idle(1, 32'h3000_0020);
   
endtask : body
`endif
