//============================================================================
// tb_axi4_to_ahb_lite.sv -- self-checking testbench
//   Drives AXI master side, checks data correctness, exercises:
//     1) single read/write
//     2) burst read/write (INCR)
//     3) multiple OUTSTANDING reads with different IDs (out-of-order capable)
//============================================================================
`default_nettype none
`timescale 1ns/1ps

module tb_axi4_to_ahb_lite;
  localparam int AW=32, DW=32, IDW=4;

  logic ACLK=0, ARESETn=0;
  always #5 ACLK=~ACLK;

  // AXI signals
  logic [IDW-1:0] AWID;    logic [AW-1:0] AWADDR; logic [7:0] AWLEN;
  logic [2:0] AWSIZE; logic [1:0] AWBURST; logic AWVALID; wire AWREADY;
  logic [DW-1:0] WDATA; logic [DW/8-1:0] WSTRB; logic WLAST,WVALID; wire WREADY;
  wire [IDW-1:0] BID; wire [1:0] BRESP; wire BVALID; logic BREADY;
  logic [IDW-1:0] ARID; logic [AW-1:0] ARADDR; logic [7:0] ARLEN;
  logic [2:0] ARSIZE; logic [1:0] ARBURST; logic ARVALID; wire ARREADY;
  wire [IDW-1:0] RID; wire [DW-1:0] RDATA; wire [1:0] RRESP; wire RLAST,RVALID; logic RREADY;

  // AHB signals
  wire [AW-1:0] HADDR; wire [2:0] HBURST; wire HMASTLOCK; wire [3:0] HPROT;
  wire [2:0] HSIZE; wire [1:0] HTRANS; wire [DW-1:0] HWDATA; wire HWRITE;
  wire [DW-1:0] HRDATA; wire HREADY; wire HRESP;

  axi4_to_ahb_lite #(.AXI_ADDR_WIDTH(AW),.AXI_DATA_WIDTH(DW),.AXI_ID_WIDTH(IDW),
                     .WR_OUTSTANDING(8),.RD_OUTSTANDING(8)) dut(.*);

  ahb_lite_slave_mem #(.ADDR_WIDTH(AW),.DATA_WIDTH(DW),.MEM_WORDS(4096)) mem(
    .HCLK(ACLK),.HRESETn(ARESETn),.HADDR,.HBURST,.HMASTLOCK,.HPROT,.HSIZE,
    .HTRANS,.HWDATA,.HWRITE,.HRDATA,.HREADY,.HRESP);

  int errors=0;

  // -------- defaults --------
  task automatic init_axi();
    AWID='0;AWADDR='0;AWLEN='0;AWSIZE=3'd2;AWBURST=2'b01;AWVALID=0;
    WDATA='0;WSTRB='1;WLAST=0;WVALID=0; BREADY=1;
    ARID='0;ARADDR='0;ARLEN='0;ARSIZE=3'd2;ARBURST=2'b01;ARVALID=0; RREADY=1;
  endtask

  // -------- single write (1 beat) --------
  task automatic axi_write_single(input [IDW-1:0] id, input [AW-1:0] addr,
                                   input [DW-1:0] data);
    @(posedge ACLK);
    AWID<=id; AWADDR<=addr; AWLEN<=8'd0; AWSIZE<=3'd2; AWBURST<=2'b01; AWVALID<=1;
    do @(posedge ACLK); while(!AWREADY);
    AWVALID<=0;
    WDATA<=data; WSTRB<='1; WLAST<=1; WVALID<=1;
    do @(posedge ACLK); while(!WREADY);
    WVALID<=0; WLAST<=0;
  endtask

  // -------- burst write (len+1 beats, INCR) --------
  task automatic axi_write_burst(input [IDW-1:0] id, input [AW-1:0] addr,
                                  input [7:0] len, input [DW-1:0] base);
    int n; n=len+1;
    @(posedge ACLK);
    AWID<=id; AWADDR<=addr; AWLEN<=len; AWSIZE<=3'd2; AWBURST<=2'b01; AWVALID<=1;
    do @(posedge ACLK); while(!AWREADY);
    AWVALID<=0;
    for(int k=0;k<n;k++) begin
      WDATA<=base+k; WSTRB<='1; WLAST<=(k==n-1); WVALID<=1;
      do @(posedge ACLK); while(!WREADY);
    end
    WVALID<=0; WLAST<=0;
  endtask

  // -------- issue read address only (non-blocking on data) --------
  task automatic axi_ar(input [IDW-1:0] id, input [AW-1:0] addr, input [7:0] len);
    @(posedge ACLK);
    ARID<=id; ARADDR<=addr; ARLEN<=len; ARSIZE<=3'd2; ARBURST<=2'b01; ARVALID<=1;
    do @(posedge ACLK); while(!ARREADY);
    ARVALID<=0;
  endtask

  // collect read beats
  int      r_count;
  logic [DW-1:0] r_log_data [$];
  logic [IDW-1:0] r_log_id  [$];
  always @(posedge ACLK) begin
    if(ARESETn && RVALID && RREADY) begin
      r_log_data.push_back(RDATA);
      r_log_id.push_back(RID);
    end
  end

  // -------- checks --------
  task automatic check(input string name, input logic cond);
    if(cond) $display("[PASS] %s", name);
    else begin $display("[FAIL] %s", name); errors++; end
  endtask

  initial begin
    init_axi();
    repeat(4) @(posedge ACLK);
    ARESETn<=1;
    repeat(2) @(posedge ACLK);

    // ---- Test 1: single write then read back ----
    axi_write_single(4'h1, 32'h0000_0010, 32'hCAFE_0001);
    repeat(6) @(posedge ACLK);
    r_log_data={}; r_log_id={};
    axi_ar(4'h1, 32'h0000_0010, 8'd0);
    repeat(8) @(posedge ACLK);
    check("T1 single rw", (r_log_data.size()==1) && (r_log_data[0]==32'hCAFE_0001));

    // ---- Test 2: burst write + burst read ----
    axi_write_burst(4'h2, 32'h0000_0100, 8'd3, 32'h1000_0000); // 4 beats
    repeat(10) @(posedge ACLK);
    r_log_data={}; r_log_id={};
    axi_ar(4'h2, 32'h0000_0100, 8'd3);
    repeat(16) @(posedge ACLK);
    check("T2 burst size", r_log_data.size()==4);
    check("T2 burst d0", r_log_data[0]==32'h1000_0000);
    check("T2 burst d3", r_log_data[3]==32'h1000_0003);

    // ---- Test 3: multiple OUTSTANDING reads, different IDs ----
    // preload distinct values
    axi_write_single(4'h3, 32'h0000_0200, 32'hAAAA_0000);
    axi_write_single(4'h4, 32'h0000_0204, 32'hBBBB_0000);
    axi_write_single(4'h5, 32'h0000_0208, 32'hCCCC_0000);
    repeat(10) @(posedge ACLK);
    r_log_data={}; r_log_id={};
    // fire 3 ARs back-to-back without waiting for data => outstanding
    axi_ar(4'h3, 32'h0000_0200, 8'd0);
    axi_ar(4'h4, 32'h0000_0204, 8'd0);
    axi_ar(4'h5, 32'h0000_0208, 8'd0);
    repeat(20) @(posedge ACLK);
    check("T3 outstanding count", r_log_data.size()==3);
    // verify each ID got correct data (regardless of order)
    begin
      logic ok3,ok4,ok5; ok3=0;ok4=0;ok5=0;
      for(int i=0;i<r_log_data.size();i++) begin
        if(r_log_id[i]==4'h3 && r_log_data[i]==32'hAAAA_0000) ok3=1;
        if(r_log_id[i]==4'h4 && r_log_data[i]==32'hBBBB_0000) ok4=1;
        if(r_log_id[i]==4'h5 && r_log_data[i]==32'hCCCC_0000) ok5=1;
      end
      check("T3 id3 data", ok3);
      check("T3 id4 data", ok4);
      check("T3 id5 data", ok5);
    end

    repeat(5) @(posedge ACLK);
    if(errors==0) $display("\n==== ALL TESTS PASSED ====\n");
    else          $display("\n==== %0d TEST(S) FAILED ====\n", errors);
    $finish;
  end

  initial begin #200000; $display("TIMEOUT"); $finish; end
endmodule
`default_nettype wire
