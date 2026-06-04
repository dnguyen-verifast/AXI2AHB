`ifndef ahb_SLAVE_NBK_WRITE_OKAY_RESP_SEQ_INCLUDED_
`define ahb_SLAVE_NBK_WRITE_OKAY_RESP_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_nbk_write_okay_resp_seq
// Extends the ahb_slave_base_seq and randomises the req item
//--------------------------------------------------------------------------------------------
class ahb_slave_nbk_write_okay_resp_seq extends ahb_slave_nbk_base_seq;
  `uvm_object_utils(ahb_slave_nbk_write_okay_resp_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_nbk_write_okay_resp_seq");
  extern task body();
endclass : ahb_slave_nbk_write_okay_resp_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - ahb_slave_nbk_write_okay_resp_seq
//--------------------------------------------------------------------------------------------
function ahb_slave_nbk_write_okay_resp_seq::new(string name = "ahb_slave_nbk_write_okay_resp_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type slave transaction and randomises the req
//--------------------------------------------------------------------------------------------
task ahb_slave_nbk_write_okay_resp_seq::body();
  super.body();
  req.transfer_type=NON_BLOCKING_WRITE;

  start_item(req);
  if(!req.randomize)begin
    `uvm_fatal("ahb","Rand failed");
  end
  `uvm_info(get_type_name(), $sformatf("slave_seq \n%s",req.sprint()), UVM_NONE); 
  finish_item(req);

endtask : body

`endif


