`ifndef AXI4_MASTER_BK_HPROT_ALL_ENCODINGS_SEQ_INCLUDED_
`define AXI4_MASTER_BK_HPROT_ALL_ENCODINGS_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_hprot_all_encodings_seq
// Extends the axi4_master_bk_base_seq and sweeps every ARPROT encoding (0..7) so the bridge's
// HPROT generation is exercised for all data/instruction, secure/non-secure and
// privileged/normal combinations.
//--------------------------------------------------------------------------------------------
class axi4_master_bk_hprot_all_encodings_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_hprot_all_encodings_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_hprot_all_encodings_seq");
  extern task body();
endclass : axi4_master_bk_hprot_all_encodings_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_hprot_all_encodings_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_hprot_all_encodings_seq::new(string name = "axi4_master_bk_hprot_all_encodings_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Iterates over all eight ARPROT encodings, issuing one read per encoding
//--------------------------------------------------------------------------------------------
task axi4_master_bk_hprot_all_encodings_seq::body();
  super.body();
  for(int i = 0; i < 8; i++) begin
    start_item(req);
    if(!req.randomize() with {req.arsize   == READ_4_BYTES;
                              req.arlen    == 0;
                              req.tx_type  == READ;
                              req.arburst  == READ_INCR;
                              req.arprot   == arprot_e'(i);
                              req.transfer_type == BLOCKING_READ;}) begin
      `uvm_fatal("axi4","Rand failed");
    end
    req.print();
    finish_item(req);
  end

endtask : body

`endif
