`ifndef AXI4_MASTER_BK_1KB_CROSS_WRAP_SEQ_INCLUDED_
`define AXI4_MASTER_BK_1KB_CROSS_WRAP_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_1kb_cross_wrap_seq
// Extends the axi4_master_bk_base_seq and drives a WRAP burst whose wrap region butts up
// against a 1KB boundary, to verify the bridge wraps correctly without crossing 1KB.
//--------------------------------------------------------------------------------------------
class axi4_master_bk_1kb_cross_wrap_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_1kb_cross_wrap_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_1kb_cross_wrap_seq");
  extern task body();
endclass : axi4_master_bk_1kb_cross_wrap_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_1kb_cross_wrap_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_1kb_cross_wrap_seq::new(string name = "axi4_master_bk_1kb_cross_wrap_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Randomises a 16-beat 4-byte WRAP burst aligned just below a 1KB boundary (0x3C0..0x400)
//--------------------------------------------------------------------------------------------
task axi4_master_bk_1kb_cross_wrap_seq::body();
  super.body();
  start_item(req);
  if(!req.randomize() with {req.awsize == WRITE_4_BYTES;
                            req.awlen  == 15;
                            req.awaddr == 32'h000003C0;
                            req.tx_type == WRITE;
                            req.awburst == WRITE_WRAP;
                            req.transfer_type == BLOCKING_WRITE;}) begin
    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

endtask : body

`endif
