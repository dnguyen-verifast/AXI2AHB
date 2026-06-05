`ifndef X2H_VIRTUAL_BASE_SEQ_INCLUDED_
`define X2H_VIRTUAL_BASE_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
//Class: x2h_virtual_base_seq
// Description:
// This class contains the handle of actual sequencer pointing towards them
//--------------------------------------------------------------------------------------------
class x2h_virtual_base_seq extends uvm_sequence;
  `uvm_object_utils(x2h_virtual_base_seq)

   //p sequencer macro declaration 
   `uvm_declare_p_sequencer(x2h_virtual_sequencer)

  //--------------------------------------------------------------------------------------------
  // Externally defined tasks and functions
  //--------------------------------------------------------------------------------------------
  extern function new(string name="x2h_virtual_base_seq");
  extern task body();

endclass:x2h_virtual_base_seq

//--------------------------------------------------------------------------------------------
//Constructor:new
//
//Paramters:
//name - Instance name of the virtual_sequence
//parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function x2h_virtual_base_seq::new(string name="x2h_virtual_base_seq");
  super.new(name);
endfunction:new

//--------------------------------------------------------------------------------------------
//task:body
//Creates the required ports
//
//Parameters:
// phase - stores the current phase
//--------------------------------------------------------------------------------------------
task x2h_virtual_base_seq::body();

  if(!$cast(p_sequencer,m_sequencer))begin
    `uvm_error(get_full_name(),"Virtual sequencer pointer cast failed")
  end
endtask:body

`endif


