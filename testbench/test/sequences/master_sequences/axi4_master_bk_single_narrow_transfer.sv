`ifndef axi4_master_bk_single_narrow_transfer_INCLUDED_
`define axi4_master_bk_single_narrow_transfer_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_master_bk_single_narrow_transfer
// Extends the axi4_master_base_seq and randomises the req item
//--------------------------------------------------------------------------------------------
class axi4_master_bk_single_narrow_transfer extends axi4_master_bk_base_seq;
  `uvm_object_utils(axi4_master_bk_single_narrow_transfer)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_master_bk_single_narrow_transfer");
  extern task body();
endclass : axi4_master_bk_single_narrow_transfer

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_master_bk_single_narrow_transfer
//--------------------------------------------------------------------------------------------
function axi4_master_bk_single_narrow_transfer::new(string name = "axi4_master_bk_single_narrow_transfer");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type master transaction and randomises the req
//--------------------------------------------------------------------------------------------
task axi4_master_bk_single_narrow_transfer::body();
  super.body();
  req.transfer_type=BLOCKING_READ;
  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: BEFORE axi4_master_bk_single_narrow_transfer"), UVM_NONE);

  repeat(5) begin
    start_item(req);
    if(!req.randomize() with {req.araddr % 4 !=0;
                                req.arsize == READ_1_BYTE;
                                req.tx_type == READ;
                                req.arlen == 0;
                                req.arburst == READ_INCR;
                                req.transfer_type == BLOCKING_READ;}) begin
      `uvm_fatal("axi4","Rand failed");
    end
    
    `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: master_seq \n%s",req.sprint()), UVM_NONE); 
    finish_item(req);
    `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: AFTER axi4_master_bk_single_narrow_transfer"), UVM_NONE); 

    start_item(req);
    if(!req.randomize() with {req.araddr % 4 !=0;
                                req.arsize == READ_2_BYTES;
                                req.tx_type == READ;
                                req.arlen == 0;
                                req.arburst == READ_WRAP;
                                req.transfer_type == BLOCKING_READ;}) begin
      `uvm_fatal("axi4","Rand failed");
    end
    `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: master_seq \n%s",req.sprint()), UVM_NONE); 
    finish_item(req);
    `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: AFTER axi4_master_bk_single_narrow_transfer"), UVM_NONE);
  end

  repeat(10) begin
    start_item(req);
    if(!req.randomize() with {req.awaddr % 4 !=0;
                                req.awsize <= 1;
                                req.tx_type == WRITE;
                                req.awlen   == 0;
                                req.transfer_type == BLOCKING_READ;}) begin
      `uvm_fatal("axi4","Rand failed");
    end
    
    `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: master_seq \n%s",req.sprint()), UVM_NONE); 
    finish_item(req);
    `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: AFTER axi4_master_bk_single_narrow_transfer"), UVM_NONE);
  end
endtask : body

`endif

