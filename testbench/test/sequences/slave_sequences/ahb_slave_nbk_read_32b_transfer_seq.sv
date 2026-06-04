`ifndef ahb_SLAVE_NBK_READ_32B_TRANSFER_SEQ_INCLUDED_
`define ahb_SLAVE_NBK_READ_32B_TRANSFER_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_nbk_read_32b_transfer_seq
// Extends the ahb_slave_nbk_base_seq and randomises the req item
//--------------------------------------------------------------------------------------------
class ahb_slave_nbk_read_32b_transfer_seq extends ahb_slave_nbk_base_seq;
  `uvm_object_utils(ahb_slave_nbk_read_32b_transfer_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_nbk_read_32b_transfer_seq");
  extern task body();
endclass : ahb_slave_nbk_read_32b_transfer_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - ahb_slave_nbk_read_32b_transfer_seq
//--------------------------------------------------------------------------------------------
function ahb_slave_nbk_read_32b_transfer_seq::new(string name = "ahb_slave_nbk_read_32b_transfer_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type slave_nbk transaction and randomises the req
//--------------------------------------------------------------------------------------------
task ahb_slave_nbk_read_32b_transfer_seq::body();
  super.body();
  req.transfer_type=NON_BLOCKING_READ;
  req.tx_type = READ;
  
  start_item(req);
  if(!req.randomize()) begin
    `uvm_fatal("ahb","Rand failed");
  end
  req.print();
  finish_item(req);
endtask : body

`endif


