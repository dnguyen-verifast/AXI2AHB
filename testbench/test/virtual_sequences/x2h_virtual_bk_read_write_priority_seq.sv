`ifndef X2H_VIRTUAL_BK_READ_WRITE_PRIORITY_SEQ_INCLUDED_
`define X2H_VIRTUAL_BK_READ_WRITE_PRIORITY_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_bk_read_write_priority_seq
// Creates and starts the master and slave sequences for read/write priority
//--------------------------------------------------------------------------------------------
class x2h_virtual_bk_read_write_priority_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_bk_read_write_priority_seq)

  //Variable: axi4_master_bk_read_write_priority_seq_h
  //Instantiation of axi4_master_bk_read_write_priority_seq handle
  axi4_master_bk_read_priority_seq axi4_master_bk_read_priority_seq_h;
  axi4_master_bk_write_priority_seq axi4_master_bk_write_priority_seq_h;

  //Variable: ahb_slave_bk_read_write_priority_seq_h
  //Instantiation of ahb_slave_bk_read_write_priority_seq handle
  ahb_slave_bk_read_write_priority_seq ahb_slave_bk_read_write_priority_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_bk_read_write_priority_seq");
  extern task body();
endclass : x2h_virtual_bk_read_write_priority_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - x2h_virtual_bk_read_write_priority_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_bk_read_write_priority_seq::new(string name = "x2h_virtual_bk_read_write_priority_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences for priority testing
//--------------------------------------------------------------------------------------------
task x2h_virtual_bk_read_write_priority_seq::body();
  axi4_master_bk_read_priority_seq_h = axi4_master_bk_read_priority_seq::type_id::create("axi4_master_bk_read_priority_seq_h");
  axi4_master_bk_write_priority_seq_h = axi4_master_bk_write_priority_seq::type_id::create("axi4_master_bk_write_priority_seq_h");
  ahb_slave_bk_read_write_priority_seq_h = ahb_slave_bk_read_write_priority_seq_h::type_id::create("ahb_slave_bk_read_write_priority_seq_h");

  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: Inside x2h_virtual_bk_read_write_priority_seq"), UVM_NONE); 

  fork 
    begin : T1_SL_PRIORITY
      forever begin
        ahb_slave_bk_read_write_priority_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
      end
    end
  join_none

  fork 
    begin: T1_PRIORITY_READ
      repeat(1) begin
        axi4_master_bk_read_priority_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
      end
    end
    begin : T2_PRIORITY_WRITE
      repeat(1) begin
        axi4_master_bk_write_priority_seq_h.start(p_sequencer.axi4_master_write_seqr_h);
      end
    end

  join

endtask : body

`endif
