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
  //   FIXED : AHB-Lite has no fixed-burst concept. Each beat re-accesses the
  //           same address and is issued as an independent SINGLE transfer
  //           (and HTRANS must be NONSEQ on every beat, see engines).
  //   WRAP  : WRAP4/8/16 for matching counts. WRAP2 has no AHB equivalent ->
  //           split into 2 single transfers (HBURST=SINGLE, each NONSEQ).
  //           Other wrap lengths fall back to INCR.
  //   INCR  : SINGLE for len0; INCR4/8/16 for matching counts; INCR otherwise.
  function automatic logic [2:0] map_hburst(
      input logic [1:0] axburst, input logic [7:0] axlen);
    logic [8:0] nb;
    nb = beats_of(axlen);
    if (axburst == AXI_BURST_FIXED) begin
      // every beat is a standalone single transfer to the same address
      map_hburst = HBURST_SINGLE;
    end else if (axburst == AXI_BURST_WRAP) begin
      unique case (nb)
        9'd2 : map_hburst = HBURST_SINGLE; // WRAP2 -> two AHB singles
        9'd4 : map_hburst = HBURST_WRAP4;
        9'd8 : map_hburst = HBURST_WRAP8;
        9'd16: map_hburst = HBURST_WRAP16;
        default: map_hburst = HBURST_INCR; // unusual wrap len -> treat as incr
      endcase
    end else begin // INCR
      unique case (nb)
        9'd1 : map_hburst = HBURST_SINGLE;
        9'd4 : map_hburst = HBURST_INCR4;
        9'd8 : map_hburst = HBURST_INCR8;
        9'd16: map_hburst = HBURST_INCR16;
        default: map_hburst = HBURST_INCR; // undefined-length incrementing
      endcase
    end
  endfunction

  // A burst must be issued as per-beat NONSEQ singles (no SEQ) when the AHB
  // HBURST is SINGLE but the AXI burst still spans multiple beats. This is true
  // for FIXED (any length) and WRAP2.
  function automatic logic force_single_beats(
      input logic [1:0] axburst, input logic [7:0] axlen);
    force_single_beats = (axburst == AXI_BURST_FIXED) ||
                         ((axburst == AXI_BURST_WRAP) && (beats_of(axlen) == 9'd2));
  endfunction

  // Detect whether stepping from `addr` to the next INCR beat crosses a 1 KB
  // (1024-byte) boundary. Per PG177, an INCR burst that would cross 1 KB must
  // be split into two undefined-length INCR bursts on AHB-Lite, i.e. the beat
  // that lands in the new 1 KB region must restart with HTRANS=NONSEQ.
  function automatic logic crosses_1kb(
      input logic [31:0] cur_addr,
      input logic [31:0] nxt_addr);
    crosses_1kb = (cur_addr[31:10] != nxt_addr[31:10]);
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

  // Map AXI AxPROT[2:0] + AxCACHE[3:0] to AHB-Lite HPROT[3:0] per PG177 Table 3-1.
  //   HPROT[0] = data(1)/opcode(0)     <- AxPROT[2] (instruction) inverted
  //   HPROT[1] = privileged(1)/user(0) <- AxPROT[0]
  //   HPROT[2] = bufferable            <- AxCACHE[0]
  //   HPROT[3] = cacheable             <- always 0 (no cacheable on AHB-Lite)
  function automatic logic [3:0] map_hprot(
      input logic [2:0] axprot, input logic [3:0] axcache);
    logic data_n_opcode, privileged, bufferable;
    begin
      data_n_opcode = ~axprot[2];   // AxPROT[2]=1 means instruction
      privileged    =  axprot[0];   // AxPROT[0]=1 means privileged
      bufferable    =  axcache[0];  // AxCACHE[0]=bufferable
      map_hprot = {1'b0, bufferable, privileged, data_n_opcode};
    end
  endfunction

  // Legality check: AxSIZE must not exceed bus byte width.
  // data_bytes is e.g. 4 for 32-bit; max legal size = $clog2(data_bytes).
  function automatic logic size_legal(
      input logic [2:0] size, input int data_bytes);
    size_legal = ({29'd0, size} <= $clog2(data_bytes));
  endfunction

endpackage
