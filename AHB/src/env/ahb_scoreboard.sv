`ifndef AHB_SCOREBOARD_INCLUDED_
`define AHB_SCOREBOARD_INCLUDED_

class ahb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ahb_scoreboard);


    int ahb_data_phase_comparer_count = 0;
    int ahb_data_phase_comparer_count_pass = 0;
    int ahb_data_phase_comparer_count_failed = 0;

    int ahb_addr_phase_comparer_count = 0;
    int ahb_addr_phase_comparer_count_pass = 0;
    int ahb_addr_phase_comparer_count_failed = 0;

    semaphore data_phase_key;
    semaphore addr_phase_key;

    uvm_tlm_analysis_fifo #(ahb_slave_tx) ahb_slave_data_phase_analysis_fifo;
    uvm_tlm_analysis_fifo #(ahb_slave_tx) ahb_slave_addr_phase_analysis_fifo;
    
    uvm_tlm_analysis_fifo #(ahb_master_tx) ahb_master_data_phase_analysis_fifo;
    uvm_tlm_analysis_fifo #(ahb_master_tx) ahb_master_addr_phase_analysis_fifo;

    uvm_tlm_analysis_fifo #(ahb_master_tx) ahb_addr_phase_analysis_fifo_expect;

    uvm_tlm_analysis_fifo #(ahb_slave_tx) ahb_data_phase_analysis_fifo_expect;
    uvm_tlm_analysis_fifo #(ahb_master_tx) ahb_data_phase_for_write_analysis_fifo_expect;
    
    extern function new(string name="ahb_scoreboard", uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    extern virtual task ahb_data_phase_compare();
    extern virtual task ahb_addr_phase_compare();

    extern virtual function void check_phase (uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
endclass : ahb_scoreboard

function ahb_scoreboard::new(string name="ahb_scoreboard", uvm_component parent=null);
    super.new(name,parent);
    ahb_slave_data_phase_analysis_fifo = new("ahb_slave_data_phase_analysis_fifo",this);
    ahb_master_data_phase_analysis_fifo = new("ahb_master_data_phase_analysis_fifo",this);
    ahb_slave_addr_phase_analysis_fifo = new("ahb_slave_addr_phase_analysis_fifo",this);
    ahb_master_addr_phase_analysis_fifo = new("ahb_master_addr_phase_analysis_fifo",this);

    ahb_addr_phase_analysis_fifo_expect = new("ahb_addr_phase_analysis_fifo_expect",this);
    ahb_data_phase_analysis_fifo_expect = new("ahb_data_phase_analysis_fifo_expect",this);
    ahb_data_phase_for_write_analysis_fifo_expect = new("ahb_data_phase_for_write_analysis_fifo_expect",this);
    data_phase_key = new(1);
    addr_phase_key = new(1);
endfunction : new

function void ahb_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

function void ahb_scoreboard::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase

function void ahb_scoreboard::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
endfunction  : end_of_elaboration_phase

function void ahb_scoreboard::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase

task ahb_scoreboard::run_phase(uvm_phase phase);
  super.run_phase(phase);
  fork
    ahb_data_phase_compare();
    ahb_addr_phase_compare();
  join
endtask : run_phase

task ahb_scoreboard::ahb_addr_phase_compare();
  forever begin
    ahb_slave_tx l_addr_phase_tx;
    ahb_master_tx m_addr_phase_tx;
    ahb_master_tx exp_addr_phase_tx;
    addr_phase_key.get(1);
    ahb_addr_phase_analysis_fifo_expect.get(exp_addr_phase_tx);
    ahb_master_addr_phase_analysis_fifo.get(m_addr_phase_tx);
    ahb_slave_addr_phase_analysis_fifo.get(l_addr_phase_tx);
    `uvm_info("AHB_SCOREBOARD",$sformatf("exp_addr_phase_tx = %s \n",exp_addr_phase_tx.sprint()),UVM_LOW)
    `uvm_info("AHB_SCOREBOARD",$sformatf("m_addr_phase_tx = %s \n",m_addr_phase_tx.sprint()),UVM_HIGH)
    `uvm_info("AHB_SCOREBOARD",$sformatf("l_addr_phase_tx = %s \n",l_addr_phase_tx.sprint()),UVM_HIGH)

    m_addr_phase_tx.compare_phase = ADDR_PHASE;
    if(m_addr_phase_tx.do_compare(l_addr_phase_tx,uvm_default_comparer) && m_addr_phase_tx.do_compare(exp_addr_phase_tx,uvm_default_comparer)) begin
      `uvm_info("AHB_SCOREBOARD","ADDRESS phase comparision PASSED",UVM_LOW)
      ahb_addr_phase_comparer_count_pass ++;
    end else begin
      ahb_addr_phase_comparer_count_failed ++; 
      `uvm_error("COMPARE_AW","Address comparision FAILED") end
    addr_phase_key.put(1);
    ahb_addr_phase_comparer_count ++;
  end
endtask : ahb_addr_phase_compare

task ahb_scoreboard::ahb_data_phase_compare();
  forever begin
    ahb_slave_tx l_data_phase_tx;
    ahb_master_tx m_data_phase_tx;
    ahb_master_tx m_data_write_tx;
    ahb_slave_tx exp_data_phase_tx;
    data_phase_key.get(1);
    ahb_master_data_phase_analysis_fifo.get(m_data_phase_tx);
    ahb_slave_data_phase_analysis_fifo.get(l_data_phase_tx);
    ahb_data_phase_analysis_fifo_expect.get(exp_data_phase_tx);

    if(m_data_phase_tx.hwrite == HWRITE_WRITE) begin
      ahb_data_phase_for_write_analysis_fifo_expect.get(m_data_write_tx);
      exp_data_phase_tx.hwdata = m_data_write_tx.hwdata;
      exp_data_phase_tx.hwstrb = m_data_write_tx.hwstrb;
    end
    `uvm_info("AHB_SCOREBOARD",$sformatf("m_data_phase_tx = %s \n",m_data_phase_tx.sprint()),UVM_LOW)
    `uvm_info("AHB_SCOREBOARD",$sformatf("l_data_phase_tx = %s \n",l_data_phase_tx.sprint()),UVM_HIGH)
    `uvm_info("AHB_SCOREBOARD",$sformatf("exp_data_phase_tx = %s \n",exp_data_phase_tx.sprint()),UVM_LOW)
    m_data_phase_tx.compare_phase = DATA_PHASE;
    if(m_data_phase_tx.do_compare(l_data_phase_tx,uvm_default_comparer) && m_data_phase_tx.do_compare(exp_data_phase_tx,uvm_default_comparer)) begin
      `uvm_info("AHB_SCOREBOARD","Data phase comparision PASSED",UVM_LOW)
      ahb_data_phase_comparer_count_pass ++;
    end else begin
      ahb_data_phase_comparer_count_failed ++; 
      `uvm_error("COMPARE_AW","DATA PHASE comparision FAILED") 
    end
    data_phase_key.put(1);
    ahb_data_phase_comparer_count ++;
  end
endtask : ahb_data_phase_compare

function void ahb_scoreboard::check_phase (uvm_phase phase);
  super.check_phase(phase);
  `uvm_info(get_type_name(),$sformatf("--\n----------------------------------------------SCOREBOARD CHECK PHASE---------------------------------------"),UVM_LOW)   
  `uvm_info (get_type_name(),$sformatf(" Scoreboard Check Phase is starting"),UVM_LOW);

  if (ahb_slave_data_phase_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf (" ahb_slave_data_phase_analysis_fifo is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("ahb_slave_data_phase_analysis_fifo:%0d",ahb_slave_data_phase_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("ahb_slave_data_phase_analysis_fifo is not empty"));
  end

    if (ahb_slave_addr_phase_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf (" ahb_slave_addr_phase_analysis_fifo is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("ahb_slave_addr_phase_analysis_fifo:%0d",ahb_slave_addr_phase_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("ahb_slave_addr_phase_analysis_fifo is not empty"));
  end

    if (ahb_master_data_phase_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf (" ahb_master_data_phase_analysis_fifo is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("ahb_master_data_phase_analysis_fifo:%0d",ahb_master_data_phase_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("ahb_master_data_phase_analysis_fifo is not empty"));
  end

    if (ahb_master_addr_phase_analysis_fifo.size() == 0) begin
    `uvm_info (get_type_name(), $sformatf (" ahb_master_addr_phase_analysis_fifo is empty"),UVM_HIGH);
  end
  else begin
    `uvm_info (get_type_name(), $sformatf ("ahb_master_addr_phase_analysis_fifo:%0d",ahb_master_addr_phase_analysis_fifo.size() ),UVM_HIGH);
    `uvm_error (get_type_name(), $sformatf ("ahb_master_addr_phase_analysis_fifo is not empty"));
  end

  `uvm_info(get_type_name(),$sformatf("--\n----------------------------------------------END OF SCOREBOARD CHECK PHASE---------------------------------------"),UVM_LOW)
  `uvm_info(get_type_name(),$sformatf("--\n----------------------------------------------END OF SCOREBOARD CHECK PHASE---------------------------------------"),UVM_LOW)

endfunction : check_phase
function void ahb_scoreboard::report_phase(uvm_phase phase);
  super.report_phase(phase);
  $display(" ");
  $display("-------------------------------------------- ");
  $display("SCOREBOARD REPORT PHASE");
  $display("-------------------------------------------- ");
  $display(" ");
  $display("-------------------------------------------- ");
  $display("ADDRESS_PHASE");
  $display("-------------------------------------------- ");

  $display(" ");
    `uvm_info("AHB_SCOREBOARD",$sformatf("scoreboard's address packets count \n %0d",ahb_addr_phase_comparer_count),UVM_LOW)
    `uvm_info("AHB_SCOREBOARD",$sformatf("scoreboard's address FAILED packets count \n %0d",ahb_addr_phase_comparer_count_failed),UVM_LOW)
    `uvm_info("AHB_SCOREBOARD",$sformatf("scoreboard's address PASS packets count \n %0d",ahb_addr_phase_comparer_count_pass),UVM_LOW)
  $display(" ");

  $display("-------------------------------------------- ");
  $display("DATA_PHASE");
  $display("-------------------------------------------- ");
  $display(" ");
    `uvm_info("AHB_SCOREBOARD",$sformatf("scoreboard's data packets count \n %0d",ahb_data_phase_comparer_count),UVM_LOW)
    `uvm_info("AHB_SCOREBOARD",$sformatf("scoreboard's data FAILED packets count \n %0d",ahb_data_phase_comparer_count_failed),UVM_LOW)
    `uvm_info("AHB_SCOREBOARD",$sformatf("scoreboard's data PASS packets count \n %0d",ahb_data_phase_comparer_count_pass),UVM_LOW)
  $display(" ");
endfunction : report_phase


`endif