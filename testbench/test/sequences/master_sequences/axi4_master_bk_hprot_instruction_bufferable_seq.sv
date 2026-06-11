`ifndef AXI4_MASTER_BK_HPROT_INSTRUCTION_BUFFERABLE_SEQ_INCLUDED_
`define AXI4_MASTER_BK_HPROT_INSTRUCTION_BUFFERABLE_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_hprot_instruction_bufferable_seq
// Extends the axi4_master_bk_base_seq and randomises the req item for HPROT instruction/bufferable
//--------------------------------------------------------------------------------------------
class axi4_master_bk_hprot_instruction_bufferable_seq extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_hprot_instruction_bufferable_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_hprot_instruction_bufferable_seq");
  extern task body();
endclass : axi4_master_bk_hprot_instruction_bufferable_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_hprot_instruction_bufferable_seq
//--------------------------------------------------------------------------------------------
function axi4_master_bk_hprot_instruction_bufferable_seq::new(string name = "axi4_master_bk_hprot_instruction_bufferable_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type master_bk transaction with HPROT instruction and bufferable settings
//--------------------------------------------------------------------------------------------
task axi4_master_bk_hprot_instruction_bufferable_seq::body();
  super.body(); 
begin
  start_item(req);
  if(!req.randomize() with {req.arsize == READ_4_BYTES;
                            req.arlen  == 4; 
                            req.tx_type == READ;
                            req.arburst == READ_INCR;
                            req.transfer_type == BLOCKING_READ;
                            req.arprot[0] == 1; // Instruction bit
                            req.arprot[1] == 0; // Non-secure
                            req.arprot[2] == 0; // Non-privileged
                            req.arcache[0] == 1; // Bufferable
                            req.arcache[1] == 0; // Non-modifiable
                            req.arcache[2] == 0; // Non-allocate
                            req.arcache[3] == 0; // Non-allocate}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

  // Send another request with instruction attribute
  start_item(req);
  if(!req.randomize() with {req.awsize == WRITE_4_BYTES;
                            req.awlen  == 4; 
                            req.tx_type == WRITE;
                            req.awburst == WRITE_INCR;
                            req.transfer_type == BLOCKING_WRITE;
                            req.awprot[0] == 1; // Instruction bit
                            req.awprot[1] == 0; // Non-secure
                            req.awprot[2] == 0; // Non-privileged
                            req.awcache[0] == 1; // Bufferable
                            req.awcache[1] == 0; // Non-modifiable
                            req.awcache[2] == 0; // Non-allocate
                            req.awcache[3] == 0; // Non-allocate}) begin

    `uvm_fatal("axi4","Rand failed");
  end
  req.print();
  finish_item(req);

end
endtask : body

`endif
