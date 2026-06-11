`ifndef AXI4_MASTER_BK_1KB_CROSS_INCR_WRITE_SEQ_INCLUDED_
`define AXI4_MASTER_BK_1KB_CROSS_INCR_WRITE_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_1kb_cross_incr_write_seq
// Extends the axi4_master_bk_base_seq and randomises the req item for 1KB write transfer
//--------------------------------------------------------------------------------------------
class axi4_master_bk_1kb_cross_incr_write_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_1kb_cross_incr_write_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_1kb_cross_incr_write_seq");
  extern task body();
endclass : axi4_master_bk_1kb_cross_incr_write_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_1kb_cross_incr_write_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_1kb_cross_incr_write_seq::new(string name = "axi4_master_bk_1kb_cross_incr_write_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type master_bk transaction and randomises the req for 1KB transfer
//--------------------------------------------------------------------------------------------
task axi4_master_bk_1kb_cross_incr_write_seq::body();
  super.body(); 
begin
  start_item(req);
  if(!req.randomize() with {req.awsize == WRITE_4_BYTES;
                            req.awlen  == 255;
                            req.awaddr  == 32'h18000ff0; 
                            req.tx_type == WRITE;
                            req.awburst == WRITE_INCR;
                            req.transfer_type == BLOCKING_WRITE;}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

end
endtask : body

`endif
