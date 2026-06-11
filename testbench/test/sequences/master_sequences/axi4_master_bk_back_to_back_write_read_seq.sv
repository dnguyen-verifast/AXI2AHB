`ifndef AXI4_MASTER_BK_BACK_TO_BACK_WRITE_READ_SEQ_INCLUDED_
`define AXI4_MASTER_BK_BACK_TO_BACK_WRITE_READ_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_back_to_back_write_read_seq
// Extends the axi4_master_bk_base_seq and randomises the req item for back-to-back write/read
//--------------------------------------------------------------------------------------------
class axi4_master_bk_back_to_back_write_read_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_back_to_back_write_read_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_back_to_back_write_read_seq");
  extern task body();
endclass : axi4_master_bk_back_to_back_write_read_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_back_to_back_write_read_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_back_to_back_write_read_seq::new(string name = "axi4_master_bk_back_to_back_write_read_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type master_bk transaction and sends back-to-back write/read requests
//--------------------------------------------------------------------------------------------
task axi4_master_bk_back_to_back_write_read_seq::body();
  super.body();
  // Send write request immediately
  start_item(req);
  if(!req.randomize() with {req.awsize == WRITE_4_BYTES;
                            req.awlen  == 4;
                            req.tx_type == WRITE;
                            req.awburst == WRITE_INCR;
                            req.transfer_type == BLOCKING_WRITE;}) begin
    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

  // Send read request immediately after write
  start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.arlen  == 4;
                            req.tx_type == READ;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;}) begin
    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

endtask : body

`endif
