`ifndef ahb_SLAVE_BK_OUTSTANDING_SAME_ID_INORDER_SEQ_INCLUDED_
`define ahb_SLAVE_BK_OUTSTANDING_SAME_ID_INORDER_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_bk_outstanding_same_id_inorder_seq
// Extends the ahb_slave_bk_base_seq and responds OKAY with no wait states.
//--------------------------------------------------------------------------------------------
class ahb_slave_bk_outstanding_same_id_inorder_seq extends ahb_slave_bk_base_seq;
  `uvm_object_utils(ahb_slave_bk_outstanding_same_id_inorder_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_bk_outstanding_same_id_inorder_seq");
  extern task body();
endclass : ahb_slave_bk_outstanding_same_id_inorder_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - ahb_slave_bk_outstanding_same_id_inorder_seq
//--------------------------------------------------------------------------------------------
function ahb_slave_bk_outstanding_same_id_inorder_seq::new(string name = "ahb_slave_bk_outstanding_same_id_inorder_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type slave_bk transaction responding OKAY with no wait states
//--------------------------------------------------------------------------------------------
task ahb_slave_bk_outstanding_same_id_inorder_seq::body();
  super.body();
  start_item(req_slv);
  if(!req_slv.randomize() with {
        hresp == HRESP_OKAY;
        wait_state == 0;
  })
  begin
      `uvm_fatal("ahb_slave","Rand failed");
  end
  `uvm_info("AHB_SLAVE_OUTSTANDING_SAME_ID_INORDER_SEQ",$sformatf("req_slv = %s \n",req_slv.sprint()),UVM_LOW)
  finish_item(req_slv);

endtask : body

`endif
