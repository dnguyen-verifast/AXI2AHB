`ifndef AHB_SLAVE_AGENT_INCLUDE_
`define AHB_SLAVE_AGENT_INCLUDE_

class ahb_slave_agent extends uvm_agent;
    `uvm_component_utils(ahb_slave_agent)

    ahb_slave_driver ahb_slave_driver_h;
    ahb_slave_monitor ahb_slave_monitor_h;
    ahb_slave_sequencer ahb_slave_sequencer_h;
    ahb_slave_coverage ahb_slave_coverage_h;

    ahb_slave_config ahb_slave_config_h;

    extern function new(string name = "ahb_slave_agent", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass : ahb_slave_agent

function ahb_slave_agent::new(string name = "ahb_slave_agent", uvm_component parent =null);
    super.new(name,parent);
endfunction : new

function void ahb_slave_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    ahb_slave_driver_h = ahb_slave_driver::type_id::create("ahb_slave_driver_h",this);
    ahb_slave_sequencer_h = ahb_slave_sequencer::type_id::create("ahb_slave_sequencer_h",this);
    ahb_slave_monitor_h = ahb_slave_monitor::type_id::create("ahb_slave_monitor_h",this);
    ahb_slave_coverage_h = ahb_slave_coverage::type_id::create("ahb_slave_coverage_h",this);
endfunction : build_phase

function void ahb_slave_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    ahb_slave_driver_h.ahb_slave_config_h = ahb_slave_config_h;

    ahb_slave_driver_h.ahb_slave_seq_item_port.connect(ahb_slave_sequencer_h.seq_item_export);
    ahb_slave_monitor_h.ahb_slave_data_analysis_port.connect(ahb_slave_coverage_h.analysis_export);
    ahb_slave_monitor_h.ahb_slave_coverage_analysis_port.connect(ahb_slave_coverage_h.analysis_export);
endfunction : connect_phase
`endif