`ifndef TOP_INCLUDED_
`define TOP_INCLUDED_
module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_globals_pkg::*;
  import ahb_global_pkg::*;
  import x2h_test_pkg::*;

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

axi_ahb_bridge_top #(
    .DATA_WIDTH (32),
    .ADDR_WIDTH (32),
    .ID_WIDTH   (4)
) dut (

    //================ AXI =================
    .axi_clk        (aclk),
    .axi_rstn       (aresetn),

    .s_axi_awid     (axi_vif.awid),
    .s_axi_awaddr   (axi_vif.awaddr),
    .s_axi_awlen    (axi_vif.awlen),
    .s_axi_awsize   (axi_vif.awsize),
    .s_axi_awburst  (axi_vif.awburst),
    .s_axi_awlock   (axi_vif.awlock[0]),
    .s_axi_awcache  ({2'b00,axi_vif.awcache}),
    .s_axi_awprot   (axi_vif.awprot),
    .s_axi_awvalid  (axi_vif.awvalid),
    .s_axi_awready  (axi_vif.awready),

    .s_axi_wdata    (axi_vif.wdata),
    .s_axi_wstrb    (axi_vif.wstrb),
    .s_axi_wlast    (axi_vif.wlast),
    .s_axi_wvalid   (axi_vif.wvalid),
    .s_axi_wready   (axi_vif.wready),

    .s_axi_bid      (axi_vif.bid),
    .s_axi_bresp    (axi_vif.bresp),
    .s_axi_bvalid   (axi_vif.bvalid),
    .s_axi_bready   (axi_vif.bready),

    .s_axi_arid     (axi_vif.arid),
    .s_axi_araddr   (axi_vif.araddr),
    .s_axi_arlen    (axi_vif.arlen),
    .s_axi_arsize   (axi_vif.arsize),
    .s_axi_arburst  (axi_vif.arburst),
    .s_axi_arlock   (axi_vif.arlock[0]),
    .s_axi_arcache  ({2'b00,axi_vif.arcache}),
    .s_axi_arprot   (axi_vif.arprot),
    .s_axi_arvalid  (axi_vif.arvalid),
    .s_axi_arready  (axi_vif.arready),

    .s_axi_rid      (axi_vif.rid),
    .s_axi_rdata    (axi_vif.rdata),
    .s_axi_rresp    (axi_vif.rresp),
    .s_axi_rlast    (axi_vif.rlast),
    .s_axi_rvalid   (axi_vif.rvalid),
    .s_axi_rready   (axi_vif.rready),

    //================ AHB =================
    .ahb_clk        (hclk),
    .ahb_rstn       (hresetn),

    .m_ahb_haddr    (ahb_vif.haddr),
    .m_ahb_hburst   (ahb_vif.hburst),
    .m_ahb_hsize    (ahb_vif.hsize),
    .m_ahb_htrans   (ahb_vif.htrans),
    .m_ahb_hwdata   (ahb_vif.hwdata),
    .m_ahb_hwrite   (ahb_vif.hwrite),
    .m_ahb_hsel     (ahb_vif.hsel),
    .m_ahb_hmastlock(ahb_vif.hmastlock),

    .m_ahb_hrdata   (ahb_vif.hrdata),
    .m_ahb_hready   (ahb_vif.hready),
    .m_ahb_hresp    (ahb_vif.hresp)
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
