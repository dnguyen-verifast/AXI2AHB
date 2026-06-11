`ifndef axi4_master_bk_write_priority_seq_INCLUDED_
`define axi4_master_bk_write_priority_seq_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_write_priority_seq
// Extends the axi4_master_bk_base_seq and randomises the req item for read/write priority
//--------------------------------------------------------------------------------------------
class axi4_master_bk_write_priority_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_write_priority_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_write_priority_seq");
  extern task body();
endclass : axi4_master_bk_write_priority_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_write_priority_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_write_priority_seq::new(string name = "axi4_master_bk_write_priority_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type master_bk transaction and randomises the req for priority testing
//--------------------------------------------------------------------------------------------
task axi4_master_bk_write_priority_seq::body();
  super.body(); 
    // Then send write request
  start_item(req);
  if(!req.randomize() with {req.awsize == WRITE_4_BYTES;
                            req.awlen  == 4; 
                            req.tx_type == WRITE;
                            req.awburst == WRITE_INCR;
                            req.transfer_type == BLOCKING_WRITE;}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);
endtask : body

`endif
