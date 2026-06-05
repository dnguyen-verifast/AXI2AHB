`ifndef ahb_SLAVE_BK_READ_INCR_BURST_SEQ_INCLUDED_
`define ahb_SLAVE_BK_READ_INCR_BURST_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_bk_read_incr_burst_seq
// Extends the ahb_slave_bk_base_seq and randomises the req item
//--------------------------------------------------------------------------------------------
class ahb_slave_bk_read_incr_burst_seq extends ahb_slave_bk_base_seq;
  `uvm_object_utils(ahb_slave_bk_read_incr_burst_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_bk_read_incr_burst_seq");
  extern task body();
endclass : ahb_slave_bk_read_incr_burst_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - ahb_slave_bk_read_incr_burst_seq
//--------------------------------------------------------------------------------------------
function ahb_slave_bk_read_incr_burst_seq::new(string name = "ahb_slave_bk_read_incr_burst_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type slave_bk transaction and randomises the req
//--------------------------------------------------------------------------------------------
task ahb_slave_bk_read_incr_burst_seq::body();
  super.body();
  start_item(req_slv);
  if(!req_slv.randomize() with {
        hresp == HRESP_OKAY;
        wait_state == 0;
  }) 
  begin
      `uvm_fatal("ahb_slave","Rand failed");
  end
  `uvm_info("AHB_SLAVE_BASIC_SINGLE_BURST_SEQ",$sformatf("req_slv = %s \n",req_slv.sprint()),UVM_LOW)
  finish_item(req_slv);

endtask : body

`endif


