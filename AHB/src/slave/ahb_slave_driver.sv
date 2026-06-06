`ifndef AHB_DRIVER_AGENT_INCLUDE_
`define AHB_DRIVER_AGENT_INCLUDE_

class ahb_slave_driver extends uvm_driver#(ahb_slave_tx);
    `uvm_component_utils(ahb_slave_driver)

    uvm_seq_item_pull_port #(REQ,RSP) ahb_slave_seq_item_port;

    uvm_analysis_port #(RSP) ahb_write_rsp_port;

    REQ req_write, req_read;
    RSP rsp_write, rsp_read;

    virtual ahb_if ahb_if_h;
    ahb_slave_config ahb_slave_config_h;

    uvm_tlm_analysis_fifo #(ahb_slave_tx) pipeline_q;
    

    semaphore add_phase_key;
    semaphore data_phase_key;

    
extern function new(string name = "ahb_slave_driver", uvm_component parent=null);
extern virtual function void build_phase(uvm_phase phase);
extern virtual function void end_of_elaboration_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern virtual task wait_ahb_for_resetn();
extern virtual task wr_addr_phase();
extern virtual task wr_data_phase();
endclass : ahb_slave_driver

function ahb_slave_driver::new(string name="ahb_slave_driver",uvm_component parent=null);
    super.new(name,parent);
    ahb_slave_seq_item_port = new("ahb_slave_seq_item_port",this);
    pipeline_q = new("pipeline_q",this);
    add_phase_key = new(1);
    data_phase_key = new(1);
endfunction : new

function void ahb_slave_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual ahb_if)::get(this,"","ahb_if",ahb_if_h)) begin
        `uvm_fatal("DRIVER_MASTER","Fatal to get interface ahb_if");
    end
endfunction : build_phase

function void ahb_slave_driver::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

task ahb_slave_driver::run_phase(uvm_phase phase);
    `uvm_info("DRIVER_SLAVE", "Inside run_phase of AHB Driver slave", UVM_LOW)

    wait_ahb_for_resetn();
    fork
        wr_addr_phase();
        wr_data_phase();
    join

endtask : run_phase

task ahb_slave_driver::wait_ahb_for_resetn();
    @(negedge ahb_if_h.resetn);
    `uvm_info("DRIVER_SLAVE",$sformatf("SYSTEM RESET DETECTED"),UVM_HIGH)
    ahb_if_h.hrdata    <= '0;
    ahb_if_h.hreadyout <= '1;
    ahb_if_h.hresp     <= '0;
    ahb_if_h.hexokay   <= '0;
    @(posedge ahb_if_h.resetn);
    `uvm_info("DRIVER_SLAVE",$sformatf("SYSTEM RESET DEACTIVATED"),UVM_HIGH)
endtask : wait_ahb_for_resetn


task ahb_slave_driver::wr_addr_phase();

    ahb_transfer_struct slv_struct_add;
    ahb_slave_tx slv_tx_add;
    forever begin
        @(posedge ahb_if_h.clk);
        if (ahb_if_h.hsel == 1'b1 && ahb_if_h.hreadyout == 1'b1) begin
            slv_struct_add.haddr     = ahb_if_h.haddr;
            slv_struct_add.hburst    = ahb_if_h.hburst;
            slv_struct_add.hmastlock = ahb_if_h.hmastlock;
            slv_struct_add.hprot     = ahb_if_h.hprot;
            slv_struct_add.hsize     = ahb_if_h.hsize;
            slv_struct_add.hnonsec   = ahb_if_h.hnonsec;
            slv_struct_add.hexcl     = ahb_if_h.hexcl;
            slv_struct_add.hmaster   = ahb_if_h.hmaster;
            slv_struct_add.htrans    = ahb_if_h.htrans;
            slv_struct_add.hwrite    = ahb_if_h.hwrite;
            ahb_slave_seq_item_converter::to_class(slv_struct_add,slv_tx_add);
            `uvm_info(get_type_name(),$sformatf("Recieved transaction address information slv_tx_add = %s \n",slv_tx_add.sprint()),UVM_NONE);
            pipeline_q.put(slv_tx_add);
        end
    end
endtask : wr_addr_phase

