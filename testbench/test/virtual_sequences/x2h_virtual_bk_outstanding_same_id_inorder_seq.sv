`ifndef X2H_VIRTUAL_BK_OUTSTANDING_SAME_ID_INORDER_SEQ_INCLUDED_
`define X2H_VIRTUAL_BK_OUTSTANDING_SAME_ID_INORDER_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_bk_outstanding_same_id_inorder_seq
// Creates and starts the master and slave sequences for the same-ID in-order scenario
//--------------------------------------------------------------------------------------------
class x2h_virtual_bk_outstanding_same_id_inorder_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_bk_outstanding_same_id_inorder_seq)

  //Variable: axi4_master_bk_outstanding_same_id_inorder_seq_h
  //Instantiation of axi4_master_bk_outstanding_same_id_inorder_seq handle
  axi4_master_bk_outstanding_same_id_inorder_seq axi4_master_bk_outstanding_same_id_inorder_seq_h;

  //Variable: ahb_slave_bk_outstanding_same_id_inorder_seq_h
  //Instantiation of ahb_slave_bk_outstanding_same_id_inorder_seq handle
  ahb_slave_bk_outstanding_same_id_inorder_seq ahb_slave_bk_outstanding_same_id_inorder_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_bk_outstanding_same_id_inorder_seq");
  extern task body();
endclass : x2h_virtual_bk_outstanding_same_id_inorder_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - x2h_virtual_bk_outstanding_same_id_inorder_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_bk_outstanding_same_id_inorder_seq::new(string name = "x2h_virtual_bk_outstanding_same_id_inorder_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Starts the slave responder and the master same-ID read sequence
//--------------------------------------------------------------------------------------------
task x2h_virtual_bk_outstanding_same_id_inorder_seq::body();
  axi4_master_bk_outstanding_same_id_inorder_seq_h = axi4_master_bk_outstanding_same_id_inorder_seq::type_id::create("axi4_master_bk_outstanding_same_id_inorder_seq_h");

  `uvm_info(get_type_name(), $sformatf("Inside x2h_virtual_bk_outstanding_same_id_inorder_seq"), UVM_NONE);

  fork
    forever begin
      ahb_slave_bk_outstanding_same_id_inorder_seq_h = ahb_slave_bk_outstanding_same_id_inorder_seq::type_id::create("ahb_slave_bk_outstanding_same_id_inorder_seq_h");
      ahb_slave_bk_outstanding_same_id_inorder_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
    end
  join_none

  fork
    begin : T1_SAME_ID_INORDER
      axi4_master_bk_outstanding_same_id_inorder_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
    end
  join

endtask : body

`endif
