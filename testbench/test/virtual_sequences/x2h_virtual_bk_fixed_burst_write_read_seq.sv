`ifndef X2H_VIRTUAL_BK_FIXED_BURST_WRITE_READ_SEQ_INCLUDED_
`define X2H_VIRTUAL_BK_FIXED_BURST_WRITE_READ_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_bk_fixed_burst_write_read_seq
// Creates and starts the master and slave sequences
//--------------------------------------------------------------------------------------------
class x2h_virtual_bk_fixed_burst_write_read_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_bk_fixed_burst_write_read_seq)

  //Variable: axi4_master_write_fixed_burst_seq_h
  //Instantiation of axi4_master_write_fixed_burst_seq handle
  axi4_master_bk_write_fixed_burst_seq axi4_master_bk_write_fixed_burst_seq_h;
  
  //Variable: axi4_master_read_fixed_burst_seq_h
  //Instantiation of axi4_master_read_fixed_burst_seq handle
  axi4_master_bk_read_fixed_burst_seq axi4_master_bk_read_fixed_burst_seq_h;

  //Variable: ahb_slave_write_fixed_burst_seq_h
  //Instantiation of ahb_slave_write_fixed_burst_seq handle
  ahb_slave_bk_write_fixed_burst_seq ahb_slave_bk_write_fixed_burst_seq_h;
  
  //Variable: ahb_slave_read_fixed_burst_seq_h
  //Instantiation of ahb_slave_read_fixed_burst_seq handle
  ahb_slave_bk_read_fixed_burst_seq ahb_slave_bk_read_fixed_burst_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_bk_fixed_burst_write_read_seq");
  extern task body();
endclass : x2h_virtual_bk_fixed_burst_write_read_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - x2h_virtual_bk_fixed_burst_write_read_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_bk_fixed_burst_write_read_seq::new(string name = "x2h_virtual_bk_fixed_burst_write_read_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences
//--------------------------------------------------------------------------------------------
task x2h_virtual_bk_fixed_burst_write_read_seq::body();
  axi4_master_bk_write_fixed_burst_seq_h = axi4_master_bk_write_fixed_burst_seq::type_id::create("axi4_master_bk_write_fixed_burst_seq_h");
  axi4_master_bk_read_fixed_burst_seq_h = axi4_master_bk_read_fixed_burst_seq::type_id::create("axi4_master_bk_read_fixed_burst_seq_h");

  ahb_slave_bk_write_fixed_burst_seq_h = ahb_slave_bk_write_fixed_burst_seq::type_id::create("ahb_slave_bk_write_fixed_burst_seq_h");
  ahb_slave_bk_read_fixed_burst_seq_h = ahb_slave_bk_read_fixed_burst_seq::type_id::create("ahb_slave_bk_read_fixed_burst_seq_h");

  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: Insdie x2h_virtual_bk_fixed_burst_write_read_seq"), UVM_NONE); 

  fork 
      forever begin
        ahb_slave_bk_write_fixed_burst_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
      end
  join_none


  fork 
    begin: T1_WRITE_READ
      repeat(2) begin
        axi4_master_bk_write_fixed_burst_seq_h.start(p_sequencer.axi4_master_write_seqr_h);
      end
    end
    // begin: T2_READ
    //   repeat(3) begin
    //     axi4_master_bk_read_fixed_burst_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
    //   end
    // end
  join
 endtask : body

`endif




