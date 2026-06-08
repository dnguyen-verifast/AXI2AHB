//============================================================================
// axi_ahb_pkg.sv
//   Shared constants, helper functions for the AXI4 -> AHB-Lite bridge.
//============================================================================
package axi_ahb_pkg;

  // ---- AXI burst types ----
  localparam logic [1:0] AXI_BURST_FIXED = 2'b00;
  localparam logic [1:0] AXI_BURST_INCR  = 2'b01;
  localparam logic [1:0] AXI_BURST_WRAP  = 2'b10;

  // ---- AXI response codes ----
  localparam logic [1:0] AXI_RESP_OKAY   = 2'b00;
  localparam logic [1:0] AXI_RESP_EXOKAY = 2'b01;
  localparam logic [1:0] AXI_RESP_SLVERR = 2'b10;
  localparam logic [1:0] AXI_RESP_DECERR = 2'b11;

  // ---- AHB HTRANS ----
  localparam logic [1:0] HTRANS_IDLE   = 2'b00;
  localparam logic [1:0] HTRANS_BUSY   = 2'b01;
  localparam logic [1:0] HTRANS_NONSEQ = 2'b10;
  localparam logic [1:0] HTRANS_SEQ    = 2'b11;

  // ---- AHB HBURST ----
  localparam logic [2:0] HBURST_SINGLE = 3'b000;
  localparam logic [2:0] HBURST_INCR   = 3'b001;
  localparam logic [2:0] HBURST_WRAP4  = 3'b010;
  localparam logic [2:0] HBURST_INCR4  = 3'b011;
  localparam logic [2:0] HBURST_WRAP8  = 3'b100;
  localparam logic [2:0] HBURST_INCR8  = 3'b101;
  localparam logic [2:0] HBURST_WRAP16 = 3'b110;
  localparam logic [2:0] HBURST_INCR16 = 3'b111;

  // Number of beats from AxLEN (len+1)
  function automatic logic [8:0] beats_of(input logic [7:0] len);
    beats_of = {1'b0, len} + 9'd1;
  endfunction

  // Map AXI burst (type, len) -> AHB HBURST.
  // Returns SINGLE for len0; INCR4/8/16 or WRAP4/8/16 for matching power-of-two
  // counts; INCR (undefined length) otherwise.
  function automatic logic [2:0] map_hburst(
      input logic [1:0] axburst, input logic [7:0] axlen);
    logic [8:0] nb;
    nb = beats_of(axlen);
    if (axburst == AXI_BURST_WRAP) begin
      unique case (nb)
        9'd4 : map_hburst = HBURST_WRAP4;
        9'd8 : map_hburst = HBURST_WRAP8;
        9'd16: map_hburst = HBURST_WRAP16;
        default: map_hburst = HBURST_INCR; // unusual wrap len -> treat as incr
      endcase
    end else begin // INCR or FIXED
      unique case (nb)
        9'd1 : map_hburst = HBURST_SINGLE;
        9'd4 : map_hburst = HBURST_INCR4;
        9'd8 : map_hburst = HBURST_INCR8;
        9'd16: map_hburst = HBURST_INCR16;
        default: map_hburst = HBURST_INCR; // undefined-length incrementing
      endcase
    end
  endfunction

  // Compute next beat address for AXI burst.
  function automatic logic [31:0] axi_next_addr(
      input logic [31:0] addr,
      input logic [2:0]  size,
      input logic [7:0]  len,
      input logic [1:0]  burst);
    logic [31:0] step, aligned, wrap_bytes, lower, upper, nxt;
    begin
      step    = (32'd1 << size);
      aligned = (addr >> size) << size;
      unique case (burst)
        AXI_BURST_FIXED: nxt = addr;
        AXI_BURST_WRAP : begin
          wrap_bytes = step * ({{24{1'b0}}, len} + 32'd1);
          lower      = (addr / wrap_bytes) * wrap_bytes;
          upper      = lower + wrap_bytes;
          nxt        = aligned + step;
          if (nxt >= upper) nxt = lower;
        end
        default        : nxt = aligned + step; // INCR
      endcase
      axi_next_addr = nxt;
    end
  endfunction

  // Legality check: AxSIZE must not exceed bus byte width.
  // data_bytes is e.g. 4 for 32-bit; max legal size = $clog2(data_bytes).
  function automatic logic size_legal(
      input logic [2:0] size, input int data_bytes);
    size_legal = ({29'd0, size} <= $clog2(data_bytes));
  endfunction

endpackage
