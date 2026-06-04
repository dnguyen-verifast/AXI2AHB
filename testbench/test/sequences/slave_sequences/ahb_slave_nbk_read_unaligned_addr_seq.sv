`ifndef ahb_SLAVE_NBK_READ_UNALIGNED_ADDR_SEQ_INCLUDED_
`define ahb_SLAVE_NBK_READ_UNALIGNED_ADDR_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_nbk_read_unaligned_addr_seq
// Extends the ahb_slave_nbk_base_seq and randomises the req item
//--------------------------------------------------------------------------------------------
class ahb_slave_nbk_read_unaligned_addr_seq extends ahb_slave_nbk_base_seq;
  `uvm_object_utils(ahb_slave_nbk_read_unaligned_addr_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_nbk_read_unaligned_addr_seq");
  extern task body();
endclass : ahb_slave_nbk_read_unaligned_addr_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - ahb_slave_nbk_read_unaligned_addr_seq
//--------------------------------------------------------------------------------------------
function ahb_slave_nbk_read_unaligned_addr_seq::new(string name = "ahb_slave_nbk_read_unaligned_addr_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type slave_nbk transaction and randomises the req
//--------------------------------------------------------------------------------------------
task ahb_slave_nbk_read_unaligned_addr_seq::body();
  super.body();
  req.transfer_type=NON_BLOCKING_READ;
  
  start_item(req);
  if(!req.randomize())begin
    `uvm_fatal("ahb","Rand failed");
  end
  req.print();
  finish_item(req);
endtask : body

`endif


