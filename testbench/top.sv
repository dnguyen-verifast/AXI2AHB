`ifndef TOP_INCLUDED_
`define TOP_INCLUDED_
module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_globals_pkg::*;
  import ahb_global_pkg::*;
  import x2h_test_pkg::*;

  import axi_ahb_bridge_pkg::*;
  import axi_ahb_pkg::*;

  parameter  ADDR_WIDTHS = 32;
  parameter DATA_WIDTHS = 32;
  logic aclk;
  logic aresetn;
  logic hclk;
  logic hresetn;

  logic        hbusreq_dummy;
  logic        hlock_dummy;
  logic        hgrant_dummy;

  axi4_if axi_vif (
    .aclk(aclk), 
    .aresetn(aresetn)
  );

  ahb_if ahb_vif (
    .clk(hclk), 
    .resetn(hresetn)
  );

axi4_to_ahb_lite #(
    .AXI_ADDR_WIDTH (32),
    .AXI_DATA_WIDTH (32),
    .AXI_ID_WIDTH   (4)
) dut (

    //=================================================
    // AXI
    //=================================================
    .ACLK       (axi_clk),
    .ARESETn    (axi_rstn),

    .AWID       (axi_if.awid),
    .AWADDR     (axi_if.awaddr),
    .AWLEN      (axi_if.awlen),
    .AWSIZE     (axi_if.awsize),
    .AWBURST    (axi_if.awburst),
    .AWVALID    (axi_if.awvalid),
    .AWREADY    (axi_if.awready),

    .WDATA      (axi_if.wdata),
    .WSTRB      (axi_if.wstrb),
    .WLAST      (axi_if.wlast),
    .WVALID     (axi_if.wvalid),
    .WREADY     (axi_if.wready),

    .BID        (axi_if.bid),
    .BRESP      (axi_if.bresp),
    .BVALID     (axi_if.bvalid),
    .BREADY     (axi_if.bready),

    .ARID       (axi_if.arid),
    .ARADDR     (axi_if.araddr),
    .ARLEN      (axi_if.arlen),
    .ARSIZE     (axi_if.arsize),
    .ARBURST    (axi_if.arburst),
    .ARVALID    (axi_if.arvalid),
    .ARREADY    (axi_if.arready),

    .RID        (axi_if.rid),
    .RDATA      (axi_if.rdata),
    .RRESP      (axi_if.rresp),
    .RLAST      (axi_if.rlast),
    .RVALID     (axi_if.rvalid),
    .RREADY     (axi_if.rready),

    //=================================================
    // AHB-Lite
    //=================================================
    .HADDR      (ahb_if_h.haddr),
    .HBURST     (ahb_if_h.hburst),
    .HMASTLOCK  (ahb_if_h.hmastlock),
    .HPROT      (ahb_if_h.hprot),
    .HSIZE      (ahb_if_h.hsize),
    .HTRANS     (ahb_if_h.htrans),
    .HWDATA     (ahb_if_h.hwdata),
    .HWRITE     (ahb_if_h.hwrite),

    .HRDATA     (ahb_if_h.hrdata),
    .HREADY     (ahb_if_h.hreadyout),
    .HRESP      (ahb_if_h.hresp)
);
  
  initial begin
    aclk = 0;
    forever #5 aclk = ~aclk;
  end

  initial begin
    hclk = 0;
    forever #5 hclk = ~hclk;
  end

  initial begin
    aresetn = 1;
    hresetn = 1;
    #10
    aresetn = 0;
    hresetn = 0;
    hgrant_dummy = 1;
    #20;
    aresetn = 1;
    hresetn = 1;
  end


  genvar i;
  generate
    for (i=0; i<NO_OF_MASTERS; i++) begin : axi4_master_agent_bfm
      axi4_master_agent_bfm #(.MASTER_ID(i)) axi4_master_agent_bfm_h(axi_vif);
      defparam axi4_master_agent_bfm[i].axi4_master_agent_bfm_h.MASTER_ID = i;
    end
    for (i=0; i<NO_OF_SLAVES; i++) begin : axi4_slave_agent_bfm
      axi4_slave_agent_bfm #(.SLAVE_ID(i)) axi4_slave_agent_bfm_h(axi_vif);
      defparam axi4_slave_agent_bfm[i].axi4_slave_agent_bfm_h.SLAVE_ID = i;
    end
  endgenerate
  initial begin
    uvm_config_db#(virtual ahb_if)::set(null, "*", "ahb_if", ahb_vif);
    run_test();
  end

endmodule

`endif
