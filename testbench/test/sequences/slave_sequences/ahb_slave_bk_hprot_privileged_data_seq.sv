`ifndef ahb_SLAVE_BK_HPROT_PRIVILEGED_DATA_SEQ_INCLUDED_
`define ahb_SLAVE_BK_HPROT_PRIVILEGED_DATA_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_bk_hprot_privileged_data_seq
// Extends the ahb_slave_bk_base_seq and randomises the req item for HPROT privileged data
//--------------------------------------------------------------------------------------------
class ahb_slave_bk_hprot_privileged_data_seq extends ahb_slave_bk_base_seq;
  `uvm_object_utils(ahb_slave_bk_hprot_privileged_data_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_bk_hprot_privileged_data_seq");
  extern task body();
endclass : ahb_slave_bk_hprot_privileged_data_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - ahb_slave_bk_hprot_privileged_data_seq
//--------------------------------------------------------------------------------------------
function ahb_slave_bk_hprot_privileged_data_seq::new(string name = "ahb_slave_bk_hprot_privileged_data_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type slave_bk transaction with HPROT privileged data
//--------------------------------------------------------------------------------------------
task ahb_slave_bk_hprot_privileged_data_seq::body();
  super.body();
  start_item(req_slv);
  if(!req_slv.randomize() with {
        hresp == HRESP_OKAY;
        wait_state == 0;
  }) 
  begin
      `uvm_fatal("ahb_slave","Rand failed");
  end
  `uvm_info("AHB_SLAVE_HPROT_PRIVILEGED_DATA_SEQ",$sformatf("req_slv = %s \n",req_slv.sprint()),UVM_LOW)
  finish_item(req_slv);

endtask : body

`endif
