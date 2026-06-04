`ifndef AHB_MASTER_AGENT_INCLUDE_
`define AHB_MASTER_AGENT_INCLUDE_

class ahb_master_agent extends uvm_agent;
    `uvm_component_utils(ahb_master_agent)

    ahb_master_driver ahb_master_driver_h;
    ahb_master_monitor ahb_master_monitor_h;
    ahb_master_sequencer ahb_master_sequencer_h;
    ahb_master_coverage ahb_master_coverage_h;

    ahb_master_config ahb_master_config_h;

    extern function new(string name = "ahb_master_agent", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass : ahb_master_agent

function ahb_master_agent::new(string name = "ahb_master_agent", uvm_component parent =null);
    super.new(name,parent);
endfunction : new

function void ahb_master_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    ahb_master_driver_h = ahb_master_driver::type_id::create("ahb_master_driver_h",this);
    ahb_master_sequencer_h = ahb_master_sequencer::type_id::create("ahb_master_sequencer_h",this);
    ahb_master_monitor_h = ahb_master_monitor::type_id::create("ahb_master_monitor_h",this);
    ahb_master_coverage_h = ahb_master_coverage::type_id::create("ahb_master_coverage_h",this);
endfunction : build_phase

function void ahb_master_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    ahb_master_driver_h.ahb_master_config_h = ahb_master_config_h;
    
    ahb_master_driver_h.ahb_master_seq_item_port.connect(ahb_master_sequencer_h.seq_item_export);
    ahb_master_monitor_h.ahb_master_data_analysis_port.connect(ahb_master_coverage_h.analysis_export);
    ahb_master_monitor_h.ahb_master_coverage_analysis_port.connect(ahb_master_coverage_h.analysis_export);
endfunction : connect_phase
`endif