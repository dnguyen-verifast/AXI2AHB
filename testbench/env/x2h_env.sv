`ifndef X2H_ENV_INCLUDE_
`define X2H_ENV_INCLUDE_
class x2h_env extends uvm_scoreboard;
    `uvm_component_utils(x2h_env)

    axi4_env_config axi4_env_cfg_h;
    axi4_env axi4_env_h;

    ahb_env_config ahb_env_config_h;
    ahb_env ahb_env_h;


    x2h_env_config x2h_env_config_h;
    x2h_scoreboard x2h_scoreboard_h;
    x2h_virtual_sequencer x2h_virtual_sequencer_h;

    extern function new(string name = "x2h_env", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass : x2h_env

function x2h_env::new(string name = "axi4_env",uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void x2h_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  axi4_env_h = axi4_env::type_id::create("axi4_env_h",this);
  ahb_env_h = ahb_env::type_id::create("ahb_env_h",this);

    if(!uvm_config_db #(axi4_env_config)::get(this,"","axi4_env_config",axi4_env_cfg_h)) begin
    `uvm_fatal("FATAL_ENV_AGENT_CONFIG", $sformatf("Couldn't get the env_agent_config from config_db"))
    end else begin  
      uvm_config_db #(axi4_env_config)::set(this,"*","axi4_env_config",axi4_env_cfg_h)
    end
    if(!uvm_config_db #(ahb_env_config)::get(this,"","ahb_env_config",ahb_env_config_h)) begin
        `uvm_fatal("FATAL_ENV_AGENT_CONFIG", $sformatf("Couldn't get the env_agent_config from config_db"))
    end else begin  
      uvm_config_db #(ahb_env_config)::set(this,"*","ahb_env_config",ahb_env_config_h)
    end

    x2h_scoreboard_h = x2h_scoreboard::type_id::create("x2h_scoreboard_h",this);
    x2h_virtual_sequencer_h = x2h_virtual_sequencer::type_id::create("x2h_virtual_sequencer_h",this);
endfunction : build_phase

function void x2h_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if(axi4_env_cfg_h.has_virtual_seqr) begin
    foreach(axi4_master_agent_h[i]) begin
      x2h_virtual_sequencer_h.axi4_master_write_seqr_h = axi4_env_h.axi4_master_agent_h[i].axi4_master_write_seqr_h;
      x2h_virtual_sequencer_h.axi4_master_read_seqr_h = axi4_env_h.axi4_master_agent_h[i].axi4_master_read_seqr_h;
    end
  end
  
  foreach(axi4_master_agent_h[i]) begin
    axi4_env_h.axi4_master_agent_h[i].axi4_master_mon_proxy_h.axi4_master_read_address_analysis_port.connect(x2h_scoreboard_h.axi4_master_read_address_analysis_fifo.analysis_export);
    axi4_env_h.axi4_master_agent_h[i].axi4_master_mon_proxy_h.axi4_master_read_data_analysis_port.connect(x2h_scoreboard_h.axi4_master_read_data_analysis_fifo.analysis_export);
    axi4_env_h.axi4_master_agent_h[i].axi4_master_mon_proxy_h.axi4_master_write_address_analysis_port.connect(x2h_scoreboard_h.axi4_master_write_address_analysis_fifo.analysis_export);
    axi4_env_h.axi4_master_agent_h[i].axi4_master_mon_proxy_h.axi4_master_write_data_analysis_port.connect(x2h_scoreboard_h.axi4_master_write_data_analysis_fifo.analysis_export);
    axi4_env_h.axi4_master_agent_h[i].axi4_master_mon_proxy_h.axi4_master_write_response_analysis_port.connect(x2h_scoreboard_h.axi4_master_write_response_analysis_fifo.analysis_export);
  end

  if(ahb_env_config.has_virtual_seqr) begin
    foreach(ahb_slave_agent_h[i]) begin
      x2h_virtual_sequencer_h.ahb_slave_sequencer_h = ahb_env_h.ahb_slave_agent_h[i].ahb_slave_sequencer_h;
    end
  end
  foreach(ahb_slave_agent_h[i]) begin
    ahb_env_h.ahb_master_agent_h[i].ahb_master_monitor_h.ahb_master_data_analysis_port.connect(x2h_scoreboard_h.ahb_master_data_phase_analysis_fifo.analysis_export);
    ahb_env_h.ahb_master_agent_h[i].ahb_master_monitor_h.ahb_master_addr_analysis_port.connect(x2h_scoreboard_h.ahb_master_addr_phase_analysis_fifo.analysis_export);
    ahb_env_h.ahb_master_agent_h[i].ahb_master_sequencer_h.seq_expect_item_port.connect(x2h_scoreboard_h.ahb_addr_phase_analysis_fifo_expect.analysis_export);
    ahb_env_h.ahb_master_agent_h[i].ahb_master_sequencer_h.seq_expect_write_item_port.connect(x2h_scoreboard_h.ahb_data_phase_for_write_analysis_fifo_expect.analysis_export); 
  end
endfunction : connect_phase
`endif