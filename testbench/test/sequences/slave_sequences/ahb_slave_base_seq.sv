`ifndef ahb_SLAVE_BASE_SEQ_INCLUDED_
`define ahb_SLAVE_BASE_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: ahb_slave_base_seq 
// creating ahb_slave_base_seq class extends from uvm_sequence
//--------------------------------------------------------------------------------------------
class ahb_slave_base_seq extends uvm_sequence #(ahb_slave_tx);
 
  //factory registration
  `uvm_object_utils(ahb_slave_base_seq)

  //-------------------------------------------------------
  // Externally defined Function
  //-------------------------------------------------------
  extern function new(string name = "ahb_slave_base_seq");
endclass : ahb_slave_base_seq

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the ahb_slave_sequence class object
//
// Parameters:
//  name - instance name of the config_template
//-----------------------------------------------------------------------------
function ahb_slave_base_seq::new(string name = "ahb_slave_base_seq");
  super.new(name);
endfunction : new

`endif

