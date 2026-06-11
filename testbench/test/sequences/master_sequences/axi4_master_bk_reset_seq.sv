`ifndef AXI4_MASTER_BK_RESET_SEQ_INCLUDED_
`define AXI4_MASTER_BK_RESET_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_reset_seq
// Extends the axi4_master_bk_base_seq and randomises the req item for reset scenario
//--------------------------------------------------------------------------------------------
class axi4_master_bk_reset_seq extends uvm_sequence #(reset_item);
  `uvm_object_utils(axi4_master_bk_reset_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_reset_seq");
  extern task body();
endclass : axi4_master_bk_reset_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_reset_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_reset_seq::new(string name = "axi4_master_bk_reset_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type master_bk transaction and performs reset scenario
//--------------------------------------------------------------------------------------------
task axi4_master_bk_reset_seq::body();
  req = reset_item::type_id::create("req");
  start_item(req);
  if(!req.randomize()) begin
    `uvm_fatal("axi4","Rand failed");
  end
  finish_item(req);

endtask : body

`endif
