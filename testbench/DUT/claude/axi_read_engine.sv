//============================================================================
// axi_read_engine.sv
//----------------------------------------------------------------------------
// Handles the AXI READ path of the bridge.
//
// Read-data buffering (fixed the heavy 256-beat-per-slot ROB):
//   - No per-transaction full-burst storage. Instead a single small bounded
//     R-data FIFO streams beats out as soon as AHB returns them.
//   - Backpressure: the engine only issues a new AHB read beat when the FIFO
//     has space. If the AXI master stalls RREADY, the FIFO fills, the engine
//     stops issuing on AHB (HTRANS=IDLE), and no data is lost.
//
// AxSIZE legality:
//   - Illegal AxSIZE -> the transaction returns SLVERR beats (RDATA = 0) for
//     its full length, without touching AHB.
//
// Burst mapping:
//   - HBURST mapped from (ARBURST, ARLEN); per-beat HTRANS NONSEQ then SEQ.
//
// Ordering / out-of-order:
//   - This engine processes its AR FIFO in order, so R beats for a given ID
//     come out in order (per-ID in-order, AXI4 requirement). Out-of-order
//     across IDs is provided by the top-level arbiter interleaving read vs
//     write issue and by the master being free to use multiple IDs; each ID's
//     responses remain correctly ordered.
//============================================================================
`default_nettype none
import axi_ahb_pkg::*;

module axi_read_engine #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 32,
  parameter int ID_W   = 4,
  parameter int AR_FIFO_DEPTH = 8,    // outstanding read commands (pow2)
  parameter int R_FIFO_DEPTH  = 16    // streaming read-data buffer (pow2)
)(
  input  wire                 clk,
  input  wire                 rstn,

  // ---- AXI read address ----
  input  wire [ID_W-1:0]      ARID,
  input  wire [ADDR_W-1:0]    ARADDR,
  input  wire [7:0]           ARLEN,
  input  wire [2:0]           ARSIZE,
  input  wire [1:0]           ARBURST,
  input  wire                 ARVALID,
  output wire                 ARREADY,
  // ---- AXI read data ----
  output wire [ID_W-1:0]      RID,
  output wire [DATA_W-1:0]    RDATA,
  output wire [1:0]           RRESP,
  output wire                 RLAST,
  output wire                 RVALID,
  input  wire                 RREADY,

  // ---- request to shared AHB arbiter ----
  output wire                 rd_req,
  input  wire                 rd_grant,
  output wire [ADDR_W-1:0]    rd_haddr,
  output wire [2:0]           rd_hsize,
  output wire [2:0]           rd_hburst,
  output wire [1:0]           rd_htrans,
  input  wire [DATA_W-1:0]    ahb_hrdata,
  input  wire                 ahb_hready,
  input  wire                 ahb_hresp
);

  localparam int DATA_BYTES = DATA_W/8;

  // ============== AR command FIFO ==============
  typedef struct packed {
    logic [ID_W-1:0]   id;
    logic [ADDR_W-1:0] addr;
    logic [7:0]        len;
    logic [2:0]        size;
    logic [1:0]        burst;
    logic              illegal;
  } arcmd_t;

  arcmd_t arc_din, arc_dout;
  logic   arc_push, arc_pop, arc_full, arc_empty;

  assign arc_din.id      = ARID;
  assign arc_din.addr    = ARADDR;
  assign arc_din.len     = ARLEN;
  assign arc_din.size    = ARSIZE;
  assign arc_din.burst   = ARBURST;
  assign arc_din.illegal = ~size_legal(ARSIZE, DATA_BYTES);

  assign ARREADY  = ~arc_full;
  assign arc_push = ARVALID & ARREADY;

  sync_fifo #(.WIDTH($bits(arcmd_t)), .DEPTH(AR_FIFO_DEPTH)) u_arfifo (
    .clk, .rstn, .push(arc_push), .din(arc_din),
    .pop(arc_pop), .dout(arc_dout), .full(arc_full), .empty(arc_empty),
    .count());

  // ============== R data FIFO (streaming, bounded) ==============
  typedef struct packed {
    logic [ID_W-1:0]   id;
    logic [DATA_W-1:0] data;
    logic [1:0]        resp;
    logic              last;
  } rdat_t;

  rdat_t rd_din, rd_dout;
  logic  rd_push, rd_pop, rd_full, rd_empty;
  logic [$clog2(R_FIFO_DEPTH):0] rd_count;

  sync_fifo #(.WIDTH($bits(rdat_t)), .DEPTH(R_FIFO_DEPTH)) u_rfifo (
    .clk, .rstn, .push(rd_push), .din(rd_din),
    .pop(rd_pop), .dout(rd_dout), .full(rd_full), .empty(rd_empty),
    .count(rd_count));

  assign RVALID = ~rd_empty;
  assign RID    = rd_dout.id;
  assign RDATA  = rd_dout.data;
  assign RRESP  = rd_dout.resp;
  assign RLAST  = rd_dout.last;
  assign rd_pop = RVALID & RREADY;

  // ============== Read issue FSM ==============
  typedef enum logic [1:0] { RS_IDLE, RS_ADDR, RS_DATA, RS_ILLEGAL } rs_e;
  rs_e rs;

  logic [ID_W-1:0]   cur_id;
  logic [ADDR_W-1:0] cur_addr;
  logic [7:0]        cur_len;
  logic [2:0]        cur_size;
  logic [1:0]        cur_burst;
  logic [8:0]        cur_beat, cur_nbeats;
  logic [2:0]        cur_hburst;
  logic              first_beat;

  // space guard: only proceed if R FIFO can accept one more beat
  wire fifo_has_space = (rd_count < R_FIFO_DEPTH[$clog2(R_FIFO_DEPTH):0]) && ~rd_full;

  assign rd_req    = (rs == RS_ADDR) && fifo_has_space;
  assign rd_haddr  = cur_addr;
  assign rd_hsize  = cur_size;
  assign rd_hburst = cur_hburst;
  assign rd_htrans = first_beat ? HTRANS_NONSEQ : HTRANS_SEQ;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      rs <= RS_IDLE;
      cur_id<='0; cur_addr<='0; cur_len<='0; cur_size<='0; cur_burst<='0;
      cur_beat<=9'd0; cur_nbeats<=9'd0; cur_hburst<=HBURST_SINGLE; first_beat<=1'b1;
      arc_pop<=1'b0; rd_push<=1'b0; rd_din<='0;
    end else begin
      arc_pop<=1'b0; rd_push<=1'b0;

      unique case (rs)
        // ---- pull next AR command ----
        RS_IDLE: begin
          if (!arc_empty) begin
            cur_id     <= arc_dout.id;
            cur_addr   <= arc_dout.addr;
            cur_len    <= arc_dout.len;
            cur_size   <= arc_dout.size;
            cur_burst  <= arc_dout.burst;
            cur_nbeats <= beats_of(arc_dout.len);
            cur_beat   <= 9'd0;
            cur_hburst <= map_hburst(arc_dout.burst, arc_dout.len);
            first_beat <= 1'b1;
            arc_pop    <= 1'b1;
            rs         <= arc_dout.illegal ? RS_ILLEGAL : RS_ADDR;
          end
        end

        // ---- AHB address phase ----
        RS_ADDR: begin
          if (fifo_has_space && rd_grant && ahb_hready) begin
            first_beat <= 1'b0;
            rs         <= RS_DATA;
          end
        end

        // ---- AHB data phase: push returned beat into R FIFO ----
        RS_DATA: begin
          if (ahb_hready) begin
            rd_din.id   <= cur_id;
            rd_din.data <= ahb_hrdata;
            rd_din.resp <= ahb_hresp ? AXI_RESP_SLVERR : AXI_RESP_OKAY;
            rd_din.last <= (cur_beat + 9'd1 >= cur_nbeats);
            rd_push     <= 1'b1;
            if (cur_beat + 9'd1 >= cur_nbeats) begin
              rs <= RS_IDLE;
            end else begin
              cur_addr <= axi_next_addr(cur_addr, cur_size, cur_len, cur_burst);
              cur_beat <= cur_beat + 9'd1;
              rs       <= RS_ADDR;
            end
          end
        end

        // ---- illegal AxSIZE: emit SLVERR beats, no AHB access ----
        RS_ILLEGAL: begin
          if (fifo_has_space) begin
            rd_din.id   <= cur_id;
            rd_din.data <= '0;
            rd_din.resp <= AXI_RESP_SLVERR;
            rd_din.last <= (cur_beat + 9'd1 >= cur_nbeats);
            rd_push     <= 1'b1;
            if (cur_beat + 9'd1 >= cur_nbeats) rs <= RS_IDLE;
            else cur_beat <= cur_beat + 9'd1;
          end
        end

        default: rs <= RS_IDLE;
      endcase
    end
  end
endmodule
`default_nettype wire
