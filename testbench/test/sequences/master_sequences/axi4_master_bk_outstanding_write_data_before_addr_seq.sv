`ifndef AXI4_MASTER_BK_OUTSTANDING_WRITE_DATA_BEFORE_ADDR_SEQ_INCLUDED_
`define AXI4_MASTER_BK_OUTSTANDING_WRITE_DATA_BEFORE_ADDR_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_outstanding_write_data_before_addr_seq
// Extends the axi4_master_bk_base_seq and issues back-to-back writes. AXI permits the write
// data (W) to arrive before the write address (AW); this stimulus exercises that ordering on
// the bridge's write data/address buffering.
//--------------------------------------------------------------------------------------------
class axi4_master_bk_outstanding_write_data_before_addr_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_outstanding_write_data_before_addr_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_outstanding_write_data_before_addr_seq");
  extern task body();
endclass : axi4_master_bk_outstanding_write_data_before_addr_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_outstanding_write_data_before_addr_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_outstanding_write_data_before_addr_seq::new(string name = "axi4_master_bk_outstanding_write_data_before_addr_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Issues two writes back-to-back so write data can be presented ahead of the address phase
//--------------------------------------------------------------------------------------------
task axi4_master_bk_outstanding_write_data_before_addr_seq::body();
  super.body();
  repeat(2) begin
    start_item(req);
    if(!req.randomize() with {req.awsize  == WRITE_4_BYTES;
                              req.awlen    == 3;
                              req.tx_type  == WRITE;
                              req.awburst  == WRITE_INCR;
                              req.transfer_type == BLOCKING_WRITE;}) begin
      `uvm_fatal("axi4","Rand failed");
    end
    req.print();
    finish_item(req);
  end

endtask : body

`endif
