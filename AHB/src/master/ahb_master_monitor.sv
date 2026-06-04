`ifndef AHB_MASTER_MONITOR_INCLUDE_
`define AHB_MASTER_MONITOR_INCLUDE_

class ahb_master_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_master_monitor)

    virtual ahb_if ahb_if_h;
    ahb_transfer_struct pipeline_monitor[$];

    uvm_analysis_port#(ahb_master_tx)  ahb_master_data_analysis_port;
    uvm_analysis_port#(ahb_master_tx)  ahb_master_addr_analysis_port;
    uvm_analysis_port#(ahb_master_tx)  ahb_master_coverage_analysis_port;

    extern function new(string name = "ahb_master_monitor", uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    extern virtual task ahb_master_data_phase();
    extern virtual task ahb_master_addr_phase(); 
endclass : ahb_master_monitor

function ahb_master_monitor::new(string name ="ahb_master_monitor", uvm_component parent =null);
    super.new(name, parent);
    ahb_master_data_analysis_port = new("ahb_master_data_analysis_port",this);
    ahb_master_addr_analysis_port = new("ahb_master_addr_analysis_port",this);
    ahb_master_coverage_analysis_port = new("ahb_master_coverage_analysis_port",this);
endfunction : new

function void ahb_master_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual ahb_if)::get(this,"","ahb_if",ahb_if_h)) begin
        `uvm_fatal("MONITOR_MASTER","Dont get interface ahb_if_h");
    end
endfunction :build_phase

function void ahb_master_monitor::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase

function void ahb_master_monitor::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase

task ahb_master_monitor::run_phase(uvm_phase phase);
    @(negedge ahb_if_h.resetn);
    `uvm_info("FROM MASTER MON BFM",$sformatf("SYSTEM RESET DETECTED"),UVM_HIGH) 
    @(posedge ahb_if_h.resetn);
    `uvm_info("FROM MASTER MON BFM",$sformatf("SYSTEM RESET DEACTIVATED"),UVM_HIGH)

    fork
        ahb_master_data_phase();
        ahb_master_addr_phase(); 
    join
endtask : run_phase

task ahb_master_monitor::ahb_master_addr_phase();
    forever begin
        ahb_master_tx mon_tx_add;
        ahb_transfer_struct m_tx_add;
        @(posedge ahb_if_h.clk);
        m_tx_add.haddr     = ahb_if_h.haddr;
        m_tx_add.hburst    = ahb_if_h.hburst;
        m_tx_add.hmastlock = ahb_if_h.hmastlock;
        m_tx_add.hprot     = ahb_if_h.hprot;
        m_tx_add.hsize     = ahb_if_h.hsize;
        m_tx_add.hnonsec   = ahb_if_h.hnonsec;
        m_tx_add.hexcl     = ahb_if_h.hexcl;
        m_tx_add.hmaster   = ahb_if_h.hmaster;
        m_tx_add.htrans    = ahb_if_h.htrans;
        m_tx_add.hwrite    = ahb_if_h.hwrite;
        m_tx_add.hsel       = ahb_if_h.hsel;
        m_tx_add.hreadyout = ahb_if_h.hreadyout;
        `uvm_info("MASTER MON",$sformatf("Capture signal from interface in addr phase"),UVM_LOW)
        ahb_master_seq_item_converter::to_class(m_tx_add,mon_tx_add);
        ahb_master_coverage_analysis_port.write(mon_tx_add);
        if(ahb_if_h.hreadyout == 1) begin
            if (mon_tx_add.htrans == HTRANS_NONSEQ || mon_tx_add.htrans == HTRANS_SEQ) begin
                pipeline_monitor.push_back(m_tx_add);
                ahb_master_addr_analysis_port.write(mon_tx_add);
                `uvm_info("MASTER MON",$sformatf("addr phase write object to scoreboard mon_tx_add = %s \n",mon_tx_add.sprint()),UVM_HIGH)
            end
        end
    end
endtask : ahb_master_addr_phase

task ahb_master_monitor::ahb_master_data_phase();
    forever begin
        ahb_master_tx mon_tx_data;
        ahb_transfer_struct m_tx_data;
        wait(pipeline_monitor.size() > 0);
//        if(pipeline_monitor.size() > 0) begin
            @(posedge ahb_if_h.clk);
            if(ahb_if_h.hreadyout == 1) begin
             m_tx_data = pipeline_monitor.pop_front();
             m_tx_data.hwdata  = ahb_if_h.hwdata;
             m_tx_data.hwstrb  = ahb_if_h.hwstrb ;
             m_tx_data.hresp   = ahb_if_h.hresp;
             m_tx_data.hrdata   = ahb_if_h.hrdata;
             m_tx_data.hexokay   = ahb_if_h.hexokay;

             `uvm_info("MASTER MON",$sformatf("Capture signal from interface in data_phase"),UVM_LOW)
            ahb_master_seq_item_converter::to_class(m_tx_data,mon_tx_data);
            `uvm_info("MASTER MON",$sformatf("data_phase write object to scoreboard mon_tx_data = %s \n",mon_tx_data.sprint()),UVM_HIGH)
            ahb_master_data_analysis_port.write(mon_tx_data); 
        end
//        end else begin @(posedge ahb_if_h.clk); end
    end
endtask : ahb_master_data_phase

`endif