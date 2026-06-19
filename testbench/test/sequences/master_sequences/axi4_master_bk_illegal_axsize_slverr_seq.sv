`ifndef AXI4_MASTER_BK_ILLEGAL_AXSIZE_SLVERR_SEQ_INCLUDED_
`define AXI4_MASTER_BK_ILLEGAL_AXSIZE_SLVERR_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_illegal_axsize_slverr_seq
// Extends the axi4_master_bk_base_seq and drives a write whose AWSIZE exceeds the bridge
// bus width (8 bytes on a 4-byte bus). The DUT must flag this as SLVERR and not forward it.
//--------------------------------------------------------------------------------------------
class axi4_master_bk_illegal_axsize_slverr_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_illegal_axsize_slverr_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_illegal_axsize_slverr_seq");
  extern task body();
endclass : axi4_master_bk_illegal_axsize_slverr_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_illegal_axsize_slverr_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_illegal_axsize_slverr_seq::new(string name = "axi4_master_bk_illegal_axsize_slverr_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Randomises a write with an illegal AWSIZE (> bus width) to provoke a SLVERR response
//--------------------------------------------------------------------------------------------
task axi4_master_bk_illegal_axsize_slverr_seq::body();
  super.body();
  // WRITE_8_BYTES is wider than the 4-byte bridge bus -> illegal. Disable the
  // strobe<->size constraint so the illegal size can actually be randomised.
  req.wstrb_c4.constraint_mode(0);
  start_item(req);
  if(!req.randomize() with {req.awsize == WRITE_8_BYTES;
                            req.awlen  == 0;
                            req.tx_type == WRITE;
                            req.awburst == WRITE_INCR;
                            req.transfer_type == BLOCKING_WRITE;}) begin
    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

endtask : body

`endif
