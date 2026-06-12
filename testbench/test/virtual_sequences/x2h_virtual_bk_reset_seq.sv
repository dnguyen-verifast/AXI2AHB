`ifndef X2H_VIRTUAL_BK_RESET_SEQ_INCLUDED_
`define X2H_VIRTUAL_BK_RESET_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_bk_reset_seq
// Creates and starts the master and slave sequences for reset scenario
//--------------------------------------------------------------------------------------------
class x2h_virtual_bk_reset_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_bk_reset_seq)

  axi4_master_bk_read_32b_transfer_seq axi4_master_bk_read_32b_transfer_seq_h;
  //Variable: axi4_master_bk_reset_seq_h
  //Instantiation of axi4_master_bk_reset_seq handle
  axi4_master_bk_reset_seq axi4_master_bk_reset_seq_h;

  //Variable: ahb_slave_bk_reset_seq_h
  //Instantiation of ahb_slave_bk_reset_seq handle
  ahb_slave_bk_reset_seq ahb_slave_bk_reset_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_bk_reset_seq");
  extern task body();
endclass : x2h_virtual_bk_reset_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - x2h_virtual_bk_reset_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_bk_reset_seq::new(string name = "x2h_virtual_bk_reset_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences for reset scenario
//--------------------------------------------------------------------------------------------
task x2h_virtual_bk_reset_seq::body();

  axi4_master_bk_read_32b_transfer_seq_h = axi4_master_bk_read_32b_transfer_seq::type_id::create("axi4_master_bk_read_32b_transfer_seq_h");

  axi4_master_bk_reset_seq_h = axi4_master_bk_reset_seq::type_id::create("axi4_master_bk_reset_seq_h");

  ahb_slave_bk_reset_seq_h = ahb_slave_bk_reset_seq::type_id::create("ahb_slave_bk_reset_seq_h");

  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: Inside x2h_virtual_bk_reset_seq"), UVM_NONE); 

  fork
    begin : T1_SL_RESET
      forever begin
        ahb_slave_bk_reset_seq_h = ahb_slave_bk_reset_seq::type_id::create("ahb_slave_bk_reset_seq_h");
        ahb_slave_bk_reset_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
      end
    end
  join_none

  fork 
    begin: T1_RESET
    #100;
      axi4_master_bk_reset_seq_h.start(p_sequencer.reset_sequencer_h);
    end
    begin : T2_RESET
      axi4_master_bk_read_32b_transfer_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
    end
  join_any
  axi4_master_bk_read_32b_transfer_seq_h.kill();
  disable fork;
  #20;
  axi4_master_bk_read_32b_transfer_seq_h = axi4_master_bk_read_32b_transfer_seq::type_id::create("axi4_master_bk_read_32b_transfer_seq_h");
  fork
    begin : T2_SL_RESET
      forever begin
        ahb_slave_bk_reset_seq_h = ahb_slave_bk_reset_seq::type_id::create("ahb_slave_bk_reset_seq_h");
        ahb_slave_bk_reset_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
      end
    end
  join_none
  axi4_master_bk_read_32b_transfer_seq_h.start(p_sequencer.axi4_master_read_seqr_h);

endtask : body

`endif
