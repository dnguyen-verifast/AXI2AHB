`ifndef AHB_SLAVE_MONITOR_INCLUDE_
`define AHB_SLAVE_MONITOR_INCLUDE_

class ahb_slave_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_slave_monitor)

    virtual ahb_if ahb_if_h;
    ahb_transfer_struct pipeline_monitor_l[$];
    bit [31:0]             pre_haddr;
    htrans_e                pre_htrans;

    uvm_analysis_port#(ahb_slave_tx)  ahb_slave_addr_analysis_port;
    uvm_analysis_port#(ahb_slave_tx)  ahb_slave_data_analysis_port;
    uvm_analysis_port#(ahb_slave_tx)  ahb_slave_coverage_analysis_port;

    extern function new(string name = "ahb_slave_monitor", uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    extern virtual task ahb_slave_data_phase();
    extern virtual task ahb_slave_addr_phase(); 
endclass : ahb_slave_monitor

function ahb_slave_monitor::new(string name = "ahb_slave_monitor", uvm_component parent =null);
    super.new(name, parent);
    ahb_slave_addr_analysis_port = new("ahb_slave_addr_analysis_port",this);
    ahb_slave_data_analysis_port = new("ahb_slave_data_analysis_port",this);
    ahb_slave_coverage_analysis_port = new("ahb_slave_coverage_analysis_port",this);
endfunction : new

function void ahb_slave_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual ahb_if)::get(this,"","ahb_if",ahb_if_h)) begin
        `uvm_fatal("MONITOR_slave","Dont get interface ahb_if_h");
    end
endfunction :build_phase

function void ahb_slave_monitor::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase

function void ahb_slave_monitor::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction: end_of_elaboration_phase

task ahb_slave_monitor::run_phase(uvm_phase phase);
    @(negedge ahb_if_h.resetn);
    `uvm_info("FROM slave MON BFM",$sformatf("SYSTEM RESET DETECTED"),UVM_HIGH) 
    @(posedge ahb_if_h.resetn);
    `uvm_info("FROM slave MON BFM",$sformatf("SYSTEM RESET DEACTIVATED"),UVM_HIGH)

    fork
        ahb_slave_data_phase();
        ahb_slave_addr_phase(); 
    join
endtask : run_phase

task ahb_slave_monitor::ahb_slave_addr_phase();
    forever begin
        ahb_slave_tx mon_tx_add;
        ahb_transfer_struct slv_tx_add;
        @(posedge ahb_if_h.clk);
        slv_tx_add.haddr     = ahb_if_h.haddr;
        slv_tx_add.hburst    = ahb_if_h.hburst;
        slv_tx_add.hmastlock = ahb_if_h.hmastlock;
        slv_tx_add.hprot     = ahb_if_h.hprot;
        slv_tx_add.hsize     = ahb_if_h.hsize;
        slv_tx_add.hnonsec   = ahb_if_h.hnonsec;
        slv_tx_add.hexcl     = ahb_if_h.hexcl;
        slv_tx_add.hmaster     = ahb_if_h.hmaster;
        slv_tx_add.htrans    = ahb_if_h.htrans;
        slv_tx_add.hwrite    = ahb_if_h.hwrite;
        slv_tx_add.hsel      = ahb_if_h.hsel;
        `uvm_info("SLAVE MON",$sformatf("Capture signal from interface in addr phase"),UVM_HIGH)
        ahb_slave_seq_item_converter::to_class(slv_tx_add,mon_tx_add);
        ahb_slave_coverage_analysis_port.write(mon_tx_add);
        if(ahb_if_h.hready == 1 && ahb_if_h.hsel == 1) begin
            pre_haddr = mon_tx_add.haddr;
            pre_htrans = mon_tx_add.htrans;
            if (mon_tx_add.htrans == HTRANS_NONSEQ || mon_tx_add.htrans == HTRANS_SEQ) begin
                pipeline_monitor_l.push_back(slv_tx_add);
                `uvm_info("SLAVE MON",$sformatf("addr phase write object to scoreboard mon_tx_add = %s \n",mon_tx_add.sprint()),UVM_HIGH)
                ahb_slave_addr_analysis_port.write(mon_tx_add);
            end

            if(ahb_if_h.htrans == HTRANS_NONSEQ || ahb_if_h.htrans == HTRANS_IDLE) begin
                `uvm_info("SLAVE MON", $sformatf("Start new sequence"), UVM_HIGH)
            end else begin
                if(ahb_if_h.haddr[31:10] != pre_haddr[31:10]) begin
                    `uvm_error("MON_CHK_1KB", $sformatf("FATAL! Burst crossed 1KB boundary. Prev: %0h, Curr: %0h", pre_haddr, ahb_if_h.haddr))
                end
            end
        end 
    end
endtask : ahb_slave_addr_phase

task ahb_slave_monitor::ahb_slave_data_phase();
    forever begin
        ahb_slave_tx mon_tx_data;
        ahb_transfer_struct slv_tx_data;
        wait(pipeline_monitor_l.size() > 0);
//        if(pipeline_monitor_l.size() > 0) begin
            @(posedge ahb_if_h.clk);
            if(ahb_if_h.hreadyout == 1) begin
                slv_tx_data = pipeline_monitor_l.pop_front();
                slv_tx_data.hwdata  = ahb_if_h.hwdata;
                slv_tx_data.hwstrb  = ahb_if_h.hwstrb;
                slv_tx_data.hresp   = ahb_if_h.hresp;
                slv_tx_data.hrdata   = ahb_if_h.hrdata;
                slv_tx_data.hexokay   = ahb_if_h.hexokay;
                `uvm_info("SLAVE MON",$sformatf("Capture signal from interface in data_phase"),UVM_HIGH)
                ahb_slave_seq_item_converter::to_class(slv_tx_data,mon_tx_data);
                ahb_slave_data_analysis_port.write(mon_tx_data);
                `uvm_info("SLAVE MON",$sformatf("data_phase write object to scoreboard mon_tx_data = %s \n",mon_tx_data.sprint()),UVM_HIGH)
            end
//        end else begin @(posedge ahb_if_h.clk); end
    end
endtask : ahb_slave_data_phase

`endif