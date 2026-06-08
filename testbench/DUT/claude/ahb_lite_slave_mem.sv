//============================================================================
// ahb_lite_slave_mem.sv -- AHB-Lite slave memory model (sim)
//   - Honors HSIZE + HADDR byte offset for sub-word writes (so WSTRB-driven
//     sub-word writes from the bridge land in the correct byte lanes).
//   - Zero wait state, always OKAY.
//============================================================================
`default_nettype none
module ahb_lite_slave_mem #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int MEM_WORDS  = 4096
)(
  input  wire                   HCLK,
  input  wire                   HRESETn,
  input  wire [ADDR_WIDTH-1:0]  HADDR,
  input  wire [2:0]             HBURST,
  input  wire                   HMASTLOCK,
  input  wire [3:0]             HPROT,
  input  wire [2:0]             HSIZE,
  input  wire [1:0]             HTRANS,
  input  wire [DATA_WIDTH-1:0]  HWDATA,
  input  wire                   HWRITE,
  output reg  [DATA_WIDTH-1:0]  HRDATA,
  output wire                   HREADY,
  output wire                   HRESP
);
  localparam logic [1:0] HTRANS_NONSEQ=2'b10, HTRANS_SEQ=2'b11;
  localparam int BYTES = DATA_WIDTH/8;

  logic [DATA_WIDTH-1:0] memw [MEM_WORDS];   // word-addressed storage

  // address-phase capture
  logic                  ap_valid, ap_write;
  logic [ADDR_WIDTH-1:0] ap_addr;
  logic [2:0]            ap_size;

  assign HREADY = 1'b1;
  assign HRESP  = 1'b0;

  wire trans_active = (HTRANS==HTRANS_NONSEQ)||(HTRANS==HTRANS_SEQ);

  function automatic [DATA_WIDTH-1:0] merge_bytes(
      input [DATA_WIDTH-1:0] old_w,
      input [DATA_WIDTH-1:0] new_w,
      input [ADDR_WIDTH-1:0] addr,
      input [2:0]            size);
    int nbytes, boff;
    logic [DATA_WIDTH-1:0] r;
    begin
      nbytes = (1 << size);
      boff   = addr[$clog2(BYTES)-1:0];
      r = old_w;
      for(int b=0;b<BYTES;b++)
        if(b>=boff && b<boff+nbytes)
          r[b*8 +: 8] = new_w[b*8 +: 8];
      merge_bytes = r;
    end
  endfunction

  always_ff @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn) begin
      ap_valid<=0; ap_write<=0; ap_addr<='0; ap_size<=0; HRDATA<='0;
    end else begin
      // data phase of previously captured access
      if(ap_valid && ap_write)
        memw[ap_addr[ADDR_WIDTH-1:2]] <=
          merge_bytes(memw[ap_addr[ADDR_WIDTH-1:2]], HWDATA, ap_addr, ap_size);
      // capture new address phase
      ap_valid <= trans_active;
      ap_write <= HWRITE;
      ap_addr  <= HADDR;
      ap_size  <= HSIZE;
      // read data (word) available in data phase
      if(trans_active && !HWRITE)
        HRDATA <= memw[HADDR[ADDR_WIDTH-1:2]];
    end
  end
endmodule
`default_nettype wire
