//============================================================================
// axi4_to_ahb_lite.sv  (top level)
//----------------------------------------------------------------------------
// AXI4 (slave) -> AHB-Lite (master) bridge.
//
// Composition:
//   - axi_write_engine : AW/W/B handling, AW-W matching, WSTRB, AWSIZE legality
//   - axi_read_engine  : AR/R handling, streaming bounded R FIFO, ARSIZE legality
//   - AHB arbiter      : shares the single AHB-Lite bus between the two engines.
//                        This is what realizes cross-ID out-of-order: the
//                        arbiter may grant read then write then read, so two
//                        transactions with different IDs can complete in any
//                        order relative to each other. Within one engine, and
//                        thus within one ID, order is strictly preserved.
//
// AHB-Lite pipeline note:
//   AHB has address phase (cycle N) and data phase (cycle N+1). Each engine
//   drives its address-phase signals while granted; the data phase uses the
//   shared HRDATA/HRESP one cycle later. The arbiter holds the grant stable
//   for a full beat (address+data) to keep the pipeline coherent. For
//   simplicity it grants one beat at a time and re-arbitrates between beats;
//   this keeps a single transfer atomic and is always protocol-legal.
//============================================================================
`default_nettype none
import axi_ahb_pkg::*;

module axi4_to_ahb_lite #(
  parameter int AXI_ADDR_WIDTH = 32,
  parameter int AXI_DATA_WIDTH = 32,
  parameter int AXI_ID_WIDTH   = 4,
  parameter int WR_OUTSTANDING = 8,   // pow2
  parameter int RD_OUTSTANDING = 8,   // pow2
  parameter int W_FIFO_DEPTH   = 16,  // pow2
  parameter int R_FIFO_DEPTH   = 16   // pow2
)(
  input  wire                         ACLK,
  input  wire                         ARESETn,

  // ---- AXI4 slave ----
  input  wire [AXI_ID_WIDTH-1:0]      AWID,
  input  wire [AXI_ADDR_WIDTH-1:0]    AWADDR,
  input  wire [7:0]                   AWLEN,
  input  wire [2:0]                   AWSIZE,
  input  wire [1:0]                   AWBURST,
  input  wire                         AWVALID,
  output wire                         AWREADY,
  input  wire [AXI_DATA_WIDTH-1:0]    WDATA,
  input  wire [AXI_DATA_WIDTH/8-1:0]  WSTRB,
  input  wire                         WLAST,
  input  wire                         WVALID,
  output wire                         WREADY,
  output wire [AXI_ID_WIDTH-1:0]      BID,
  output wire [1:0]                   BRESP,
  output wire                         BVALID,
  input  wire                         BREADY,
  input  wire [AXI_ID_WIDTH-1:0]      ARID,
  input  wire [AXI_ADDR_WIDTH-1:0]    ARADDR,
  input  wire [7:0]                   ARLEN,
  input  wire [2:0]                   ARSIZE,
  input  wire [1:0]                   ARBURST,
  input  wire                         ARVALID,
  output wire                         ARREADY,
  output wire [AXI_ID_WIDTH-1:0]      RID,
  output wire [AXI_DATA_WIDTH-1:0]    RDATA,
  output wire [1:0]                   RRESP,
  output wire                         RLAST,
  output wire                         RVALID,
  input  wire                         RREADY,

  // ---- AHB-Lite master ----
  output wire                         HSEL,       // slave-select (active on a real transfer)
  output reg  [AXI_ADDR_WIDTH-1:0]    HADDR,
  output reg  [2:0]                   HBURST,
  output reg                          HMASTLOCK,
  output reg  [3:0]                   HPROT,
  output reg  [2:0]                   HSIZE,
  output reg  [1:0]                   HTRANS,
  output reg  [AXI_DATA_WIDTH-1:0]    HWDATA,
  output reg                          HWRITE,
  input  wire [AXI_DATA_WIDTH-1:0]    HRDATA,
  input  wire                         HREADYOUT,  // ready FROM the slave
  output wire                         HREADY,     // ready TO the master (= HREADYOUT for 1 slave)
  input  wire                         HRESP
);

  // In a single-slave system HREADY simply mirrors the slave's HREADYOUT.
  // (With a decoder/mux this would combine HREADYOUT of all slaves.)
  assign HREADY = HREADYOUT;

  // HSEL: the bridge selects the slave whenever it drives a real (non-IDLE)
  // address phase. A decoder would normally produce this from HADDR; with one
  // slave covering the whole map, "any active transfer" == "select the slave".
  assign HSEL = (HTRANS != HTRANS_IDLE);

  // engine <-> arbiter wires
  wire                       wr_req, wr_busy, wr_grant;
  wire [AXI_ADDR_WIDTH-1:0]  wr_haddr;
  wire [2:0]                 wr_hsize, wr_hburst;
  wire [1:0]                 wr_htrans;
  wire [AXI_DATA_WIDTH-1:0]  wr_hwdata;

  wire                       rd_req, rd_busy, rd_grant;
  wire [AXI_ADDR_WIDTH-1:0]  rd_haddr;
  wire [2:0]                 rd_hsize, rd_hburst;
  wire [1:0]                 rd_htrans;

  // ---- write engine ----
  axi_write_engine #(
    .ADDR_W(AXI_ADDR_WIDTH), .DATA_W(AXI_DATA_WIDTH), .ID_W(AXI_ID_WIDTH),
    .AW_FIFO_DEPTH(WR_OUTSTANDING), .W_FIFO_DEPTH(W_FIFO_DEPTH)
  ) u_wr (
    .clk(ACLK), .rstn(ARESETn),
    .AWID, .AWADDR, .AWLEN, .AWSIZE, .AWBURST, .AWVALID, .AWREADY,
    .WDATA, .WSTRB, .WLAST, .WVALID, .WREADY,
    .BID, .BRESP, .BVALID, .BREADY,
    .wr_req, .wr_busy, .wr_grant, .wr_haddr, .wr_hsize, .wr_hburst, .wr_htrans, .wr_hwdata,
    .ahb_hready(HREADY), .ahb_hresp(HRESP)
  );

  // ---- read engine ----
  axi_read_engine #(
    .ADDR_W(AXI_ADDR_WIDTH), .DATA_W(AXI_DATA_WIDTH), .ID_W(AXI_ID_WIDTH),
    .AR_FIFO_DEPTH(RD_OUTSTANDING), .R_FIFO_DEPTH(R_FIFO_DEPTH)
  ) u_rd (
    .clk(ACLK), .rstn(ARESETn),
    .ARID, .ARADDR, .ARLEN, .ARSIZE, .ARBURST, .ARVALID, .ARREADY,
    .RID, .RDATA, .RRESP, .RLAST, .RVALID, .RREADY,
    .rd_req, .rd_busy, .rd_grant, .rd_haddr, .rd_hsize, .rd_hburst, .rd_htrans,
    .ahb_hrdata(HRDATA), .ahb_hready(HREADY), .ahb_hresp(HRESP)
  );

  //==========================================================================
  // AHB arbiter (burst-lock)
  //   - A "holder" owns the AHB bus for an entire burst. While the holder is
  //     busy (mid-burst) it keeps the grant, so address phases stream back-to
  //     -back and data phases overlap them -- no HTRANS=IDLE is inserted
  //     between beats.
  //   - When no one holds the bus, arbitrate by round-robin priority.
  //   - HWDATA is driven by the write engine and is already aligned to the data
  //     phase (the engine registers it one cycle behind its HADDR).
  //==========================================================================
  typedef enum logic [1:0] { HOLD_NONE, HOLD_WR, HOLD_RD } hold_e;
  hold_e holder;
  logic  prefer_read;

  // grant: combinational. The holder keeps its grant; if free, pick by priority.
  logic grant_wr_c, grant_rd_c;
  always_comb begin
    grant_wr_c = 1'b0;
    grant_rd_c = 1'b0;
    unique case (holder)
      HOLD_WR: grant_wr_c = 1'b1;
      HOLD_RD: grant_rd_c = 1'b1;
      default: begin // HOLD_NONE -> arbitrate
        if (prefer_read) begin
          if (rd_req)      grant_rd_c = 1'b1;
          else if (wr_req) grant_wr_c = 1'b1;
        end else begin
          if (wr_req)      grant_wr_c = 1'b1;
          else if (rd_req) grant_rd_c = 1'b1;
        end
      end
    endcase
  end

  assign wr_grant = grant_wr_c;
  assign rd_grant = grant_rd_c;

  // AHB address-phase mux. HTRANS comes straight from the granted engine, which
  // drives NONSEQ/SEQ continuously through the burst (IDLE only when idle).
  always_comb begin
    HADDR     = '0;
    HSIZE     = 3'd0;
    HBURST    = HBURST_SINGLE;
    HTRANS    = HTRANS_IDLE;
    HWRITE    = 1'b0;
    HMASTLOCK = 1'b0;
    HPROT     = 4'b0011;       // data, privileged, non-buf, non-cache
    if (grant_wr_c) begin
      HADDR  = wr_haddr;  HSIZE = wr_hsize; HBURST = wr_hburst;
      HTRANS = wr_htrans; HWRITE = 1'b1;
    end else if (grant_rd_c) begin
      HADDR  = rd_haddr;  HSIZE = rd_hsize; HBURST = rd_hburst;
      HTRANS = rd_htrans; HWRITE = 1'b0;
    end
  end

  // HWDATA: only a write supplies data; the write engine already aligns it to
  // the data phase, so forward it whenever a write currently holds the bus.
  always_comb HWDATA = wr_hwdata;

  // holder tracking
  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      holder      <= HOLD_NONE;
      prefer_read <= 1'b0;
    end else begin
      unique case (holder)
        HOLD_NONE: begin
          if (grant_wr_c)      holder <= HOLD_WR;
          else if (grant_rd_c) holder <= HOLD_RD;
        end
        HOLD_WR: if (!wr_busy) begin
          holder      <= HOLD_NONE;
          prefer_read <= 1'b1;     // alternate to read next
        end
        HOLD_RD: if (!rd_busy) begin
          holder      <= HOLD_NONE;
          prefer_read <= 1'b0;
        end
        default: holder <= HOLD_NONE;
      endcase
    end
  end
endmodule
`default_nettype wire
