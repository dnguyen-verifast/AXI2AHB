`ifndef AHB_ENV_INCLUDED_
`define AHB_ENV_INCLUDED_

class ahb_env extends uvm_env;
  `uvm_component_utils(ahb_env)

    ahb_master_agent ahb_master_agent_h [];
    ahb_slave_agent ahb_slave_agent_h [];
    ahb_scoreboard ahb_scoreboard_h;

    ahb_virtual_seqr ahb_virtual_seqr_h;

    ahb_env_config ahb_env_config_h;
    ahb_slave_config ahb_slave_config_h [];
    ahb_master_config ahb_master_config_h  [];

    extern function new(string name = "ahb_env", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass : ahb_env

function ahb_env::new(string name = "ahb_env", uvm_component parent = null);
      super.new(name, parent);
endfunction : new
function void ahb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(ahb_env_config)::get(this,"","ahb_env_config",ahb_env_config_h)) begin
        `uvm_fatal("FATAL_ENV_AGENT_CONFIG", $sformatf("Couldn't get the env_agent_config from config_db"))
    end

    ahb_master_config_h = new[ahb_env_config_h.no_of_masters];
    foreach(ahb_master_config_h[i]) begin
        if(!uvm_config_db#(ahb_master_config)::get(this,"",$sformatf("ahb_master_config[%0d]",i),ahb_master_config_h[i])) begin
            `uvm_fatal("FATAL_MA_AGENT_CONFIG", $sformatf("Couldn't get the ahb_master_config[%0d] from config_db",i))
        end
    end

    ahb_slave_config_h = new[ahb_env_config_h.no_of_slaves];
    foreach(ahb_slave_config_h[i]) begin
        if(!uvm_config_db#(ahb_slave_config)::get(this,"",$sformatf("ahb_slave_config[%0d]",i),ahb_slave_config_h[i])) begin
            `uvm_fatal("FATAL_SLV_AGENT_CONFIG", $sformatf("Couldn't get the ahb_slave_config[%0d] from config_db",i))
        end
    end

    ahb_master_agent_h = new[ahb_env_config_h.no_of_masters];
    foreach(ahb_master_agent_h[i]) begin
        ahb_master_agent_h[i]=ahb_master_agent::type_id::create($sformatf("ahb_master_agent_h[%0d]",i),this);
    end
    ahb_slave_agent_h = new[ahb_env_config_h.no_of_slaves];
    foreach(ahb_slave_agent_h[i]) begin
        ahb_slave_agent_h[i]=ahb_slave_agent::type_id::create($sformatf("ahb_slave_agent_h[%0d]",i),this);
    end

    foreach(ahb_master_agent_h[i]) begin
        ahb_master_agent_h[i].ahb_master_config_h = ahb_master_config_h[i];
    end
    
    foreach(ahb_slave_agent_h[i]) begin
        ahb_slave_agent_h[i].ahb_slave_config_h = ahb_slave_config_h[i];
    end
    if(ahb_env_config_h.has_scoreboard) begin
        ahb_scoreboard_h = ahb_scoreboard::type_id::create("ahb_scoreboard_h",this);
    end
    if(ahb_env_config_h.has_virtual_seqr) begin
        ahb_virtual_seqr_h = ahb_virtual_seqr::type_id::create("ahb_virtual_seqr_h",this);
    end
endfunction : build_phase

function void ahb_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    foreach(ahb_master_agent_h[i]) begin
        if(ahb_env_config_h.has_virtual_seqr) begin
            ahb_virtual_seqr_h.ahb_master_sequencer_h = ahb_master_agent_h[i].ahb_master_sequencer_h;
        end
       if(ahb_env_config_h.has_scoreboard) begin
            ahb_slave_agent_h[i].ahb_slave_monitor_h.ahb_slave_data_analysis_port.connect(ahb_scoreboard_h.ahb_slave_data_phase_analysis_fifo.analysis_export);
            ahb_slave_agent_h[i].ahb_slave_monitor_h.ahb_slave_addr_analysis_port.connect(ahb_scoreboard_h.ahb_slave_addr_phase_analysis_fifo.analysis_export);
            ahb_slave_agent_h[i].ahb_slave_sequencer_h.seq_expect_item_port.connect(ahb_scoreboard_h.ahb_data_phase_analysis_fifo_expect.analysis_export);
       end 
    end
    
    foreach(ahb_slave_agent_h[i]) begin
        if(ahb_env_config_h.has_virtual_seqr) begin
            ahb_virtual_seqr_h.ahb_slave_sequencer_h = ahb_slave_agent_h[i].ahb_slave_sequencer_h;
        end
        if(ahb_env_config_h.has_scoreboard) begin
            ahb_master_agent_h[i].ahb_master_monitor_h.ahb_master_data_analysis_port.connect(ahb_scoreboard_h.ahb_master_data_phase_analysis_fifo.analysis_export);
            ahb_master_agent_h[i].ahb_master_monitor_h.ahb_master_addr_analysis_port.connect(ahb_scoreboard_h.ahb_master_addr_phase_analysis_fifo.analysis_export);
            ahb_master_agent_h[i].ahb_master_sequencer_h.seq_expect_item_port.connect(ahb_scoreboard_h.ahb_addr_phase_analysis_fifo_expect.analysis_export);
            ahb_master_agent_h[i].ahb_master_sequencer_h.seq_expect_write_item_port.connect(ahb_scoreboard_h.ahb_data_phase_for_write_analysis_fifo_expect.analysis_export); 
        end
    end
endfunction : connect_phase
`endif