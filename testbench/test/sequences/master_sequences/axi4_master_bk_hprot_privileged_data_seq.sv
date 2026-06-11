`ifndef AXI4_MASTER_BK_HPROT_PRIVILEGED_DATA_SEQ_INCLUDED_
`define AXI4_MASTER_BK_HPROT_PRIVILEGED_DATA_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_hprot_privileged_data_seq
// Extends the axi4_master_bk_base_seq and randomises the req item for HPROT privileged data
//--------------------------------------------------------------------------------------------
class axi4_master_bk_hprot_privileged_data_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_hprot_privileged_data_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_hprot_privileged_data_seq");
  extern task body();
endclass : axi4_master_bk_hprot_privileged_data_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_hprot_privileged_data_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_hprot_privileged_data_seq::new(string name = "axi4_master_bk_hprot_privileged_data_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type master_bk transaction with HPROT privileged data settings
//--------------------------------------------------------------------------------------------
task axi4_master_bk_hprot_privileged_data_seq::body();
  super.body(); 
begin
  start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.arlen  == 4; 
                            req.tx_type == READ;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;
                            req.arprot[0] == 0; // Data bit
                            req.arprot[1] == 0; // Non-secure
                            req.arprot[2] == 1; // Privileged
                            req.arcache[0] == 0; // Non-bufferable
                            req.arcache[1] == 0; // Non-modifiable
                            req.arcache[2] == 0; // Non-allocate
                            req.arcache[3] == 0; // Non-allocate}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

  // Send another request with privileged data attribute
  start_item(req);
  if(!req.randomize() with {req.awsize == WRITE_4_BYTES;
                            req.awlen  == 4; 
                            req.tx_type == WRITE;
                            req.awburst == WRITE_INCR;
                            req.transfer_type == BLOCKING_WRITE;
                            req.awprot[0] == 0; // Data bit
                            req.awprot[1] == 0; // Non-secure
                            req.awprot[2] == 1; // Privileged
                            req.awcache[0] == 0; // Non-bufferable
                            req.awcache[1] == 0; // Non-modifiable
                            req.awcache[2] == 0; // Non-allocate
                            req.awcache[3] == 0; // Non-allocate}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

end
endtask : body

`endif
