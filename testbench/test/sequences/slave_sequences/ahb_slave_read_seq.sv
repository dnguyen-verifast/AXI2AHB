`ifndef ahb_SLAVE_READ_SEQ_INCLUDED_
`define ahb_SLAVE_READ_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_read_seq
// Extends the ahb_slave_read_seq and randomize the req item
//--------------------------------------------------------------------------------------------
class ahb_slave_read_seq extends ahb_slave_base_seq;
  `uvm_object_utils(ahb_slave_read_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_read_seq");
  extern task body();
endclass : ahb_slave_read_seq

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - ahb_slave_read_seq
//  intializes the memory for the object
//--------------------------------------------------------------------------------------------
function ahb_slave_read_seq::new(string name = "ahb_slave_read_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
//Task : Body
//Creates the req of type slave transaction and randomises the req
//--------------------------------------------------------------------------------------------
task ahb_slave_read_seq::body();
  req=ahb_slave_tx::type_id::create("req");

  start_item(req);
  if(!req.randomize()) begin
    `uvm_fatal(get_type_name(),"randomization failed");
  end
  `uvm_info("REQ_READ_DEBUG",$sformatf("read_req = \n %0p",req.sprint()),UVM_HIGH);
  finish_item(req);
endtask : body

`endif


