`ifndef X2H_VIRTUAL_WRITE_SEQ_INCLUDED_
`define X2H_VIRTUAL_WRITE_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_write_seq
// Creates and starts the master and slave sequences
//--------------------------------------------------------------------------------------------
class x2h_virtual_write_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_write_seq)

  //Variable: axi4_master_write_seq_h
  //Instantiation of axi4_master_write_seq handle
  axi4_master_bk_write_seq axi4_master_bk_write_seq_h;
  axi4_master_nbk_write_seq axi4_master_nbk_write_seq_h;

  //Variable: ahb_slave_write_seq_h
  //Instantiation of ahb_slave_write_seq handle
  ahb_slave_bk_write_seq ahb_slave_bk_write_seq_h;
  ahb_slave_nbk_write_seq ahb_slave_nbk_write_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_write_seq");
  extern task body();
endclass : x2h_virtual_write_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - x2h_virtual_write_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_write_seq::new(string name = "x2h_virtual_write_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences
//--------------------------------------------------------------------------------------------
task x2h_virtual_write_seq::body();
  axi4_master_bk_write_seq_h = axi4_master_bk_write_seq::type_id::create("axi4_master_bk_write_seq_h");
  axi4_master_nbk_write_seq_h = axi4_master_nbk_write_seq::type_id::create("axi4_master_nbk_write_seq_h");

  ahb_slave_bk_write_seq_h = ahb_slave_bk_write_seq::type_id::create("ahb_slave_bk_write_seq_h");
  ahb_slave_nbk_write_seq_h = ahb_slave_nbk_write_seq::type_id::create("ahb_slave_nbk_write_seq_h");
  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: Insdie x2h_virtual_write_seq"), UVM_NONE); 
  repeat(3) begin
  fork
		begin : T1_BK
	 		ahb_slave_bk_write_seq_h.start(p_sequencer.ahb_slave_write_seqr_h);
		end
		begin : T2_BK
			 axi4_master_bk_write_seq_h.start(p_sequencer.axi4_master_write_seqr_h);
		end
	join
end

fork
	begin : T1_NBK
		forever begin
	 		ahb_slave_nbk_write_seq_h.start(p_sequencer.ahb_slave_write_seqr_h);
		end
	end
join_none
		repeat(10) begin
			 axi4_master_nbk_write_seq_h.start(p_sequencer.axi4_master_write_seqr_h);
		end

 endtask : body


`endif




