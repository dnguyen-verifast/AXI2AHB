`ifndef AXI4_MASTER_BK_READ_INCR_BURST_SEQ_INCLUDED_
`define AXI4_MASTER_BK_READ_INCR_BURST_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_read_incr_burst_seq
// Extends the axi4_master_bk_base_seq and randomises the req item
//--------------------------------------------------------------------------------------------
class axi4_master_bk_read_incr_burst_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_read_incr_burst_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_read_incr_burst_seq");
  extern task body();
endclass : axi4_master_bk_read_incr_burst_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_read_incr_burst_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_read_incr_burst_seq::new(string name = "axi4_master_bk_read_incr_burst_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type master_bk transaction and randomises the req
//--------------------------------------------------------------------------------------------
task axi4_master_bk_read_incr_burst_seq::body();
  super.body();

  start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.tx_type == READ;
                            req.arlen  == 1;
                            req.araddr == 32'h11010110;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

    start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.tx_type == READ;
                            req.arlen  == 7;
                            req.araddr == 32'h11110110;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);
    start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.tx_type == READ;
                            req.arlen  == 15;
                            req.araddr == 32'h11111110;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);
    start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.tx_type == READ;
                            req.arlen  == 127;
                            req.araddr == 32'h21111110;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);
    start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.tx_type == READ;
                            req.arlen  == 255;
                            req.araddr == 32'h22111110;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);
    start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.tx_type == READ;
                            req.arlen  == 63;
                            req.araddr == 32'h23111110;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);
  
    start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.tx_type == READ;
                            req.arlen  == 101;
                            req.araddr == 32'h2f111110;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

endtask : body

`endif

