`ifndef AHB_VIRTUAL_BASE_SEQ_INCLUDE_
`define AHB_VIRTUAL_BASE_SEQ_INCLUDE_

class ahb_virtual_base_seq extends uvm_sequence;
    `uvm_object_utils(ahb_virtual_base_seq)

    `uvm_declare_p_sequencer(ahb_virtual_seqr)
    extern function new(string name="ahb_virtual_base_seq");
    extern task body();
endclass : ahb_virtual_base_seq
function ahb_virtual_base_seq::new(string name="ahb_virtual_base_seq");
  super.new(name);
endfunction:new

task ahb_virtual_base_seq::body();

  if(!$cast(p_sequencer,m_sequencer))begin
    `uvm_error(get_full_name(),"Virtual sequencer pointer cast failed")
  end
endtask:body
`endif