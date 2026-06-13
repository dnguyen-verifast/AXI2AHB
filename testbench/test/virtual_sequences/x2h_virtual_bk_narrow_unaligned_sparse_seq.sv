`ifndef x2h_virtual_bk_narrow_unaligned_sparse_seq_INCLUDED_
`define x2h_virtual_bk_narrow_unaligned_sparse_seq_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_bk_narrow_unaligned_sparse_seq
// Creates and starts the master and slave sequences
//--------------------------------------------------------------------------------------------
class x2h_virtual_bk_narrow_unaligned_sparse_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_bk_narrow_unaligned_sparse_seq)

  //Variable: axi4_master_write_unaligned_addr_seq_h
  //Instantiation of axi4_master_write_unaligned_addr_seq handle
  axi4_master_bk_write_unaligned_addr_seq axi4_master_bk_write_unaligned_addr_seq_h;
  
  //Variable: axi4_master_read_unaligned_addr_seq_h
  //Instantiation of axi4_master_read_unaligned_addr_seq handle
  axi4_master_bk_read_unaligned_addr_seq axi4_master_bk_read_unaligned_addr_seq_h;

  //Variable: ahb_slave_write_unaligned_addr_seq_h
  //Instantiation of ahb_slave_write_unaligned_addr_seq handle
  ahb_slave_bk_write_unaligned_addr_seq ahb_slave_bk_write_unaligned_addr_seq_h;
  
  //Variable: ahb_slave_read_unaligned_addr_seq_h
  //Instantiation of ahb_slave_read_unaligned_addr_seq handle
  ahb_slave_bk_read_unaligned_addr_seq ahb_slave_bk_read_unaligned_addr_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_bk_narrow_unaligned_sparse_seq");
  extern task body();
endclass : x2h_virtual_bk_narrow_unaligned_sparse_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - axi4_virtual_bk_maximum_write_read_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_bk_narrow_unaligned_sparse_seq::new(string name = "x2h_virtual_bk_narrow_unaligned_sparse_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences
//--------------------------------------------------------------------------------------------
task x2h_virtual_bk_narrow_unaligned_sparse_seq::body();
  axi4_master_bk_write_unaligned_addr_seq_h = axi4_master_bk_write_unaligned_addr_seq::type_id::create("axi4_master_bk_write_unaligned_addr_seq_h");

  axi4_master_bk_read_unaligned_addr_seq_h = axi4_master_bk_read_unaligned_addr_seq::type_id::create("axi4_master_bk_read_unaligned_addr_seq_h");
  ahb_slave_bk_write_unaligned_addr_seq_h = ahb_slave_bk_write_unaligned_addr_seq::type_id::create("ahb_slave_bk_write_unaligned_addr_seq_h");

  ahb_slave_bk_read_unaligned_addr_seq_h = ahb_slave_bk_read_unaligned_addr_seq::type_id::create("ahb_slave_bk_read_unaligned_addr_seq_h");
  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: Inside x2h_virtual_bk_narrow_unaligned_sparse_seq"), UVM_NONE); 

  fork 
      forever begin
        ahb_slave_bk_write_unaligned_addr_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
      end
  join_none


  fork 
    begin: T1_WRITE
      repeat(2) begin
        axi4_master_bk_write_unaligned_addr_seq_h.start(p_sequencer.axi4_master_write_seqr_h);
      end
    end
    begin: T2_READ
      repeat(5) begin
        axi4_master_bk_read_unaligned_addr_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
      end
    end
  join
 endtask : body

`endif