task ahb_slave_driver::wr_data_phase();
    ahb_slave_tx slv_addr_phase;
    ahb_slave_tx slv_data_tx;
    ahb_transfer_struct slv_data_struct;
    @(posedge ahb_if_h.clk);
    forever begin
        `uvm_info(get_type_name(),$sformatf("Waiting for queue address phase valid"),UVM_HIGH);
        pipeline_q.get(slv_addr_phase);
        `uvm_info(get_type_name(),$sformatf("Recieved addr into data phase"),UVM_LOW);
        if(slv_addr_phase.htrans == HTRANS_IDLE || slv_addr_phase.htrans == HTRANS_BUSY) begin
            ahb_if_h.hreadyout <= 1'b1;
            ahb_if_h.hresp     <= 1'b0;
            ahb_if_h.hexokay   <= 1'b0;
            `uvm_info(get_type_name(),$sformatf("Trans ilde or busy ignore"),UVM_NONE);
            @(posedge ahb_if_h.clk);
        end else begin
            ahb_slave_seq_item_port.get_next_item(slv_data_tx);
            `uvm_info(get_type_name(),$sformatf("ADDRESS PHASE::Before Sending_req_write_packet = \n %s",slv_data_tx.sprint()),UVM_HIGH);
            ahb_slave_seq_item_converter::from_class(slv_data_tx,slv_data_struct);
            if(slv_addr_phase.hwrite == HWRITE_WRITE) begin
                repeat(slv_data_tx.wait_state) begin
                    ahb_if_h.hreadyout <= 0;
                    `uvm_info("DRIVER_SLAVE","waiting for resolve a previous data phase WRITE",UVM_LOW)
                    @(posedge ahb_if_h.clk);
                end
                if(slv_addr_phase.hexcl == HEXCL_NORMAL) begin
                    `uvm_info("DRIVER_SLAVE"," resolve a HEXCL_NORMAL data phase WRITE",UVM_LOW)
                    if(slv_data_tx.hresp == HRESP_ERROR) begin
                         `uvm_info("DRIVER_SLAVE"," resolve a HRESP_ERROR data phase WRITE",UVM_LOW)
                        ahb_if_h.hreadyout <= 0;
                        ahb_if_h.hresp     <= 1;
                        ahb_if_h.hexokay   <= 0;
                        @(posedge ahb_if_h.clk);
                        ahb_if_h.hreadyout <= 1;
                        ahb_if_h.hresp     <= 1;
                        ahb_if_h.hexokay   <= 0;
                        @(posedge ahb_if_h.clk);
                        ahb_if_h.hresp     <= 0;
                        ahb_if_h.hexokay   <= 0;
                    end else begin
                        `uvm_info("DRIVER_SLAVE"," resolve a HRESP_OKAY data phase WRITE",UVM_LOW)
                        ahb_if_h.hreadyout <= 1;
                        ahb_if_h.hresp     <= 0;
                        slv_data_tx.hwdata   = ahb_if_h.hwdata;
                        @(posedge ahb_if_h.clk);
                    end
                end else begin
                    if(slv_data_tx.hexokay == HEXOKAY_PASS) begin
                            `uvm_info("DRIVER_SLAVE"," resolve a HEXOKAY_PASS data phase for exclusive access WRITE",UVM_LOW)
                            ahb_if_h.hreadyout <= 1;
                            ahb_if_h.hexokay     <= 1;
                            ahb_if_h.hresp     <= 0;
                            slv_data_tx.hwdata   = ahb_if_h.hwdata;
                            @(posedge ahb_if_h.clk);
                            ahb_if_h.hexokay     <= 0;
                    end else begin
                            `uvm_info("DRIVER_SLAVE"," resolve a HEXOKAY_FAIL data phase for exclusive access WRITE",UVM_LOW)
                            ahb_if_h.hreadyout <= 0;
                            ahb_if_h.hresp     <= 0;
                            ahb_if_h.hexokay   <= 0;
                            @(posedge ahb_if_h.clk);
                            ahb_if_h.hresp     <= 0;
                            ahb_if_h.hexokay   <= 0;
                    end
                end
            end else if(slv_addr_phase.hwrite == HWRITE_READ) begin
                repeat(slv_data_tx.wait_state) begin
                    ahb_if_h.hreadyout <= 0;
                    `uvm_info("DRIVER_SLAVE","waiting for resolve a previous data phase HWRITE_READ",UVM_LOW)
                    @(posedge ahb_if_h.clk);
                end
                if(slv_addr_phase.hexcl == HEXCL_NORMAL) begin
                    if(slv_data_tx.hresp == HRESP_ERROR) begin
                        `uvm_info("DRIVER_SLAVE"," resolve a HRESP_ERROR data phase HWRITE_READ",UVM_LOW)
                        ahb_if_h.hreadyout <= 0;
                        ahb_if_h.hresp     <= 1;
                        @(posedge ahb_if_h.clk);
                        ahb_if_h.hreadyout <= 1;
                        ahb_if_h.hresp     <= 1;
                        ahb_if_h.hrdata    <= slv_data_struct.hrdata;
                        @(posedge ahb_if_h.clk);
                        ahb_if_h.hresp     <= 0;
                    end else begin
                        `uvm_info("DRIVER_SLAVE"," resolve a HRESP_PASS data phase HWRITE_READ",UVM_LOW)
                        ahb_if_h.hreadyout <= 1;
                        ahb_if_h.hresp     <= 0;
                        ahb_if_h.hrdata    <= slv_data_struct.hrdata;
                        @(posedge ahb_if_h.clk);
                    end
                end else begin
                    if(slv_data_tx.hexokay == HEXOKAY_PASS) begin
                            `uvm_info("DRIVER_SLAVE"," resolve HEXCL_EXCLUSIVE a HEXOKAY_PASS data phase HWRITE_READ",UVM_LOW)
                            ahb_if_h.hreadyout <= 1;
                            ahb_if_h.hexokay   <= 1;
                            ahb_if_h.hresp     <= 0;
                            ahb_if_h.hrdata    <= slv_data_struct.hrdata;
                            @(posedge ahb_if_h.clk);
                            ahb_if_h.hexokay   <= 0;
                    end else begin
                            `uvm_info("DRIVER_SLAVE"," resolve HEXCL_EXCLUSIVE a HEXOKAY_FAIL data phase HWRITE_READ",UVM_LOW)
                            ahb_if_h.hreadyout <= 1;
                            ahb_if_h.hresp     <= 0;
                            ahb_if_h.hexokay   <= 0;
                            ahb_if_h.hrdata    <= slv_data_struct.hrdata;
                            @(posedge ahb_if_h.clk);
                    end
                end
            end
            ahb_slave_seq_item_port.item_done();
        end
    end
endtask : wr_data_phase

`endif


