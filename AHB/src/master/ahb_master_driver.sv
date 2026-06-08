`ifndef AHB_DRIVER_AGENT_INCLUDE_
`define AHB_DRIVER_AGENT_INCLUDE_

class ahb_master_driver extends uvm_driver#(ahb_master_tx);
    `uvm_component_utils(ahb_master_driver)

    uvm_seq_item_pull_port #(REQ,RSP) ahb_master_seq_item_port;

    uvm_analysis_port #(RSP) ahb_write_rsp_port;

    uvm_tlm_analysis_fifo #(ahb_master_tx) ahb_master_fifo;
    
    REQ req_write, req_read;
    RSP rsp_write, rsp_read;

    virtual ahb_if ahb_if_h;
    ahb_master_config ahb_master_config_h;
    
extern function new(string name = "ahb_master_driver", uvm_component parent=null);
extern virtual function void build_phase(uvm_phase phase);
extern virtual function void end_of_elaboration_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);

extern virtual task wr_addr_phase();
extern virtual task wr_data_phase();


extern virtual task wait_ahb_for_resetn();

endclass : ahb_master_driver

function ahb_master_driver::new(string name="ahb_master_driver",uvm_component parent=null);
    super.new(name,parent);
    ahb_master_seq_item_port = new("ahb_master_seq_item_port",this);
    ahb_master_fifo = new("ahb_master_fifo",this);
endfunction : new

function void ahb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual ahb_if)::get(this,"","ahb_if",ahb_if_h)) begin
        `uvm_fatal("DRIVER_MASTER","Fatal to get interface ahb_if");
    end
endfunction : build_phase

function void ahb_master_driver::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task ahb_master_driver::run_phase(uvm_phase phase);
    `uvm_info("DRIVER_MASTER", "Inside run_phase of AHB Driver master", UVM_LOW)

    wait_ahb_for_resetn();  
    fork
        wr_addr_phase();
        wr_data_phase();
    join
endtask : run_phase

task ahb_master_driver::wait_ahb_for_resetn();
    @(negedge ahb_if_h.resetn);
    `uvm_info("MASTER_DRIVER",$sformatf("SYSTEM RESET DETECTED"),UVM_HIGH)
    ahb_if_h.haddr     <= '0;
    ahb_if_h.hburst    <= '0;
    ahb_if_h.hmastlock <= '0;
    ahb_if_h.hprot     <= '0;
    ahb_if_h.hsize     <= '0;
    ahb_if_h.hnonsec   <= '0;
    ahb_if_h.hexcl     <= '0;
    ahb_if_h.hmaster   <= '0;
    ahb_if_h.htrans    <= '0;
    ahb_if_h.hwdata    <= '0;
    ahb_if_h.hwstrb    <= '0;
    ahb_if_h.hwrite    <= '0;
    ahb_if_h.hsel      <= '0;
    @(posedge ahb_if_h.resetn);
    `uvm_info("MASTER_DRIVER",$sformatf("SYSTEM RESET DEACTIVATED"),UVM_HIGH)
endtask : wait_ahb_for_resetn

task ahb_master_driver::wr_addr_phase();
    forever begin
        ahb_master_tx m_tx;
        ahb_transfer_struct m_tx_addr;
        ahb_master_seq_item_port.get_next_item(m_tx);
        `uvm_info("MASTER_DRIVER",$sformatf("ADDRESS_PHASE information address m_tx =%s \n",m_tx.sprint()),UVM_HIGH)
        ahb_master_seq_item_converter::from_class(m_tx,m_tx_addr);
        if(m_tx == null) begin
            ahb_if_h.htrans    <= '0;
            @(posedge ahb_if_h.clk);
        end else begin
            ahb_if_h.haddr     <= m_tx_addr.haddr;
            ahb_if_h.hburst    <= m_tx_addr.hburst;
            ahb_if_h.hmastlock <= m_tx_addr.hmastlock;
            ahb_if_h.hprot     <= m_tx_addr.hprot;
            ahb_if_h.hsize     <= m_tx_addr.hsize;
            ahb_if_h.hnonsec   <= m_tx_addr.hnonsec;
            ahb_if_h.hexcl     <= m_tx_addr.hexcl;
            ahb_if_h.hmaster   <= m_tx_addr.hmaster;
            ahb_if_h.htrans    <= m_tx_addr.htrans;
            ahb_if_h.hwrite    <= m_tx_addr.hwrite;
            ahb_if_h.hsel       <= m_tx_addr.hsel;
            @(posedge ahb_if_h.clk);
            if(ahb_master_config_h.has_convert_waitstate == 1) begin
                if(ahb_if_h.hready == 0 && (m_tx.htrans == HTRANS_IDLE || (m_tx.htrans == HTRANS_BUSY && (m_tx.hburst != SINGLE)))) begin
                    `uvm_info("MASTER_DRIVER",$sformatf("Transfer type changes during wait states"),UVM_LOW)                        
                end else begin
                    ahb_master_fifo.put(m_tx);
                    `uvm_info("MASTER_DRIVER",$sformatf("Finished send information address"),UVM_LOW)
                    while(ahb_if_h.hready == 0) begin
                        @(posedge ahb_if_h.clk);
                    end
                end
            end else begin
                ahb_master_fifo.put(m_tx);
                `uvm_info("MASTER_DRIVER",$sformatf("Finished send information address"),UVM_LOW)
                while(ahb_if_h.hready == 0) begin
                    @(posedge ahb_if_h.clk);
                end
            end
        end
        ahb_master_seq_item_port.item_done(); 
    end    
endtask : wr_addr_phase

task ahb_master_driver::wr_data_phase();
    forever begin
        ahb_master_tx m_tx;
        ahb_transfer_struct m_tx_data;
        `uvm_info("MASTER_DRIVER",$sformatf("Waiting for fifo information address"),UVM_LOW)
        ahb_master_fifo.get(m_tx);
        ahb_master_seq_item_converter::from_class(m_tx,m_tx_data);
        if(m_tx.hwrite == HWRITE_WRITE) begin
            ahb_if_h.hwdata    <= m_tx_data.hwdata;
            ahb_if_h.hwstrb    <= m_tx_data.hwstrb;
            `uvm_info("MASTER_DRIVER",$sformatf("Send data to slave hwdata = %h    hwstrb = %h \n",m_tx_data.hwdata,m_tx_data.hwstrb),UVM_LOW)
            @(posedge ahb_if_h.clk);
            while(ahb_if_h.hready == 0) begin
                @(posedge ahb_if_h.clk);
            end
            `uvm_info("MASTER_DRIVER",$sformatf("Get response from slave for write transaction"),UVM_LOW)
            m_tx_data.hresp  = ahb_if_h.hresp;
            m_tx_data.hexokay  = ahb_if_h.hexokay;
        end else if(m_tx.hwrite == HWRITE_READ)begin
            ahb_if_h.hwstrb    <= m_tx_data.hwstrb;
            @(posedge ahb_if_h.clk);
            while(ahb_if_h.hready == 0) begin
                @(posedge ahb_if_h.clk);
            end
            `uvm_info("MASTER_DRIVER",$sformatf("Get response from slave for read transaction"),UVM_LOW)
            m_tx_data.hresp    = ahb_if_h.hresp;
            m_tx_data.hexokay    = ahb_if_h.hexokay;
            m_tx_data.hrdata = ahb_if_h.hrdata;
        end
    end
endtask : wr_data_phase
`endif

