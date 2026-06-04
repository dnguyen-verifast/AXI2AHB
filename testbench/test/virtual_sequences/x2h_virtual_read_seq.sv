`ifndef X2H_VIRTUAL_READ_SEQ_INCLUDED_
`define X2H_VIRTUAL_READ_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_read_seq
// Creates and starts the master and slave sequences
//--------------------------------------------------------------------------------------------
class x2h_virtual_read_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_read_seq)

  //Variable: axi4_master_bk_read_seq_h
  //Instantiation of axi4_master_bk_read_seq handle
  axi4_master_bk_read_seq axi4_master_bk_read_seq_h;
  //Variable: axi4_master_nbk_read_seq_h
  //Instantiation of axi4_master_nbk_read_seq handle
  axi4_master_nbk_read_seq axi4_master_nbk_read_seq_h;

  //Variable: ahb_slave_read_seq_h
  //Instantiation of ahb_slave_read_seq handle
  ahb_slave_bk_read_seq ahb_slave_bk_read_seq_h;
  //Variable: ahb_slave_nbk_read_seq_h
  //Instantiation of ahb_slave_nbk_read_seq handle
  ahb_slave_nbk_read_seq ahb_slave_nbk_read_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_read_seq");
  extern task body();
endclass : x2h_virtual_read_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - x2h_virtual_read_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_read_seq::new(string name = "x2h_virtual_read_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences
//--------------------------------------------------------------------------------------------
task x2h_virtual_read_seq::body();
  axi4_master_bk_read_seq_h = axi4_master_bk_read_seq::type_id::create("axi4_master_bk_read_seq_h");
  axi4_master_nbk_read_seq_h = axi4_master_nbk_read_seq::type_id::create("axi4_master_nbk_read_seq_h");
  ahb_slave_bk_read_seq_h = ahb_slave_bk_read_seq::type_id::create("ahb_slave_bk_read_seq_h");
  ahb_slave_nbk_read_seq_h = ahb_slave_nbk_read_seq::type_id::create("ahb_slave_nbk_read_seq_h");
  repeat(3) begin
  fork
		begin : T1_BK
	 		ahb_slave_bk_read_seq_h.start(p_sequencer.ahb_slave_read_seqr_h);
		end
		begin : T2_BK
			 axi4_master_bk_read_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
		end
	join
end
fork
		forever begin
	 		ahb_slave_nbk_read_seq_h.start(p_sequencer.ahb_slave_read_seqr_h);
		end
join_none
		repeat(5) begin
			 axi4_master_nbk_read_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
		end
 endtask : body

`endif




