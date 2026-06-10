//============================================================================
// sync_fifo.sv -- simple parameterized synchronous FIFO (first-word-fallthrough
// style read: dout always shows head; pop advances). Depth must be power-of-2.
//============================================================================
`default_nettype none
module sync_fifo #(
  parameter int WIDTH = 32,
  parameter int DEPTH = 8          // must be power of 2
)(
  input  wire              clk,
  input  wire              rstn,
  input  wire              push,
  input  wire [WIDTH-1:0]  din,
  input  wire              pop,
  output wire [WIDTH-1:0]  dout,
  output wire              full,
  output wire              empty,
  output wire [$clog2(DEPTH):0] count
);
  localparam int AW = $clog2(DEPTH);
  logic [WIDTH-1:0] mem [DEPTH];
  logic [AW:0]      wptr, rptr;

  assign full  = (wptr[AW] != rptr[AW]) && (wptr[AW-1:0] == rptr[AW-1:0]);
  assign empty = (wptr == rptr);
  assign dout  = mem[rptr[AW-1:0]];
  assign count = wptr - rptr;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      wptr <= '0; rptr <= '0;
      // Clear storage so dout is a defined value (0) before the first push,
      // keeping waveforms free of X without affecting function.
      for (int i = 0; i < DEPTH; i++) mem[i] <= '0;
    end else begin
      if (push && !full)  begin mem[wptr[AW-1:0]] <= din; wptr <= wptr + 1'b1; end
      if (pop  && !empty) rptr <= rptr + 1'b1;
    end
  end
endmodule
`default_nettype wire
