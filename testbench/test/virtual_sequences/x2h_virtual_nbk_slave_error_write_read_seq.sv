`ifndef X2H_VIRTUAL_NBK_SLAVE_ERROR_WRITE_READ_SEQ_INCLUDED_
`define X2H_VIRTUAL_NBK_SLAVE_ERROR_WRITE_READ_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: x2h_virtual_nbk_slave_error_write_read_seq
// Creates and starts the master and slave sequences
//--------------------------------------------------------------------------------------------
class x2h_virtual_nbk_slave_error_write_read_seq extends x2h_virtual_base_seq;
  `uvm_object_utils(x2h_virtual_nbk_slave_error_write_read_seq)

  //Variable: axi4_master_write_slave_error_seq_h
  //Instantiation of axi4_master_write_slave_error_transfer_seq handle
  axi4_master_nbk_write_slave_error_seq axi4_master_nbk_write_slave_error_seq_h;
  
  //Variable: axi4_master_read_slave_error_seq_h
  //Instantiation of axi4_master_read_slave_error_transfer_seq handle
  axi4_master_nbk_read_slave_error_seq axi4_master_nbk_read_slave_error_seq_h;

  //Variable: ahb_slave_write_slave_error_seq_h
  //Instantiation of ahb_slave_write_slave_error_transfer_seq handle
  ahb_slave_nbk_write_slave_error_seq ahb_slave_nbk_write_slave_error_seq_h;
  
  //Variable: ahb_slave_read_slave_error_seq_h
  //Instantiation of ahb_slave_read_slave_error_transfer_seq handle
  ahb_slave_nbk_read_slave_error_seq ahb_slave_nbk_read_slave_error_seq_h;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "x2h_virtual_nbk_slave_error_write_read_seq");
  extern task body();
endclass : x2h_virtual_nbk_slave_error_write_read_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialises new memory for the object
//
// Parameters:
//  name - x2h_virtual_nbk_slave_error_write_read_seq
//--------------------------------------------------------------------------------------------
function x2h_virtual_nbk_slave_error_write_read_seq::new(string name = "x2h_virtual_nbk_slave_error_write_read_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task - body
// Creates and starts the data of master and slave sequences
//--------------------------------------------------------------------------------------------
task x2h_virtual_nbk_slave_error_write_read_seq::body();
  queue_info_ctrl_s queue_info_ctrl_h, queue_info_ctrl_h1;
  axi4_master_nbk_write_slave_error_seq_h = axi4_master_nbk_write_slave_error_seq::type_id::create("axi4_master_nbk_write_slave_error_seq_h");

  axi4_master_nbk_read_slave_error_seq_h = axi4_master_nbk_read_slave_error_seq::type_id::create("axi4_master_nbk_read_slave_error_seq_h");
  ahb_slave_nbk_write_slave_error_seq_h = ahb_slave_nbk_write_slave_error_seq::type_id::create("ahb_slave_nbk_write_slave_error_seq_h");

  ahb_slave_nbk_read_slave_error_seq_h = ahb_slave_nbk_read_slave_error_seq::type_id::create("ahb_slave_nbk_read_slave_error_seq_h");
  `uvm_info(get_type_name(), $sformatf("DEBUG_MSHA :: Insdie x2h_virtual_nbk_slave_error_write_read_seq"), UVM_NONE); 

  fork 
    begin : T1_SL_WR
      forever begin
        ahb_slave_nbk_write_slave_error_seq_h.start(p_sequencer.ahb_slave_write_seqr_h);
      end
    end
    begin : T2_SL_RD
      forever begin
        ahb_slave_nbk_read_slave_error_seq_h.start(p_sequencer.ahb_slave_read_seqr_h);
      end
    end
  join_none


  fork 
    begin: T1_WRITE
      repeat(3) begin
        axi4_master_nbk_write_slave_error_seq_h.start(p_sequencer.axi4_master_write_seqr_h);
        queue_info_ctrl_h.addr = axi4_master_nbk_write_slave_error_seq_h.req.awaddr; 
        queue_info_ctrl_h.id = axi4_master_nbk_write_slave_error_seq_h.req.awid;
        p_sequencer.queue_info_ctrl.push_back(queue_info_ctrl_h);
      end
    end
    begin: T2_READ
      repeat(3) begin
        wait(p_sequencer.queue_info_ctrl.size() > 0);
        queue_info_ctrl_h1 = p_sequencer.queue_info_ctrl.pop_front();
        axi4_master_nbk_read_slave_error_seq_h.queue_info_ctrl_r.addr = queue_info_ctrl_h1.addr;
        axi4_master_nbk_read_slave_error_seq_h.queue_info_ctrl_r.id = queue_info_ctrl_h1.id;
        axi4_master_nbk_read_slave_error_seq_h.start(p_sequencer.axi4_master_read_seqr_h);
      end
    end
  join
 endtask : body

`endif




