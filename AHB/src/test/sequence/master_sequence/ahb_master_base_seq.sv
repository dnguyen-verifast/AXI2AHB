`ifndef AHB_MASTER_SEQ_BASE_INCLUDED_
`define AHB_MASTER_SEQ_BASE_INCLUDED_

class ahb_master_base_seq extends uvm_sequence #(ahb_master_tx);
  `uvm_object_utils(ahb_master_base_seq)
  `uvm_declare_p_sequencer(ahb_master_sequencer)
  ahb_master_tx req_m;
  extern function new(string name = "ahb_master_base_seq");
  extern task body();
  
  // --- define API functions ---
  extern function int get_burst_len(hburst_e burst_type);
  extern function bit [31:0] calculate_wrap_address(bit [31:0] current_addr, hsize_e hsize, hburst_e hburst);
  extern task do_idle(input int num_clk, input bit [31:0] addr_idle);
  extern task do_burst_transfer(
    input bit [31:0] start_addr, 
    input hwrite_e  is_write, 
    input hburst_e burst_type, 
    input hsize_e size,
    input int      busy_chance_pct = 0,
    input int      undef_incr_len = 1
  );

endclass : ahb_master_base_seq

// =======================================================================
// CHI TIẾT IMPLEMENTATION
// =======================================================================

function ahb_master_base_seq::new(string name = "ahb_master_base_seq");
  super.new(name);
endfunction : new

task ahb_master_base_seq::body();
    req_m = ahb_master_tx::type_id::create("req_m");
endtask : body

function int ahb_master_base_seq::get_burst_len( hburst_e burst_type);
  `uvm_info("SEQ master", "Inside get_burst_len of AHB SEQ master", UVM_LOW)
  case (burst_type)
    SINGLE      : return 1;  // SINGLE / INCR(undefine length)
    WRAP4, INCR4: return 4;  // WRAP4, INCR4
    WRAP8, INCR8: return 8;  // WRAP8, INCR8
    WRAP16, INCR16: return 16; // WRAP16, INCR16
    default: return 1;
  endcase
endfunction

function bit [31:0] ahb_master_base_seq::calculate_wrap_address(bit [31:0] current_addr, hsize_e hsize, hburst_e hburst);
  int bytes_per_beat = 1 << hsize; 
  int burst_length = get_burst_len(hburst);
  int total_wrap_bytes = bytes_per_beat * burst_length; 
  bit [31:0] wrap_boundary = current_addr & ~(total_wrap_bytes - 1);
  bit [31:0] next_addr = current_addr + bytes_per_beat;
  `uvm_info("SEQ master", "Inside calculate_wrap_address of AHB SEQ master", UVM_LOW)
  if (next_addr == (wrap_boundary + total_wrap_bytes)) begin
    next_addr = wrap_boundary;
  end
  return next_addr;
endfunction

task ahb_master_base_seq::do_idle(input int num_clk, input bit [31:0] addr_idle);
  ahb_master_tx req_m;
  for(int i = 0; i < num_clk; i++) begin
    req_m = ahb_master_tx::type_id::create("req_m");
    start_item(req_m);
    assert(req_m.randomize() with {
      req_m.htrans == HTRANS_IDLE;
      req_m.haddr == local::addr_idle;
    });
    `uvm_info("SEQ master", $sformatf("Driving IDLE phase %0d/%0d", i+1, num_clk), UVM_LOW)
    finish_item(req_m);
  end    
endtask : do_idle

task ahb_master_base_seq::do_burst_transfer(
    input bit [31:0] start_addr, 
    input hwrite_e  is_write, 
    input hburst_e burst_type, 
    input hsize_e size,
    input int      busy_chance_pct = 0,
    input int      undef_incr_len = 1
);
  //ahb_master_tx req_m;
  ahb_master_tx cloned_req;
  ahb_master_tx cloned_req1;
  bit [31:0] current_addr = start_addr;
  int burst_len;

  if(burst_type == INCR) begin
    burst_len = undef_incr_len;
  end else burst_len = get_burst_len(burst_type);

  `uvm_info("SEQ master", $sformatf("burst_len = %d \n",burst_len), UVM_LOW)

  for (int i = 0; i < burst_len; i++) begin
    `uvm_info("SEQ master", "Inside do_burst_transfer of AHB SEQ master", UVM_LOW)
    if (i > 0 && busy_chance_pct > 0) begin
      // randomize insert BUSY
      while ($urandom_range(0, 100) < busy_chance_pct) begin
        req_m = ahb_master_tx::type_id::create("req_m_busy");
        start_item(req_m);
        assert(req_m.randomize() with {
          htrans == HTRANS_BUSY; // BUSY
          hsize  == local::size; // Chữ local:: sinh ra để chỉ định tường minh: "Ê trình biên dịch, biến này chắc chắn là của cái scope bên ngoài, đừng có tìm bên trong object nhé!".
          hburst == local::burst_type;
          hwrite == local::is_write;
          req_m.haddr == local::current_addr;
        });
        `uvm_info("SEQ master", $sformatf("req_m = %s \n",req_m.sprint()), UVM_LOW)
        finish_item(req_m);
      end
    end
    req_m = ahb_master_tx::type_id::create("req_m");
    start_item(req_m);
    assert(req_m.randomize() with {
      hsize  == local::size;
      hburst == local::burst_type;
      hwrite == local::is_write;
      if (local::i == 0) {
        htrans == HTRANS_NONSEQ;
      } else {
        htrans == HTRANS_SEQ;}
      req_m.haddr == local::current_addr; 
    });
    
    `uvm_info("SEQ master", $sformatf("req_m = %s \n",req_m.sprint()), UVM_LOW)
    $cast(cloned_req, req_m.clone());
    p_sequencer.seq_expect_item_port.write(cloned_req);

    if(req_m.hwrite == HWRITE_WRITE) begin
      $cast(cloned_req1, req_m.clone());
      p_sequencer.seq_expect_write_item_port.write(cloned_req1);
    end
    finish_item(req_m);
    
    if (burst_type == INCR || burst_type == INCR4 || burst_type == INCR8 || burst_type == INCR16) begin // INCR
       current_addr = current_addr + (1 << size);
    end
    else if (burst_type == WRAP4 || burst_type == WRAP8 || burst_type == WRAP16) begin // WRAP
       current_addr = calculate_wrap_address(current_addr, size, burst_type);
    end
    
  end
endtask : do_burst_transfer

`endif