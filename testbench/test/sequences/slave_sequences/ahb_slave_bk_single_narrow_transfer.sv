`ifndef ahb_slave_bk_single_narrow_transfer_INCLUDED_
`define ahb_slave_bk_single_narrow_transfer_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_bk_single_narrow_transfer
// Extends the ahb_slave_base_seq and randomises the req item
//--------------------------------------------------------------------------------------------
class ahb_slave_bk_single_narrow_transfer extends ahb_slave_bk_base_seq;
  `uvm_object_utils(ahb_slave_bk_single_narrow_transfer)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_bk_single_narrow_transfer");
  extern task body();
endclass : ahb_slave_bk_single_narrow_transfer

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - ahb_slave_bk_single_narrow_transfer
//--------------------------------------------------------------------------------------------
function ahb_slave_bk_single_narrow_transfer::new(string name = "ahb_slave_bk_single_narrow_transfer");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type slave transaction and randomises the req
//--------------------------------------------------------------------------------------------
task ahb_slave_bk_single_narrow_transfer::body();
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


