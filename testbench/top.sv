`ifndef TOP_INCLUDED_
`define TOP_INCLUDED_
module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_globals_pkg::*;
  import ahb_global_pkg::*;
  import x2h_test_pkg::*;

  import axi_ahb_bridge_pkg::*;

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

axi2ahb_bridge_top #(
    .ADDR_WIDTH (32),
    .DATA_WIDTH (32)
) dut (

    .clk        (aclk),
    .rstn       (aresetn),

    //================ AXI WRITE ADDRESS =================
    .awvalid    (axi_vif.awvalid),
    .awready    (axi_vif.awready),
    .awaddr     (axi_vif.awaddr),
    .awlen      (axi_vif.awlen[3:0]),
    .awsize     (axi_vif.awsize),
    .awburst    (axi_vif.awburst),

    //================ AXI WRITE DATA =================
    .wvalid     (axi_vif.wvalid),
    .wready     (axi_vif.wready),
    .wdata      (axi_vif.wdata),
    .wstrb      (axi_vif.wstrb),
    .wlast      (axi_vif.wlast),

    //================ AXI WRITE RESP =================
    .bvalid     (axi_vif.bvalid),
    .bready     (axi_vif.bready),
    .bresp      (axi_vif.bresp),

    //================ AXI READ ADDRESS =================
    .arvalid    (axi_vif.arvalid),
    .arready    (axi_vif.arready),
    .araddr     (axi_vif.araddr),
    .arlen      (axi_vif.arlen[3:0]),
    .arsize     (axi_vif.arsize),
    .arburst    (axi_vif.arburst),

    //================ AXI READ DATA =================
    .rvalid     (axi_vif.rvalid),
    .rready     (axi_vif.rready),
    .rdata      (axi_vif.rdata),
    .rresp      (axi_vif.rresp),
    .rlast      (axi_vif.rlast),

    //================ AHB =================
    .haddr      (ahb_vif.haddr),
    .htrans     (ahb_vif.htrans),
    .hwrite     (ahb_vif.hwrite),
    .hsize      (ahb_vif.hsize),
    .hburst     (ahb_vif.hburst),
    .hwdata     (ahb_vif.hwdata),
    .hstrb      (ahb_vif.hwstrb),

    .hrdata     (ahb_vif.hrdata),
    .hready     (ahb_vif.hready),
    .hresp      (ahb_vif.hresp)
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
