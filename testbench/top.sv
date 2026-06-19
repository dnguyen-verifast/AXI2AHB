`ifndef TOP_INCLUDED_
`define TOP_INCLUDED_
module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_globals_pkg::*;
  import ahb_global_pkg::*;
  import x2h_test_pkg::*;

  //import axi_ahb_bridge_pkg::*;
  import axi_ahb_pkg::*;

  parameter  ADDR_WIDTHS = 32;
  parameter DATA_WIDTHS = 32;
  logic aclk;
  logic hclk;

  axi4_if axi_vif (
    .aclk(aclk), 
    .aresetn(reset_vif.rst_n)
  );

  ahb_if ahb_vif (
    .clk(hclk), 
    .resetn(reset_vif.rst_n)
  );

  reset_if reset_vif(.clk(aclk));

axi4_to_ahb_lite #(
    .AXI_ADDR_WIDTH (32),
    .AXI_DATA_WIDTH (32),
    .AXI_ID_WIDTH   (4),
    .TIMEOUT        (32)
) dut (

    //=================================================
    // AXI
    //=================================================
    .ACLK       (aclk),
    .ARESETn    (reset_vif.rst_n),

    .AWID       (axi_vif.awid),
    .AWADDR     (axi_vif.awaddr),
    .AWLEN      (axi_vif.awlen),
    .AWSIZE     (axi_vif.awsize),
    .AWBURST    (axi_vif.awburst),
    .AWPROT     (axi_vif.awprot),
    .AWCACHE    (axi_vif.awcache),
    .AWVALID    (axi_vif.awvalid),
    .AWREADY    (axi_vif.awready),

    .WDATA      (axi_vif.wdata),
    .WSTRB      (axi_vif.wstrb),
    .WLAST      (axi_vif.wlast),
    .WVALID     (axi_vif.wvalid),
    .WREADY     (axi_vif.wready),

    .BID        (axi_vif.bid),
    .BRESP      (axi_vif.bresp),
    .BVALID     (axi_vif.bvalid),
    .BREADY     (axi_vif.bready),

    .ARID       (axi_vif.arid),
    .ARADDR     (axi_vif.araddr),
    .ARLEN      (axi_vif.arlen),
    .ARSIZE     (axi_vif.arsize),
    .ARBURST    (axi_vif.arburst),
    .ARPROT     (axi_vif.arprot),
    .ARCACHE    (axi_vif.arcache),
    .ARVALID    (axi_vif.arvalid),
    .ARREADY    (axi_vif.arready),

    .RID        (axi_vif.rid),
    .RDATA      (axi_vif.rdata),
    .RRESP      (axi_vif.rresp),
    .RLAST      (axi_vif.rlast),
    .RVALID     (axi_vif.rvalid),
    .RREADY     (axi_vif.rready),

    //=================================================
    // AHB-Lite
    //=================================================
    .HSEL       (ahb_vif.hsel),
    .HADDR      (ahb_vif.haddr),
    .HBURST     (ahb_vif.hburst),
    .HMASTLOCK  (ahb_vif.hmastlock),
    .HPROT      (ahb_vif.hprot),
    .HSIZE      (ahb_vif.hsize),
    .HTRANS     (ahb_vif.htrans),
    .HWDATA     (ahb_vif.hwdata),
    .HWRITE     (ahb_vif.hwrite),

    .HRDATA     (ahb_vif.hrdata),
    .HREADYOUT  (ahb_vif.hreadyout),
    .HREADY     (ahb_vif.hready),
    .HRESP      (ahb_vif.hresp)
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
    reset_vif.rst_n = 1;
    #10
    reset_vif.rst_n = 0;
    #20;
    reset_vif.rst_n = 1;
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
    uvm_config_db#(virtual reset_if)::set(null, "*", "rst_vif", reset_vif);
    run_test();
  end

endmodule

`endif
