`ifndef x2h_virtual_bk_single_narrow_transfer_seq_INCLUDED_
`define x2h_virtual_bk_single_narrow_transfer_seq_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_bk_single_narrow_transfer_seq
// Creates and starts the master and slave sequences
//--------------------------------------------------------------------------------------------
class x2h_virtual_bk_single_narrow_transfer_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_bk_single_narrow_transfer_seq)
  
  axi4_master_bk_single_narrow_transfer axi4_master_bk_single_narrow_transfer_h;
  
  ahb_slave_bk_single_narrow_transfer ahb_slave_bk_single_narrow_transfer_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_bk_single_narrow_transfer_seq");
  extern task body();
endclass : x2h_virtual_bk_single_narrow_transfer_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - axi4_virtual_bk_maximum_write_read_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_bk_single_narrow_transfer_seq::new(string name = "x2h_virtual_bk_single_narrow_transfer_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences
//--------------------------------------------------------------------------------------------
task x2h_virtual_bk_single_narrow_transfer_seq::body();

  axi4_master_bk_single_narrow_transfer_h = axi4_master_bk_single_narrow_transfer::type_id::create("axi4_master_bk_single_narrow_transfer_h");
  ahb_slave_bk_single_narrow_transfer_h = ahb_slave_bk_single_narrow_transfer::type_id::create("ahb_slave_bk_single_narrow_transfer_h");

  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: Inside x2h_virtual_bk_single_narrow_transfer_seq"), UVM_NONE); 

  fork 
      forever begin
        ahb_slave_bk_single_narrow_transfer_h.start(p_sequencer.ahb_slave_sequencer_h);
      end
  join_none


  fork 
    begin: T1_WRITE
      repeat(1) begin
        axi4_master_bk_single_narrow_transfer_h.start(p_sequencer.axi4_master_write_seqr_h);
      end
    end
  join
 endtask : body

`endif




