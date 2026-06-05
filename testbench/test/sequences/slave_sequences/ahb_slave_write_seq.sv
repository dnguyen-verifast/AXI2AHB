`ifndef ahb_SLAVE_WRITE_SEQ_INCLUDED_
`define ahb_SLAVE_WRITE_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_write_seq
// Extends the ahb_slave_base_seq and randomises the req item
//--------------------------------------------------------------------------------------------
class ahb_slave_write_seq extends ahb_slave_base_seq;
  `uvm_object_utils(ahb_slave_write_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_write_seq");
  extern task body();
endclass : ahb_slave_write_seq

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - ahb_slave_write_seq
//  intializes new memory for the object
//--------------------------------------------------------------------------------------------
function ahb_slave_write_seq::new(string name = "ahb_slave_write_seq");
  super.new(name);
endfunction : new

//-------------------------------------------------------
//Task : Body
//Creates the req of type slave transaction and randomises the req.
//-------------------------------------------------------
task ahb_slave_write_seq::body();
     super.body();
    start_item(req_slv);
    if(!req_slv.randomize() with {
        hresp == HRESP_OKAY;
        wait_state == 0;
    }) 
    begin
        `uvm_fatal("ahb_slave","Rand failed");
    end
    finish_item(req_slv);
endtask :body

`endif


