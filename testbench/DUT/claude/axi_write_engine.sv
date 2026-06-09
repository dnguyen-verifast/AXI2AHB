//============================================================================
// axi_write_engine.sv
//----------------------------------------------------------------------------
// Handles the AXI WRITE path of the bridge.
//
// Correct AW-W matching (AXI4):
//   - AXI4 prohibits write-data interleaving. The W beats of transaction N
//     arrive entirely before the W beats of transaction N+1, in the same
//     order their AW commands were accepted.
//   - Therefore we keep ONE AW command FIFO and ONE W data FIFO. The engine
//     pops the head AW, then consumes exactly (len+1) W beats for it. This is
//     the matching: by arrival order, with no interleave assumed or allowed.
//
// WSTRB handling:
//   - AHB-Lite has no write-strobe signal. We honor WSTRB by:
//       * driving HSIZE = AWSIZE (the slave only updates the addressed bytes),
//       * advancing HADDR by the byte offset implied by the strobe / size,
//     For full-word writes (WSTRB all ones, size=bus width) this is a plain
//     word write. For sub-size writes the AHB slave uses HSIZE+HADDR to know
//     which lane is active. WSTRB that is non-contiguous / not size-aligned is
//     not representable on AHB-Lite -> flagged as SLVERR (see strb_to_size).
//
// AWSIZE legality:
//   - If AWSIZE > bus width, the whole transaction returns SLVERR and is NOT
//     issued onto AHB.
//
// Burst mapping:
//   - HBURST is mapped from (AWBURST, AWLEN) via map_hburst() and per-beat
//     HTRANS is NONSEQ (first) then SEQ.
//
// Ordering / out-of-order:
//   - Per-ID response order is naturally preserved because, within one ID, AW
//     are issued in order and B is produced in completion order (which equals
//     issue order for that ID). Different IDs can complete out of order because
//     the shared arbiter (in the top level) may interleave issue across IDs.
//============================================================================
`default_nettype none
import axi_ahb_pkg::*;

module axi_write_engine #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 32,
  parameter int ID_W   = 4,
  parameter int AW_FIFO_DEPTH = 8,   // outstanding write commands (pow2)
  parameter int W_FIFO_DEPTH  = 16   // buffered write-data beats (pow2)
)(
  input  wire                 clk,
  input  wire                 rstn,

  // ---- AXI write address ----
  input  wire [ID_W-1:0]      AWID,
  input  wire [ADDR_W-1:0]    AWADDR,
  input  wire [7:0]           AWLEN,
  input  wire [2:0]           AWSIZE,
  input  wire [1:0]           AWBURST,
  input  wire                 AWVALID,
  output wire                 AWREADY,
  // ---- AXI write data ----
  input  wire [DATA_W-1:0]    WDATA,
  input  wire [DATA_W/8-1:0]  WSTRB,
  input  wire                 WLAST,
  input  wire                 WVALID,
  output wire                 WREADY,
  // ---- AXI write response ----
  output wire [ID_W-1:0]      BID,
  output wire [1:0]           BRESP,
  output wire                 BVALID,
  input  wire                 BREADY,

  // ---- request to shared AHB arbiter ----
  output wire                 wr_req,        // engine wants the AHB bus
  output wire                 wr_busy,       // engine is mid-burst (hold grant)
  input  wire                 wr_grant,      // arbiter granted the bus
  output wire [ADDR_W-1:0]    wr_haddr,
  output wire [2:0]           wr_hsize,
  output wire [2:0]           wr_hburst,
  output wire [1:0]           wr_htrans,
  output wire [DATA_W-1:0]    wr_hwdata,
  input  wire                 ahb_hready,    // shared HREADY
  input  wire                 ahb_hresp      // shared HRESP
);

  localparam int DATA_BYTES = DATA_W/8;

  // ============== AW command FIFO ==============
  typedef struct packed {
    logic [ID_W-1:0]   id;
    logic [ADDR_W-1:0] addr;
    logic [7:0]        len;
    logic [2:0]        size;
    logic [1:0]        burst;
    logic              illegal;   // AWSIZE illegal -> SLVERR, skip AHB
  } awcmd_t;

  awcmd_t awc_din, awc_dout;
  logic   awc_push, awc_pop, awc_full, awc_empty;

  assign awc_din.id      = AWID;
  assign awc_din.addr    = AWADDR;
  assign awc_din.len     = AWLEN;
  assign awc_din.size    = AWSIZE;
  assign awc_din.burst   = AWBURST;
  assign awc_din.illegal = ~size_legal(AWSIZE, DATA_BYTES);

  assign AWREADY  = ~awc_full;
  assign awc_push = AWVALID & AWREADY;

  sync_fifo #(.WIDTH($bits(awcmd_t)), .DEPTH(AW_FIFO_DEPTH)) u_awfifo (
    .clk, .rstn, .push(awc_push), .din(awc_din),
    .pop(awc_pop), .dout(awc_dout), .full(awc_full), .empty(awc_empty),
    .count());

  // ============== W data FIFO ==============
  typedef struct packed {
    logic [DATA_W-1:0]   data;
    logic [DATA_BYTES-1:0] strb;
    logic                last;
  } wdat_t;

  wdat_t wd_din, wd_dout;
  logic  wd_push, wd_full, wd_empty;
  logic  wd_pop;   // combinational: advances head when a beat is consumed

  assign wd_din.data = WDATA;
  assign wd_din.strb = WSTRB;
  assign wd_din.last = WLAST;

  assign WREADY  = ~wd_full;
  assign wd_push = WVALID & WREADY;

  sync_fifo #(.WIDTH($bits(wdat_t)), .DEPTH(W_FIFO_DEPTH)) u_wfifo (
    .clk, .rstn, .push(wd_push), .din(wd_din),
    .pop(wd_pop), .dout(wd_dout), .full(wd_full), .empty(wd_empty),
    .count());

  // ============== B response FIFO ==============
  // One B entry produced per completed AW. Depth = outstanding writes.
  typedef struct packed { logic [ID_W-1:0] id; logic [1:0] resp; } brsp_t;
  brsp_t br_din, br_dout;
  logic  br_push, br_pop, br_full, br_empty;

  sync_fifo #(.WIDTH($bits(brsp_t)), .DEPTH(AW_FIFO_DEPTH)) u_bfifo (
    .clk, .rstn, .push(br_push), .din(br_din),
    .pop(br_pop), .dout(br_dout), .full(br_full), .empty(br_empty),
    .count());

  assign BVALID = ~br_empty;
  assign BID    = br_dout.id;
  assign BRESP  = br_dout.resp;
  assign br_pop = BVALID & BREADY;

  // ============== Convert WSTRB -> (size, byte offset) ==============
  // Returns: legal (contiguous & size-aligned), the implied size, and the
  // byte address offset of the active lane group.
  function automatic void strb_decode(
      input  logic [DATA_BYTES-1:0] strb,
      input  logic [2:0]            axsize,
      output logic                  legal,
      output logic [ADDR_W-1:0]     offset);
    int lo, hi, cnt;
    begin
      lo = -1; hi = -1; cnt = 0;
      for (int b = 0; b < DATA_BYTES; b++) begin
        if (strb[b]) begin
          if (lo < 0) lo = b;
          hi  = b;
          cnt = cnt + 1;
        end
      end
      offset = 0;
      if (cnt == 0) begin
        legal = 1'b1;             // no-op write, harmless
        offset = 0;
      end else begin
        // contiguous? all bytes between lo..hi set, count == (hi-lo+1)
        legal = (cnt == (hi - lo + 1)) && (cnt == (1 << axsize));
        offset = lo[ADDR_W-1:0];
      end
    end
  endfunction

  // ============== Write issue FSM ==============
  // AHB-Lite pipeline: the address phase of beat N+1 overlaps the data phase
  // of beat N. We present a new address every cycle HREADY=1, and HWDATA is
  // naturally one cycle behind HADDR (data phase). No IDLE is inserted between
  // beats; HTRANS goes NONSEQ (first) -> SEQ (rest) for INCR/WRAP, or NONSEQ
  // every beat for FIXED.
  //
  // States:
  //   WS_IDLE  : no active write; pull next AW.
  //   WS_RUN   : streaming address phases of the burst onto AHB.
  //   WS_LAST  : address phase done, waiting for the final data phase to retire.
  //   WS_ILLEG : illegal AxSIZE; drain W beats, no AHB access.
  //   WS_RESP  : push B response.
  typedef enum logic [2:0] { WS_IDLE, WS_RUN, WS_LAST, WS_ILLEG, WS_RESP } ws_e;
  ws_e ws;

  logic [ID_W-1:0]   cur_id;
  logic [ADDR_W-1:0] cur_addr;     // address of the beat currently in ADDR phase
  logic [7:0]        cur_len;
  logic [2:0]        cur_size;
  logic [1:0]        cur_burst;
  logic [8:0]        cur_abeat;     // index of beat being presented (addr phase)
  logic [8:0]        cur_nbeats;
  logic [1:0]        cur_resp;
  logic              cur_illegal;
  logic [2:0]        cur_hburst;
  logic              first_beat;

  // outstanding data-phase tracker: number of address phases accepted but whose
  // data phase has not yet completed. For AHB-Lite this is 0 or 1.
  logic              dphase_pend;

  // strobe decode for the current W beat
  logic              strb_legal;
  logic [ADDR_W-1:0] strb_off;
  always_comb strb_decode(wd_dout.strb, cur_size, strb_legal, strb_off);

  // we can present an address-phase beat when we have its W data available
  wire addr_beat_ready = (ws == WS_RUN) && !wd_empty;

  // request / busy to arbiter
  assign wr_req  = (ws == WS_RUN) && !wd_empty && !cur_illegal;
  assign wr_busy = (ws == WS_RUN) || (ws == WS_LAST);

  // AHB address-phase drive (valid while granted & presenting)
  assign wr_haddr  = cur_addr + (cur_illegal ? '0 : strb_off);
  assign wr_hsize  = cur_size;
  assign wr_hburst = cur_hburst;
  // HTRANS: only drive a real (NONSEQ/SEQ) transfer while we are actually
  // presenting a beat in WS_RUN with its W data available; otherwise IDLE so
  // we never present a spurious extra address (e.g. during WS_LAST while the
  // final data phase drains).
  wire present_beat = (ws == WS_RUN) && !wd_empty && !cur_illegal;
  assign wr_htrans = !present_beat ? HTRANS_IDLE
                   : (cur_burst == AXI_BURST_FIXED) ? HTRANS_NONSEQ
                   : (first_beat ? HTRANS_NONSEQ : HTRANS_SEQ);
  // HWDATA: in AHB-Lite the write data is presented during the DATA phase,
  // one cycle after the matching address phase. We keep the W beat at the FIFO
  // head during its data phase and present it combinationally; the beat is
  // popped only when its data phase retires. To line HWDATA up with the data
  // phase we register the head into hwdata_q at address-accept time and hold it.
  logic [DATA_W-1:0] hwdata_q;
  assign wr_hwdata = hwdata_q;

  // an address phase is "accepted" this cycle when presenting, granted, ready
  wire addr_accept = wr_req && wr_grant && ahb_hready;
  // a data phase retires this cycle when one was pending and the bus is ready
  wire data_retire = dphase_pend && ahb_hready;

  // W data FIFO advances: on a legal address accept, or while draining an
  // illegal transaction. Combinational so the head is ready for the next beat.
  assign wd_pop = (ws == WS_RUN)   ? addr_accept :
                  (ws == WS_ILLEG) ? !wd_empty   : 1'b0;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      ws <= WS_IDLE;
      cur_id<='0; cur_addr<='0; cur_len<='0; cur_size<='0; cur_burst<='0;
      cur_abeat<=9'd0; cur_nbeats<=9'd0; cur_resp<=AXI_RESP_OKAY;
      cur_illegal<=1'b0; cur_hburst<=HBURST_SINGLE; first_beat<=1'b1;
      dphase_pend<=1'b0; hwdata_q<='0;
      awc_pop<=1'b0; br_push<=1'b0; br_din<='0;
    end else begin
      awc_pop<=1'b0; br_push<=1'b0;

      // ----- retire a data phase (capture HRESP) -----
      if (data_retire) begin
        if (ahb_hresp) cur_resp <= AXI_RESP_SLVERR;
        dphase_pend <= 1'b0;
      end

      unique case (ws)
        // ---- pull next AW command ----
        WS_IDLE: begin
          if (!awc_empty && !br_full) begin
            cur_id      <= awc_dout.id;
            cur_addr    <= awc_dout.addr;
            cur_len     <= awc_dout.len;
            cur_size    <= awc_dout.size;
            cur_burst   <= awc_dout.burst;
            cur_nbeats  <= beats_of(awc_dout.len);
            cur_abeat   <= 9'd0;
            cur_resp    <= awc_dout.illegal ? AXI_RESP_SLVERR : AXI_RESP_OKAY;
            cur_illegal <= awc_dout.illegal;
            cur_hburst  <= map_hburst(awc_dout.burst, awc_dout.len);
            first_beat  <= 1'b1;
            awc_pop     <= 1'b1;
            ws          <= awc_dout.illegal ? WS_ILLEG : WS_RUN;
          end
        end

        // ---- stream address phases; data phases overlap automatically ----
        WS_RUN: begin
          // sub-word strobe legality (per beat being presented)
          if (!wd_empty && !strb_legal) cur_resp <= AXI_RESP_SLVERR;

          if (addr_accept) begin
            // this beat's address was latched; present its data next cycle.
            // wd_pop (combinational) advances the FIFO head this cycle so the
            // next beat's data is ready; hwdata_q holds THIS beat's data for
            // its data phase.
            hwdata_q    <= wd_dout.data;
            dphase_pend <= 1'b1;
            first_beat  <= 1'b0;
            cur_addr    <= axi_next_addr(cur_addr, cur_size, cur_len, cur_burst);

            if (cur_abeat + 9'd1 >= cur_nbeats) begin
              // last address phase presented; wait for its data phase
              ws <= WS_LAST;
            end else begin
              cur_abeat <= cur_abeat + 9'd1;
            end
          end
        end

        // ---- final beat: address phase already done; HTRANS must go IDLE so
        //      we don't present a spurious next address while the last data
        //      phase completes. Retire then respond. ----
        WS_LAST: begin
          // when the pending (last) data phase retires, finish.
          if (data_retire || !dphase_pend) begin
            ws <= WS_RESP;
          end
        end

        // ---- illegal AxSIZE: drain the W beats, no AHB access ----
        WS_ILLEG: begin
          if (!wd_empty) begin
            if (wd_dout.last) ws <= WS_RESP;
          end
        end

        // ---- push B response ----
        WS_RESP: begin
          if (!br_full) begin
            br_din.id   <= cur_id;
            br_din.resp <= cur_resp;
            br_push     <= 1'b1;
            ws          <= WS_IDLE;
          end
        end

        default: ws <= WS_IDLE;
      endcase
    end
  end
endmodule
`default_nettype wire
