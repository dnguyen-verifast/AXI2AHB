`ifndef X2H_VIRTUAL_BK_HPROT_PRIVILEGED_DATA_SEQ_INCLUDED_
`define X2H_VIRTUAL_BK_HPROT_PRIVILEGED_DATA_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_bk_hprot_privileged_data_seq
// Creates and starts the master and slave sequences for HPROT privileged data
//--------------------------------------------------------------------------------------------
class x2h_virtual_bk_hprot_privileged_data_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_bk_hprot_privileged_data_seq)

  //Variable: axi4_master_bk_hprot_privileged_data_seq_h
  //Instantiation of axi4_master_bk_hprot_privileged_data_seq handle
  axi4_master_bk_hprot_privileged_data_seq axi4_master_bk_hprot_privileged_data_seq_h;

  //Variable: ahb_slave_bk_hprot_privileged_data_seq_h
  //Instantiation of ahb_slave_bk_hprot_privileged_data_seq handle
  ahb_slave_bk_hprot_privileged_data_seq ahb_slave_bk_hprot_privileged_data_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_bk_hprot_privileged_data_seq");
  extern task body();
endclass : x2h_virtual_bk_hprot_privileged_data_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - x2h_virtual_bk_hprot_privileged_data_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_bk_hprot_privileged_data_seq::new(string name = "x2h_virtual_bk_hprot_privileged_data_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences with HPROT privileged data
//--------------------------------------------------------------------------------------------
task x2h_virtual_bk_hprot_privileged_data_seq::body();
  axi4_master_bk_hprot_privileged_data_seq_h = axi4_master_bk_hprot_privileged_data_seq::type_id::create("axi4_master_bk_hprot_privileged_data_seq_h");

  ahb_slave_bk_hprot_privileged_data_seq_h = ahb_slave_bk_hprot_privileged_data_seq::type_id::create("ahb_slave_bk_hprot_privileged_data_seq_h");

  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: Inside x2h_virtual_bk_hprot_privileged_data_seq"), UVM_NONE); 

  fork 
    begin : T1_SL_PRIV_DATA
      forever begin
        ahb_slave_bk_hprot_privileged_data_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
      end
    end
  join_none

  fork 
    begin: T1_HPROT_PRIV_DATA
      repeat(2) begin
        axi4_master_bk_hprot_privileged_data_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
      end
    end
  join

endtask : body

`endif
