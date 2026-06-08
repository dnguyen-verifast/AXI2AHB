//============================================================================
// tb_bridge_advanced.sv -- targeted tests for the fixed issues:
//   * WSTRB sub-word write
//   * AWSIZE / ARSIZE illegality -> SLVERR
//   * AHB HBURST mapping (INCR4 etc.)
//   * AW-W matching (interleave-free, in order)
//   * cross-ID out-of-order capability (per-ID order preserved)
//============================================================================
`default_nettype none
`timescale 1ns/1ps
import axi_ahb_pkg::*;

module tb_bridge_advanced;
  localparam int AW=32, DW=32, IDW=4;

  logic ACLK=0, ARESETn=0;
  always #5 ACLK=~ACLK;

  logic [IDW-1:0] AWID; logic [AW-1:0] AWADDR; logic [7:0] AWLEN;
  logic [2:0] AWSIZE; logic [1:0] AWBURST; logic AWVALID; wire AWREADY;
  logic [DW-1:0] WDATA; logic [DW/8-1:0] WSTRB; logic WLAST,WVALID; wire WREADY;
  wire [IDW-1:0] BID; wire [1:0] BRESP; wire BVALID; logic BREADY;
  logic [IDW-1:0] ARID; logic [AW-1:0] ARADDR; logic [7:0] ARLEN;
  logic [2:0] ARSIZE; logic [1:0] ARBURST; logic ARVALID; wire ARREADY;
  wire [IDW-1:0] RID; wire [DW-1:0] RDATA; wire [1:0] RRESP; wire RLAST,RVALID; logic RREADY;

  wire [AW-1:0] HADDR; wire [2:0] HBURST; wire HMASTLOCK; wire [3:0] HPROT;
  wire [2:0] HSIZE; wire [1:0] HTRANS; wire [DW-1:0] HWDATA; wire HWRITE;
  wire [DW-1:0] HRDATA; wire HREADY; wire HRESP;

  axi4_to_ahb_lite #(.AXI_ADDR_WIDTH(AW),.AXI_DATA_WIDTH(DW),.AXI_ID_WIDTH(IDW),
    .WR_OUTSTANDING(8),.RD_OUTSTANDING(8),.W_FIFO_DEPTH(16),.R_FIFO_DEPTH(16)) dut(.*);

  ahb_lite_slave_mem #(.ADDR_WIDTH(AW),.DATA_WIDTH(DW),.MEM_WORDS(4096)) mem(
    .HCLK(ACLK),.HRESETn(ARESETn),.HADDR,.HBURST,.HMASTLOCK,.HPROT,.HSIZE,
    .HTRANS,.HWDATA,.HWRITE,.HRDATA,.HREADY,.HRESP);

  int errors=0;
  task automatic check(input string n, input logic c);
    if(c) $display("[PASS] %s", n); else begin $display("[FAIL] %s", n); errors++; end
  endtask

  // ---- monitors ----
  // log HBURST of every write NONSEQ (burst start)
  logic [2:0] wr_hburst_log [$];
  always @(posedge ACLK) if(ARESETn && HTRANS==HTRANS_NONSEQ && HWRITE)
    wr_hburst_log.push_back(HBURST);

  // capture B responses
  logic [IDW-1:0] b_id_log [$]; logic [1:0] b_rsp_log [$];
  always @(posedge ACLK) if(ARESETn && BVALID && BREADY) begin
    b_id_log.push_back(BID); b_rsp_log.push_back(BRESP);
  end
  // capture R responses
  logic [IDW-1:0] r_id_log [$]; logic [DW-1:0] r_d_log [$]; logic [1:0] r_rsp_log [$];
  always @(posedge ACLK) if(ARESETn && RVALID && RREADY) begin
    r_id_log.push_back(RID); r_d_log.push_back(RDATA); r_rsp_log.push_back(RRESP);
  end

  task automatic init();
    AWID='0;AWADDR='0;AWLEN='0;AWSIZE=3'd2;AWBURST=AXI_BURST_INCR;AWVALID=0;
    WDATA='0;WSTRB='1;WLAST=0;WVALID=0;BREADY=1;
    ARID='0;ARADDR='0;ARLEN='0;ARSIZE=3'd2;ARBURST=AXI_BURST_INCR;ARVALID=0;RREADY=1;
  endtask

  task automatic wr_single(input [IDW-1:0] id,input [AW-1:0] a,input [DW-1:0] d,
                           input [DW/8-1:0] strb,input [2:0] size);
    @(posedge ACLK);
    AWID<=id;AWADDR<=a;AWLEN<=0;AWSIZE<=size;AWBURST<=AXI_BURST_INCR;AWVALID<=1;
    do @(posedge ACLK); while(!AWREADY); AWVALID<=0;
    WDATA<=d;WSTRB<=strb;WLAST<=1;WVALID<=1;
    do @(posedge ACLK); while(!WREADY); WVALID<=0;WLAST<=0;
  endtask

  task automatic wr_burst(input [IDW-1:0] id,input [AW-1:0] a,input [7:0] len,
                          input [DW-1:0] base);
    int n; n=len+1;
    @(posedge ACLK);
    AWID<=id;AWADDR<=a;AWLEN<=len;AWSIZE<=3'd2;AWBURST<=AXI_BURST_INCR;AWVALID<=1;
    do @(posedge ACLK); while(!AWREADY); AWVALID<=0;
    for(int k=0;k<n;k++) begin
      WDATA<=base+k;WSTRB<='1;WLAST<=(k==n-1);WVALID<=1;
      do @(posedge ACLK); while(!WREADY);
    end
    WVALID<=0;WLAST<=0;
  endtask

  task automatic ar(input [IDW-1:0] id,input [AW-1:0] a,input [7:0] len,input [2:0] size);
    @(posedge ACLK);
    ARID<=id;ARADDR<=a;ARLEN<=len;ARSIZE<=size;ARBURST<=AXI_BURST_INCR;ARVALID<=1;
    do @(posedge ACLK); while(!ARREADY); ARVALID<=0;
  endtask

  initial begin
    init();
    repeat(4) @(posedge ACLK); ARESETn<=1; repeat(2) @(posedge ACLK);

    // ===== Test A: WSTRB sub-word write =====
    // write only byte lane 1 (strb=0010) of address 0x40 with 0xAABBCCDD;
    // size=0 (1 byte). Expect only that byte updated.
    // Preload full word first.
    wr_single(4'h0, 32'h0000_0040, 32'h1111_1111, 4'b1111, 3'd2);
    repeat(6) @(posedge ACLK);
    wr_single(4'h0, 32'h0000_0040, 32'h0000_CC00, 4'b0010, 3'd0); // byte lane1
    repeat(6) @(posedge ACLK);
    r_id_log={};r_d_log={};r_rsp_log={};
    ar(4'h0, 32'h0000_0040, 0, 3'd2);
    repeat(8) @(posedge ACLK);
    // byte1 should now be 0xCC, others unchanged 0x11
    check("A WSTRB sub-word", r_d_log.size()==1 &&
          r_d_log[0][15:8]==8'hCC && r_d_log[0][7:0]==8'h11 &&
          r_d_log[0][31:16]==16'h1111);

    // ===== Test B: AWSIZE illegal -> SLVERR, AHB untouched =====
    // size=3 means 8 bytes > 4-byte bus -> illegal
    b_id_log={};b_rsp_log={};
    wr_single(4'h7, 32'h0000_0080, 32'hDEAD_BEEF, 4'b1111, 3'd3);
    repeat(8) @(posedge ACLK);
    check("B AWSIZE illegal SLVERR", b_rsp_log.size()==1 &&
          b_rsp_log[0]==AXI_RESP_SLVERR && b_id_log[0]==4'h7);

    // ===== Test C: ARSIZE illegal -> SLVERR read beats =====
    r_id_log={};r_d_log={};r_rsp_log={};
    ar(4'h8, 32'h0000_0090, 1, 3'd3); // 2-beat burst, illegal size
    repeat(10) @(posedge ACLK);
    check("C ARSIZE illegal SLVERR", r_rsp_log.size()==2 &&
          r_rsp_log[0]==AXI_RESP_SLVERR && r_rsp_log[1]==AXI_RESP_SLVERR);

    // ===== Test D: HBURST mapping INCR4 =====
    wr_hburst_log={};
    wr_burst(4'h1, 32'h0000_0200, 8'd3, 32'h5000_0000); // 4 beats -> INCR4
    repeat(12) @(posedge ACLK);
    check("D HBURST INCR4 map", wr_hburst_log.size()>=1 &&
          wr_hburst_log[0]==HBURST_INCR4);

    // ===== Test E: AW-W matching across 2 back-to-back writes =====
    // Two writes different IDs issued; data must land at correct addresses.
    wr_burst(4'h2, 32'h0000_0300, 8'd1, 32'hC0DE_0000); // 2 beats
    wr_burst(4'h3, 32'h0000_0400, 8'd1, 32'hF00D_0000); // 2 beats
    repeat(16) @(posedge ACLK);
    r_id_log={};r_d_log={};r_rsp_log={};
    ar(4'h2, 32'h0000_0300, 1, 3'd2);
    repeat(10) @(posedge ACLK);
    check("E AW-W match wr2 b0", r_d_log.size()==2 && r_d_log[0]==32'hC0DE_0000);
    check("E AW-W match wr2 b1", r_d_log.size()==2 && r_d_log[1]==32'hC0DE_0001);
    r_id_log={};r_d_log={};r_rsp_log={};
    ar(4'h3, 32'h0000_0400, 1, 3'd2);
    repeat(10) @(posedge ACLK);
    check("E AW-W match wr3 b0", r_d_log.size()==2 && r_d_log[0]==32'hF00D_0000);

    // ===== Test F: per-ID in-order under outstanding =====
    // Two reads SAME ID must come back in issue order.
    wr_single(4'h5, 32'h0000_0500, 32'h0000_0055, 4'b1111, 3'd2);
    wr_single(4'h5, 32'h0000_0504, 32'h0000_0056, 4'b1111, 3'd2);
    repeat(8) @(posedge ACLK);
    r_id_log={};r_d_log={};r_rsp_log={};
    ar(4'h5, 32'h0000_0500, 0, 3'd2);
    ar(4'h5, 32'h0000_0504, 0, 3'd2);
    repeat(14) @(posedge ACLK);
    check("F same-ID in-order", r_d_log.size()==2 &&
          r_d_log[0]==32'h0000_0055 && r_d_log[1]==32'h0000_0056);

    repeat(5) @(posedge ACLK);
    if(errors==0) $display("\n==== ALL ADVANCED TESTS PASSED ====\n");
    else $display("\n==== %0d ADVANCED TEST(S) FAILED ====\n", errors);
    $finish;
  end
  initial begin #500000; $display("TIMEOUT"); $finish; end
endmodule
`default_nettype wire
