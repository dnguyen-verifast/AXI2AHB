`ifndef X2H_VIRTUAL_BK_WRAP_BURST_READ_SEQ_INCLUDED_
`define X2H_VIRTUAL_BK_WRAP_BURST_READ_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_bk_wrap_burst_read_seq
// Creates and starts the master and slave sequences
//--------------------------------------------------------------------------------------------
class x2h_virtual_bk_wrap_burst_read_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_bk_wrap_burst_read_seq)

  //Variable: axi4_master_bk_read_wrap_burst_seq_h
  //Instantiation of axi4_master_bk_read_wrap_burst_seq handle
  axi4_master_bk_read_wrap_burst_seq axi4_master_bk_read_wrap_burst_seq_h;

  //Variable: ahb_slave_bk_read_wrap_burst_seq_h
  //Instantiation of ahb_slave_bk_read_wrap_burst_seq handle
  ahb_slave_bk_read_wrap_burst_seq ahb_slave_bk_read_wrap_burst_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_bk_wrap_burst_read_seq");
  extern task body();
endclass : x2h_virtual_bk_wrap_burst_read_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - x2h_virtual_bk_wrap_burst_read_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_bk_wrap_burst_read_seq::new(string name = "x2h_virtual_bk_wrap_burst_read_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences
//--------------------------------------------------------------------------------------------
task x2h_virtual_bk_wrap_burst_read_seq::body();
  axi4_master_bk_read_wrap_burst_seq_h = axi4_master_bk_read_wrap_burst_seq::type_id::create("axi4_master_bk_read_wrap_burst_seq_h");

  ahb_slave_bk_read_wrap_burst_seq_h = ahb_slave_bk_read_wrap_burst_seq::type_id::create("ahb_slave_bk_read_wrap_burst_seq_h");

  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: Insdie axi4_virtual_bk_read_wrap_burst_seq"), UVM_NONE); 

  fork 
    begin : T2_SL_RD
      forever begin
        ahb_slave_bk_read_wrap_burst_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
      end
    end
  join_none


  fork 
    begin: T2_READ
      repeat(1) begin
      axi4_master_bk_read_wrap_burst_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
      end
    end
  join
 endtask : body

`endif




