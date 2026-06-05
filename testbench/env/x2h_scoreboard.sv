`ifndef X2H_SCOREBOARD_INCLUDE_
`define X2H_SCOREBOARD_INCLUDE_
typedef ahb_slave_tx queue_convert_w_axi2ahb[$];
typedef ahb_slave_tx queue_convert_r_axi2ahb[$];
class x2h_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(x2h_scoreboard)

    int ahb_data_phase_comparer_count = 0;
    int ahb_data_phase_comparer_count_pass = 0;
    int ahb_data_phase_comparer_count_failed = 0;

    int ahb_addr_phase_comparer_count = 0;
    int ahb_addr_phase_comparer_count_pass = 0;
    int ahb_addr_phase_comparer_count_failed = 0;


    axi4_master_tx axi4_master_tx_h1;
    axi4_master_tx axi4_master_tx_h2;
    axi4_master_tx axi4_master_tx_h3;
    axi4_master_tx axi4_master_tx_h4;
    axi4_master_tx axi4_master_tx_h5;

    //Variable : axi4_master_analysis_fifo
    //Used to store the axi4_master_data
    uvm_tlm_analysis_fifo#(axi4_master_tx) axi4_master_read_address_analysis_fifo;
    uvm_tlm_analysis_fifo#(axi4_master_tx) axi4_master_read_data_analysis_fifo;
    uvm_tlm_analysis_fifo#(axi4_master_tx) axi4_master_write_address_analysis_fifo;
    uvm_tlm_analysis_fifo#(axi4_master_tx) axi4_master_write_data_analysis_fifo;
    uvm_tlm_analysis_fifo#(axi4_master_tx) axi4_master_write_response_analysis_fifo;
    uvm_tlm_analysis_fifo#(axi4_slave_tx) axi4_slave_read_address_analysis_fifo;
    uvm_tlm_analysis_fifo#(axi4_slave_tx) axi4_slave_read_data_analysis_fifo;
    uvm_tlm_analysis_fifo#(axi4_slave_tx) axi4_slave_write_address_analysis_fifo;
    uvm_tlm_analysis_fifo#(axi4_slave_tx) axi4_slave_write_data_analysis_fifo;
    uvm_tlm_analysis_fifo#(axi4_slave_tx) axi4_slave_write_response_analysis_fifo;

    uvm_tlm_analysis_fifo #(ahb_slave_tx) ahb_slave_data_phase_analysis_fifo;
    uvm_tlm_analysis_fifo #(ahb_slave_tx) ahb_slave_addr_phase_analysis_fifo;
    uvm_tlm_analysis_fifo #(ahb_master_tx) ahb_master_data_phase_analysis_fifo;
    uvm_tlm_analysis_fifo #(ahb_master_tx) ahb_master_addr_phase_analysis_fifo;
    uvm_tlm_analysis_fifo #(ahb_master_tx) ahb_addr_phase_analysis_fifo_expect;
    uvm_tlm_analysis_fifo #(ahb_slave_tx) ahb_data_phase_analysis_fifo_expect;
    uvm_tlm_analysis_fifo #(ahb_master_tx) ahb_data_phase_for_write_analysis_fifo_expect;
  
  //master tx_count
  int axi4_master_tx_awaddr_count;
  //slave tx count
  int axi4_slave_tx_awaddr_count;
  
  //master tx_count
  int axi4_master_tx_wdata_count;
  //slave tx count
  int axi4_slave_tx_wdata_count;
  
  //master tx_count
  int axi4_master_tx_bresp_count;
  //slave tx count
  int axi4_slave_tx_bresp_count;
  
  //master tx_count
  int axi4_master_tx_araddr_count;
  //slave tx count
  int axi4_slave_tx_araddr_count;
  
  //master tx_count
  int axi4_master_tx_rdata_count;
  //slave tx count
  int axi4_slave_tx_rdata_count;
  
  //master tx_count
  int axi4_master_tx_rresp_count;
  //slave tx count
  int axi4_slave_tx_rresp_count;

    semaphore write_address_key;
    semaphore write_data_key;
    semaphore write_response_key;
    semaphore read_address_key;
    semaphore read_data_key;

    //-------------------------------------------------------
    // Externally defined Tasks and Functions
    //-------------------------------------------------------
    extern function new(string name = "x2h_scoreboard", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task predict_result_write_axi2ahb();
    extern virtual function queue_convert_w_axi2ahb convert_write_axi_packet_2_ahb_packet(input axi4_master_tx axi4_aw_tx, input axi4_master_tx axi4_w_tx);
    extern virtual task predict_result_read_axi2ahb();
    extern virtual function queue_convert_r_axi2ahb convert_read_axi_packet_2_ahb_packet(input axi4_master_tx axi4_ar_tx, input axi4_master_tx axi4_r_tx);
    extern virtual function void compare_w(input queue_convert_w_axi2ahb expect_queue_w);
    extern virtual function void compare_r(input queue_convert_r_axi2ahb expect_queue_r);
    extern virtual function void check_phase (uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
endclass : x2h_scoreboard

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - x2h_scoreboard
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function x2h_scoreboard::new(string name = "x2h_scoreboard",
                                 uvm_component parent = null);
  super.new(name, parent);
  axi4_master_write_address_analysis_fifo = new("axi4_master_write_address_analysis_fifo",this);
  axi4_master_write_data_analysis_fifo = new("axi4_master_write_data_analysis_fifo",this);
  axi4_master_write_response_analysis_fifo= new("axi4_master_write_response_analysis_fifo",this);
  axi4_master_read_address_analysis_fifo = new("axi4_master_read_address_analysis_fifo",this);
  axi4_master_read_data_analysis_fifo = new("axi4_master_read_data_analysis_fifo",this);

  ahb_slave_data_phase_analysis_fifo = new("ahb_slave_data_phase_analysis_fifo",this);
  ahb_slave_addr_phase_analysis_fifo = new("ahb_slave_addr_phase_analysis_fifo",this);
  ahb_data_phase_analysis_fifo_expect = new("ahb_data_phase_analysis_fifo_expect",this);

  write_address_key = new(1);
  write_data_key = new(1);
  write_response_key = new(1);
  read_address_key = new(1);
  read_data_key = new(1);

endfunction : new

//--------------------------------------------------------------------------------------------
// Function: build_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void x2h_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

//--------------------------------------------------------------------------------------------
// Function: connect_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void x2h_scoreboard::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase

//--------------------------------------------------------------------------------------------
// Function: end_of_elaboration_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void x2h_scoreboard::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
endfunction  : end_of_elaboration_phase

//--------------------------------------------------------------------------------------------
// Function: start_of_simulation_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void x2h_scoreboard::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase

//--------------------------------------------------------------------------------------------
// Task: run_phase
// All the comparision are done
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task x2h_scoreboard::run_phase(uvm_phase phase);

  super.run_phase(phase);

  fork
    predict_result_write_axi2ahb();
    predict_result_read_axi2ahb();
  join

endtask : run_phase

//--------------------------------------------------------------------------------------------
// Task: predict_result_write_axi2ahb
// Gets the master and slave write address and send it to the write address comparision task
//--------------------------------------------------------------------------------------------
task x2h_scoreboard::predict_result_write_axi2ahb();
  forever begin
    queue_convert_w_axi2ahb expect_queue_w;
    write_address_key.get(1);
    axi4_master_write_address_analysis_fifo.get(axi4_master_tx_h1);
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_write_address_channel \n%s",axi4_master_tx_h1.sprint()),UVM_LOW)
    axi4_master_write_data_analysis_fifo.get(axi4_master_tx_h2);
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_write_data_channel \n%s",axi4_master_tx_h2.sprint()),UVM_HIGH)
    expect_queue_w = convert_write_axi_packet_2_ahb_packet(axi4_master_tx_h1,axi4_master_tx_h2);
    axi4_master_write_response_analysis_fifo.get(axi4_master_tx_h3);
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_write_response_channel \n%s",axi4_master_tx_h3.sprint()),UVM_HIGH)

    compare_w(expect_queue_w);

    axi4_master_tx_awaddr_count++;
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_write_address_channel count \n %0d",axi4_master_tx_awaddr_count),UVM_HIGH)
     axi4_master_tx_wdata_count++;
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_write_data_channel count \n %0d",axi4_master_tx_wdata_count),UVM_HIGH)
    axi4_master_tx_bresp_count++;
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_write_response_channel count \n %0d",axi4_master_tx_bresp_count),UVM_HIGH)
    write_address_key.put(1);
  end

endtask : predict_result_write_axi2ahb

//--------------------------------------------------------------------------------------------
// Task: predict_result_read_axi2ahb
// Gets the master and slave write response and send it to the write response comparision task
//--------------------------------------------------------------------------------------------
task x2h_scoreboard::predict_result_read_axi2ahb();
  forever begin
    queue_convert_r_axi2ahb expect_queue_r;
    write_response_key.get(1);
    axi4_master_read_address_analysis_fifo.get(axi4_master_tx_h4);
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_read_address_channel \n%s",axi4_master_tx_h4.sprint()),UVM_HIGH)
    axi4_master_read_data_analysis_fifo.get(axi4_master_tx_h5);
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_read_data_channel \n%s",axi4_master_tx_h5.sprint()),UVM_HIGH)
    expect_queue_r = convert_read_axi_packet_2_ahb_packet(axi4_master_tx_h4,axi4_master_tx_h5);

    compare_r(expect_queue_r);

    axi4_master_tx_araddr_count++;
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_read_address_channel count \n %0d",axi4_master_tx_araddr_count),UVM_HIGH)
    axi4_master_tx_rdata_count++;
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_read_data_channel count \n %0d",axi4_master_tx_rdata_count),UVM_HIGH)
    axi4_master_tx_rresp_count++;
    `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_read_response_channel count \n %0d",axi4_master_tx_rresp_count),UVM_HIGH)
    write_response_key.put(1);

  end

endtask : predict_result_read_axi2ahb

//--------------------------------------------------------------------------------------------
// Task: convert_write_axi_packet_2_ahb_packet
// Gets the master and slave write data and send it to the write data comparision task
//--------------------------------------------------------------------------------------------
function queue_convert_w_axi2ahb x2h_scoreboard::convert_write_axi_packet_2_ahb_packet(
  input axi4_master_tx axi4_aw_tx, 
  input axi4_master_tx axi4_w_tx
);
  queue_convert_w_axi2ahb convert_queue;
  ahb_slave_tx convert_ahb;
  bit [2:0] size_bit;
  bit [31:0] start_addr    = axi4_aw_tx.awaddr;
  int        number_bytes  = 1 << axi4_aw_tx.awsize;
  int        burst_len     = axi4_aw_tx.awlen + 1;
  bit [31:0] aligned_addr  = (start_addr / number_bytes) * number_bytes;
  bit [31:0] current_addr;
 
  bit [31:0] wrap_boundary = (start_addr / (number_bytes * burst_len)) * (number_bytes * burst_len);
  bit [31:0] high_boundary = wrap_boundary + (number_bytes * burst_len);

  for(int i = 0; i <= axi4_aw_tx.awlen; i++) begin
    convert_ahb = ahb_slave_tx::type_id::create($sformatf("convert_ahb_%0d", i));
    if (i == 0) begin
      current_addr = start_addr;
    end 
    else begin
      if(axi4_aw_tx.awburst == WRITE_FIXED) begin
        current_addr = start_addr;
      end
      else if(axi4_aw_tx.awburst == WRITE_INCR) begin
        current_addr = aligned_addr + (i * number_bytes);
      end 
      else if(axi4_aw_tx.awburst == WRITE_WRAP) begin
        current_addr = aligned_addr + (i * number_bytes);
        if (current_addr >= high_boundary) begin
          current_addr = current_addr - (number_bytes * burst_len); // Quay vòng địa chỉ
        end
      end
    end

    convert_ahb.haddr  = current_addr;
    size_bit           = bit'(axi4_aw_tx.awsize);
    convert_ahb.hsize  = hsize_e'(size_bit);
    convert_ahb.hwrite = HWRITE_WRITE;
    
    if (i < axi4_w_tx.wdata.size()) begin
      convert_ahb.hwdata = axi4_w_tx.wdata[i];
    end else begin
      convert_ahb.hwdata = 0;
    end

    if (axi4_aw_tx.awburst == WRITE_FIXED) begin
      convert_ahb.htrans = HTRANS_NONSEQ; 
    end else begin
      convert_ahb.htrans = (i == 0) ? HTRANS_NONSEQ : HTRANS_SEQ;
    end
    convert_queue.push_back(convert_ahb);
  end

  return convert_queue;
endfunction : convert_write_axi_packet_2_ahb_packet
//--------------------------------------------------------------------------------------------
// Task: convert_read_axi_packet_2_ahb_packet
// Gets the master and slave read address and send it to the read address comparision task
//--------------------------------------------------------------------------------------------
function queue_convert_r_axi2ahb x2h_scoreboard::convert_read_axi_packet_2_ahb_packet(
  input axi4_master_tx axi4_ar_tx,
  input axi4_master_tx axi4_r_tx
);
  queue_convert_r_axi2ahb convert_queue;
  ahb_slave_tx convert_ahb;
  bit [2:0] size_bit;
  bit [31:0] start_addr    = axi4_ar_tx.araddr;
  int        number_bytes  = 1 << axi4_ar_tx.arsize; 
  int        burst_len     = axi4_ar_tx.arlen + 1;   
  bit [31:0] aligned_addr  = (start_addr / number_bytes) * number_bytes; 
  bit [31:0] current_addr;
  
  bit [31:0] wrap_boundary = (start_addr / (number_bytes * burst_len)) * (number_bytes * burst_len);
  bit [31:0] high_boundary = wrap_boundary + (number_bytes * burst_len);

  for(int i = 0; i <= axi4_ar_tx.arlen; i++) begin
    convert_ahb = ahb_slave_tx::type_id::create($sformatf("convert_ahb_r_%0d", i));
    
    if (i == 0) begin
      current_addr = start_addr; 
    end 
    else begin
      if(axi4_ar_tx.arburst == READ_FIXED) begin
        current_addr = start_addr; 
      end
      else if(axi4_ar_tx.arburst == READ_INCR) begin
        current_addr = aligned_addr + (i * number_bytes);
      end 
      else if(axi4_ar_tx.arburst == READ_WRAP) begin
        current_addr = aligned_addr + (i * number_bytes);
        if (current_addr >= high_boundary) begin
          current_addr = current_addr - (number_bytes * burst_len); 
        end
      end
    end

    convert_ahb.haddr  = current_addr;
    size_bit           = bit'(axi4_ar_tx.arsize);
    convert_ahb.hsize  = hsize_e'(size_bit);
    convert_ahb.hwrite = HWRITE_READ; 
    convert_ahb.hwdata = 32'h0;
    convert_ahb.hrdata = axi4_r_tx.rdata[i];

    if (axi4_ar_tx.arburst == READ_FIXED) begin
      convert_ahb.htrans = HTRANS_NONSEQ; 
    end else begin
      convert_ahb.htrans = (i == 0) ? HTRANS_NONSEQ : HTRANS_SEQ;
    end

    convert_queue.push_back(convert_ahb);
  end
  return convert_queue;
endfunction : convert_read_axi_packet_2_ahb_packet

//--------------------------------------------------------------------------------------------
// Task: compare_w
// Gets the master and slave read data and send it to the read data comparision task
//--------------------------------------------------------------------------------------------
function void x2h_scoreboard::compare_w(input queue_convert_w_axi2ahb expect_queue_w);
  ahb_slave_tx exp_tx;
  ahb_slave_tx act_addr_tx;
  ahb_slave_tx act_data_tx;

  axi4_master_tx_wdata_count++;
  `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_write_data_channel count \n %0d", axi4_master_tx_wdata_count), UVM_HIGH)
  axi4_master_tx_bresp_count++;
  `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_write_response_channel count \n %0d", axi4_master_tx_bresp_count), UVM_HIGH)

  while(expect_queue_w.size() > 0) begin
    exp_tx = expect_queue_w.pop_front();

    if (!ahb_slave_addr_phase_analysis_fifo.try_get(act_addr_tx)) begin
      `uvm_error("COMPARE_W_FIFO_EMPTY", "Missing data in ahb_slave_addr_phase_analysis_fifo!")
      return;
    end

    if (!ahb_slave_data_phase_analysis_fifo.try_get(act_data_tx)) begin
      `uvm_error("COMPARE_W_FIFO_EMPTY", "Missing data in ahb_slave_data_phase_analysis_fifo!")
      return;
    end

    if (exp_tx.haddr !== act_addr_tx.haddr) begin
      `uvm_error("MISMATCH_HADDR", $sformatf("HADDR mismatch! Exp: %0h, Act: %0h", exp_tx.haddr, act_addr_tx.haddr))
    end

    if (exp_tx.hwdata !== act_data_tx.hwdata) begin
      `uvm_error("MISMATCH_HWDATA", $sformatf("HWDATA mismatch at addr %0h! Exp: %0h, Act: %0h", exp_tx.haddr, exp_tx.hwdata, act_data_tx.hwdata))
    end

    if (exp_tx.hwrite !== act_addr_tx.hwrite) begin
      `uvm_error("MISMATCH_HWRITE", $sformatf("HWRITE mismatch at addr %0h! Exp: %0b, Act: %0b", exp_tx.haddr, exp_tx.hwrite, act_addr_tx.hwrite))
    end

    if (exp_tx.htrans !== act_addr_tx.htrans) begin
      `uvm_error("MISMATCH_HTRANS", $sformatf("HTRANS mismatch at addr %0h! Exp: %0s, Act: %0s", exp_tx.haddr, exp_tx.htrans.name(), act_addr_tx.htrans.name())) 
    end

    if (exp_tx.hsize !== act_addr_tx.hsize) begin
      `uvm_error("MISMATCH_HSIZE", $sformatf("HSIZE mismatch at addr %0h! Exp: %0d, Act: %0d", exp_tx.haddr, exp_tx.hsize, act_addr_tx.hsize))
    end
  end
endfunction : compare_w

function void x2h_scoreboard::compare_r(input queue_convert_r_axi2ahb expect_queue_r);
  ahb_slave_tx exp_tx;
  ahb_slave_tx act_addr_tx;
  ahb_slave_tx act_data_tx;

  axi4_master_tx_rdata_count++;
  `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_read_data_channel count \n %0d", axi4_master_tx_rdata_count), UVM_HIGH)
  axi4_master_tx_rresp_count++;
  `uvm_info(get_type_name(),$sformatf("scoreboard's axi4_master_read_response_channel count \n %0d", axi4_master_tx_rresp_count), UVM_HIGH)

  while(expect_queue_r.size() > 0) begin
    exp_tx = expect_queue_r.pop_front();

    if (!ahb_slave_addr_phase_analysis_fifo.try_get(act_addr_tx)) begin
      `uvm_error("COMPARE_R_FIFO_EMPTY", "Missing data in ahb_slave_addr_phase_analysis_fifo!")
      return;
    end

    if (!ahb_slave_data_phase_analysis_fifo.try_get(act_data_tx)) begin
      `uvm_error("COMPARE_R_FIFO_EMPTY", "Missing data in ahb_slave_data_phase_analysis_fifo!")
      return;
    end

    if (exp_tx.haddr !== act_addr_tx.haddr) begin
      `uvm_error("MISMATCH_HADDR", $sformatf("HADDR mismatch! Exp: %0h, Act: %0h", exp_tx.haddr, act_addr_tx.haddr))
    end

    if (exp_tx.hrdata !== act_data_tx.hrdata) begin
      `uvm_error("MISMATCH_HRDATA", $sformatf("HRDATA mismatch at addr %0h! Exp: %0h, Act: %0h", exp_tx.haddr, exp_tx.hrdata, act_data_tx.hrdata))
    end

    if (exp_tx.hwrite !== act_addr_tx.hwrite) begin
      `uvm_error("MISMATCH_HWRITE", $sformatf("HWRITE mismatch at addr %0h! Exp: %0b, Act: %0b", exp_tx.haddr, exp_tx.hwrite, act_addr_tx.hwrite))
    end

    if (exp_tx.htrans !== act_addr_tx.htrans) begin
      `uvm_error("MISMATCH_HTRANS", $sformatf("HTRANS mismatch at addr %0h! Exp: %0s, Act: %0s", exp_tx.haddr, exp_tx.htrans.name(), act_addr_tx.htrans.name())) 
    end

    if (exp_tx.hsize !== act_addr_tx.hsize) begin
      `uvm_error("MISMATCH_HSIZE", $sformatf("HSIZE mismatch at addr %0h! Exp: %0d, Act: %0d", exp_tx.haddr, exp_tx.hsize, act_addr_tx.hsize))
    end
  end

endfunction : compare_r
//--------------------------------------------------------------------------------------------
// Function: check_phase
// Display the result of simulation
//
// Parameters:
// phase - uvm phase
//--------------------------------------------------------------------------------------------
function void x2h_scoreboard::check_phase(uvm_phase phase);
  super.check_phase(phase);

  `uvm_info(get_type_name(),$sformatf("--\n----------------------------------------------SCOREBOARD CHECK PHASE---------------------------------------"),UVM_HIGH) 
  
  `uvm_info (get_type_name(),$sformatf(" Scoreboard Check Phase is starting"),UVM_HIGH); 

  //-------------------------------------------------------
  // Write_Address_Channel comparision
  // Write_Data_Channel comparision
  // Write_Response_Channel comparision
  //-------------------------------------------------------

  if((axi4_master_tx_awaddr_count != axi4_master_tx_wdata_count) && (axi4_master_tx_wdata_count != axi4_master_tx_bresp_count)) begin
    `uvm_error (get_type_name(), $sformatf ("Total number of packets from three channel of write are not same"));
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("Total number of packets from three channel of write are same, Number: %0d",axi4_master_tx_awaddr_count),UVM_HIGH);
  end
 
  //-------------------------------------------------------
  // Read_Address_Channel comparision
  // Read_Data_Channel comparision
  //-------------------------------------------------------
  if((axi4_master_tx_araddr_count != axi4_master_tx_rdata_count) && (axi4_master_tx_rdata_count != axi4_master_tx_rresp_count)) begin
    `uvm_error (get_type_name(), $sformatf ("Total number of packets from two channel of read are not same"));
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("Total number of packets from two channel of read are same, Number: %0d",axi4_master_tx_araddr_count),UVM_HIGH);
  end
  //--------------------------------------------------------------------------------------------
  // 2.Check if master packets received are same as slave packets received
  //   To Make sure that we have equal number of master and slave packets
  //--------------------------------------------------------------------------------------------
  
  //--------------------------------------------------------------------------------------------
  // 3.Analysis fifos must be zero - This will indicate that all the packets have been compared
  //   This is to make sure that we have taken all packets from both FIFOs and made the comparisions
  //--------------------------------------------------------------------------------------------
  //!!!! recommend use used() instead of size() to check the FIFO depth as used() will give the number of elements in the FIFO while size() will give the total capacity of the FIFO
  if (axi4_master_write_address_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf ("axi4 Master write address analysis FIFO is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("axi4_master_write_address_analysis_fifo:%0d",axi4_master_write_address_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("axi4 Master write address analysis FIFO is not empty"));
  end

  if (axi4_master_write_data_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf ("axi4 Master write data analysis FIFO is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("axi4_master_write_data_analysis_fifo:%0d",axi4_master_write_data_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("axi4 Master write data analysis FIFO is not empty"));
  end

  if (axi4_master_write_response_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf ("axi4 Master write response analysis FIFO is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("axi4_master_write_response_analysis_fifo:%0d",axi4_master_write_response_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("axi4 Master write response analysis FIFO is not empty"));
  end
 
  if (axi4_master_read_address_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf ("axi4 Master read address analysis FIFO is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("axi4_master_read_address_analysis_fifo:%0d",axi4_master_read_address_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("axi4 Master read address analysis FIFO is not empty"));
  end

  if (axi4_master_read_data_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf ("axi4 Master read data analysis FIFO is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("axi4_master_read_data_analysis_fifo:%0d",axi4_master_read_data_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("axi4 Master read data analysis FIFO is not empty"));
  end

  if (ahb_slave_data_phase_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf ("ahb_slave_data_phase_analysis_fifo is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("ahb_slave_data_phase_analysis_fifo:%0d",ahb_slave_data_phase_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("ahb_slave_data_phase_analysis_fifo is not empty"));
  end
  
  if (ahb_slave_addr_phase_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf ("ahb_slave_addr_phase_analysis_fifo is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("ahb_slave_addr_phase_analysis_fifo:%0d",ahb_slave_addr_phase_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("ahb_slave_addr_phase_analysis_fifo is not empty"));
  end

  
  `uvm_info(get_type_name(),$sformatf("--\n----------------------------------------------END OF SCOREBOARD CHECK PHASE---------------------------------------"),UVM_HIGH)

  `uvm_info(get_type_name(),$sformatf("--\n----------------------------------------------END OF SCOREBOARD CHECK PHASE---------------------------------------"),UVM_HIGH)

endfunction : check_phase

//--------------------------------------------------------------------------------------------
// Function: report_phase
// Display the result of simulation
//
// Parameters:
// phase - uvm phase
//--------------------------------------------------------------------------------------------
function void x2h_scoreboard::report_phase(uvm_phase phase);
  super.report_phase(phase);
  
  $display(" ");
  $display("-------------------------------------------- ");
  $display("SCOREBOARD REPORT PHASE");
  $display("-------------------------------------------- ");
  $display(" ");

  $display(" ");
  $display("-------------------------------------------- ");
  $display("SCOREBOARD WRITE ADDRESS PACKETS");
  $display("-------------------------------------------- ");
  $display(" ");
    `uvm_info(get_type_name(),$sformatf("scoreboard's write address packets count  from master   \n %0d",axi4_master_tx_awaddr_count),UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("scoreboard's write address packets count  from slave    \n %0d",axi4_slave_tx_awaddr_count),UVM_HIGH)
    //`uvm_info (get_type_name(),$sformatf("Total no. of byte wise awaddr verified comparisions:%0d",byte_data_cmp_verified_awaddr_count ),UVM_NONE);
  //`uvm_info (get_type_name(),$sformatf("Total no. of byte wise awaddr failed comparisions:%0d",byte_data_cmp_failed_awaddr_count ),UVM_NONE);
 
  $display(" ");
  $display("-------------------------------------------- ");
  $display("SCOREBOARD WRITE DATA PACKETS");
  $display("-------------------------------------------- ");
  $display(" ");
    `uvm_info(get_type_name(),$sformatf("scoreboard's  write data packets count from master \n %0d",axi4_master_tx_wdata_count),UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("scoreboard's  write data packets count from slave   \n %0d",axi4_slave_tx_wdata_count),UVM_HIGH)
  
  $display(" ");
  $display("-------------------------------------------- ");
  $display("SCOREBOARD WRITE RESPONSE PACKETS");
  $display("-------------------------------------------- ");
  $display(" ");
    `uvm_info(get_type_name(),$sformatf("scoreboard's write response packets count from master \n %0d",axi4_master_tx_bresp_count),UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("scoreboard's write response packets count from slave  \n %0d",axi4_slave_tx_bresp_count),UVM_HIGH)
  

  
  $display("-------------------------------------------- ");
  $display("READ_ADDRESS_PHASE");
  $display("-------------------------------------------- ");
  
  
  $display("READ_DATA_PHASE");
 
  $display(" ");
  $display("-------------------------------------------- ");
  $display("SCOREBOARD READ ADDRESS PACKETS");
  $display("-------------------------------------------- ");
  $display(" ");
    `uvm_info(get_type_name(),$sformatf("scoreboard's read address packets count from master \n %0d",axi4_master_tx_araddr_count),UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("scoreboard's read address packets count from slave  \n %0d",axi4_slave_tx_araddr_count),UVM_HIGH)
  
  $display(" ");
  $display("-------------------------------------------- ");
  $display("SCOREBOARD READ DATA PACKETS");
  $display("-------------------------------------------- ");
  $display(" ");
    `uvm_info(get_type_name(),$sformatf("scoreboard's  read data packets count from master \n %0d",axi4_master_tx_rdata_count),UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("scoreboard's  read data packets count from slave  \n %0d",axi4_slave_tx_rdata_count),UVM_HIGH)
  
  $display(" ");
  $display("-------------------------------------------- ");
  $display("SCOREBOARD READ RESPONSE PACKETS");
  $display("-------------------------------------------- ");
  $display(" ");
    `uvm_info(get_type_name(),$sformatf("scoreboard's read response packets count from master \n %0d",axi4_master_tx_rresp_count),UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("scoreboard's read response packets count from slave   \n %0d",axi4_slave_tx_rresp_count),UVM_HIGH)

endfunction : report_phase

`endif