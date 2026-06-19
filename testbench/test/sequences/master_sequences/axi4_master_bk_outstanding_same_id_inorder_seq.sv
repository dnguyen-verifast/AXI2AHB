`ifndef AXI4_MASTER_BK_OUTSTANDING_SAME_ID_INORDER_SEQ_INCLUDED_
`define AXI4_MASTER_BK_OUTSTANDING_SAME_ID_INORDER_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_outstanding_same_id_inorder_seq
// Extends the axi4_master_bk_base_seq and issues several reads that all share the same ARID.
// Transactions with the same ID must complete in order.
//--------------------------------------------------------------------------------------------
class axi4_master_bk_outstanding_same_id_inorder_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_outstanding_same_id_inorder_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_outstanding_same_id_inorder_seq");
  extern task body();
endclass : axi4_master_bk_outstanding_same_id_inorder_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_outstanding_same_id_inorder_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_outstanding_same_id_inorder_seq::new(string name = "axi4_master_bk_outstanding_same_id_inorder_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Issues four reads with the same ARID to check in-order completion
//--------------------------------------------------------------------------------------------
task axi4_master_bk_outstanding_same_id_inorder_seq::body();
  super.body();
  repeat(4) begin
    start_item(req);
    if(!req.randomize() with {req.arid    == ARID_0;
                              req.arsize   == READ_4_BYTES;
                              req.arlen    == 3;
                              req.tx_type  == READ;
                              req.arburst  == READ_INCR;
                              req.transfer_type == NON_BLOCKING_READ;}) begin
      `uvm_fatal("axi4","Rand failed");
    end
    req.print();
    finish_item(req);
  end

endtask : body

`endif
