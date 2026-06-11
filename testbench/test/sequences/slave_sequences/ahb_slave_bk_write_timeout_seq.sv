`ifndef ahb_SLAVE_BK_WRITE_TIMEOUT_SEQ_INCLUDED_
`define ahb_SLAVE_BK_WRITE_TIMEOUT_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_bk_write_timeout_seq
// Extends the ahb_slave_bk_base_seq and randomises the req item for write timeout scenario
//--------------------------------------------------------------------------------------------
class ahb_slave_bk_write_timeout_seq extends ahb_slave_bk_base_seq;
  `uvm_object_utils(ahb_slave_bk_write_timeout_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_bk_write_timeout_seq");
  extern task body();
endclass : ahb_slave_bk_write_timeout_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - ahb_slave_bk_write_timeout_seq
//--------------------------------------------------------------------------------------------
function ahb_slave_bk_write_timeout_seq::new(string name = "ahb_slave_bk_write_timeout_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type slave_bk transaction with delayed response to trigger timeout
//--------------------------------------------------------------------------------------------
task ahb_slave_bk_write_timeout_seq::body();
  super.body();
  start_item(req_slv);
  if(!req_slv.randomize() with {
        hresp == HRESP_OKAY;
        wait_state == 100; // High wait state to trigger timeout
  }) 
  begin
      `uvm_fatal("ahb_slave","Rand failed");
  end
  `uvm_info("AHB_SLAVE_WRITE_TIMEOUT_SEQ",$sformatf("req_slv = %s \n",req_slv.sprint()),UVM_LOW)
  finish_item(req_slv);

endtask : body

`endif
