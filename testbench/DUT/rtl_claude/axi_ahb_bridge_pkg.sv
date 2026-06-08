// ============================================================
//  axi_ahb_bridge_pkg.sv
//  Shared types, parameters, and utility functions
//  for the AXI-to-AHB bridge.
// ============================================================


package axi_ahb_bridge_pkg;

    // ----------------------------------------------------------------
    //  AXI burst type
    // ----------------------------------------------------------------
    typedef enum logic [1:0] {
        AXI_BURST_FIXED = 2'b00,
        AXI_BURST_INCR  = 2'b01,
        AXI_BURST_WRAP  = 2'b10
    } axi_burst_e;

    // ----------------------------------------------------------------
    //  AXI response
    // ----------------------------------------------------------------
    typedef enum logic [1:0] {
        AXI_RESP_OKAY   = 2'b00,
        AXI_RESP_EXOKAY = 2'b01,
        AXI_RESP_SLVERR = 2'b10,
        AXI_RESP_DECERR = 2'b11
    } axi_resp_e;

    // ----------------------------------------------------------------
    //  AHB HTRANS encoding
    // ----------------------------------------------------------------
    typedef enum logic [1:0] {
        AHB_HTRANS_IDLE   = 2'b00,
        AHB_HTRANS_BUSY   = 2'b01,
        AHB_HTRANS_NONSEQ = 2'b10,
        AHB_HTRANS_SEQ    = 2'b11
    } ahb_htrans_e;

    // ----------------------------------------------------------------
    //  AHB HBURST encoding
    // ----------------------------------------------------------------
    typedef enum logic [2:0] {
        AHB_HBURST_SINGLE = 3'b000,
        AHB_HBURST_INCR   = 3'b001,
        AHB_HBURST_WRAP4  = 3'b010,
        AHB_HBURST_INCR4  = 3'b011,
        AHB_HBURST_WRAP8  = 3'b100,
        AHB_HBURST_INCR8  = 3'b101,
        AHB_HBURST_WRAP16 = 3'b110,
        AHB_HBURST_INCR16 = 3'b111
    } ahb_hburst_e;

    // ----------------------------------------------------------------
    //  AHB HRESP encoding
    // ----------------------------------------------------------------
    typedef enum logic {
        AHB_HRESP_OKAY  = 1'b0,
        AHB_HRESP_ERROR = 1'b1
    } ahb_hresp_e;

    // ----------------------------------------------------------------
    //  AHB HSIZE encoding
    // ----------------------------------------------------------------
    typedef enum logic [2:0] {
        AHB_HSIZE_8    = 3'b000,
        AHB_HSIZE_16   = 3'b001,
        AHB_HSIZE_32   = 3'b010,
        AHB_HSIZE_64   = 3'b011,
        AHB_HSIZE_128  = 3'b100,
        AHB_HSIZE_256  = 3'b101,
        AHB_HSIZE_512  = 3'b110,
        AHB_HSIZE_1024 = 3'b111
    } ahb_hsize_e;

    // ----------------------------------------------------------------
    //  Write transaction descriptor
    //  Used to carry context through bridge controller
    // ----------------------------------------------------------------
    typedef struct packed {
        logic [3:0]  id;
        logic [31:0] addr;
        logic [7:0]  len;
        logic [2:0]  size;
        logic [1:0]  burst;
        logic [2:0]  prot;
    } wr_txn_t;

    // ----------------------------------------------------------------
    //  Read transaction descriptor
    // ----------------------------------------------------------------
    typedef struct packed {
        logic [3:0]  id;
        logic [31:0] addr;
        logic [7:0]  len;
        logic [2:0]  size;
        logic [1:0]  burst;
        logic [2:0]  prot;
    } rd_txn_t;

    // ----------------------------------------------------------------
    //  AXI->AHB burst mapping function
    //  Returns AHB HBURST encoding from AXI burst type + len
    // ----------------------------------------------------------------
    function automatic logic [2:0] axi_burst_to_ahb (
        input logic [7:0] len,
        input logic [1:0] burst
    );
        if (burst == AXI_BURST_FIXED)
            return AHB_HBURST_SINGLE;
        else if (burst == AXI_BURST_WRAP) begin
            case (len)
                8'd3:    return AHB_HBURST_WRAP4;
                8'd7:    return AHB_HBURST_WRAP8;
                8'd15:   return AHB_HBURST_WRAP16;
                default: return AHB_HBURST_INCR;   // undefined WRAP -> INCR
            endcase
        end else begin  // INCR
            case (len)
                8'd0:    return AHB_HBURST_SINGLE;
                8'd3:    return AHB_HBURST_INCR4;
                8'd7:    return AHB_HBURST_INCR8;
                8'd15:   return AHB_HBURST_INCR16;
                default: return AHB_HBURST_INCR;   // undefined length -> INCR
            endcase
        end
    endfunction

    // ----------------------------------------------------------------
    //  AHB HRESP -> AXI resp mapping
    // ----------------------------------------------------------------
    function automatic logic [1:0] ahb_resp_to_axi (
        input logic hresp
    );
        return hresp ? AXI_RESP_SLVERR : AXI_RESP_OKAY;
    endfunction

    // ----------------------------------------------------------------
    //  Next address calculator (INCR / WRAP / FIXED)
    // ----------------------------------------------------------------
    function automatic logic [31:0] calc_next_addr (
        input logic [31:0] addr,
        input logic [2:0]  size,
        input logic [1:0]  burst,
        input logic [7:0]  len
    );
        logic [31:0] incr_bytes;
        logic [31:0] wrap_boundary;
        logic [31:0] wrap_mask;

        incr_bytes = (32'd1 << size);

        case (burst)
            AXI_BURST_FIXED: begin
                calc_next_addr = addr;
            end
            AXI_BURST_INCR: begin
                calc_next_addr = addr + incr_bytes;
            end
            AXI_BURST_WRAP: begin
                // wrap_mask covers the entire burst range
                wrap_mask      = ((len + 1) * incr_bytes) - 32'd1;
                wrap_boundary  = addr & ~wrap_mask;
                calc_next_addr = wrap_boundary | ((addr + incr_bytes) & wrap_mask);
            end
            default: begin
                calc_next_addr = addr + incr_bytes;
            end
        endcase
    endfunction

    // ----------------------------------------------------------------
    //  Gray code encode / decode
    //  Used by async_fifo for pointer synchronisation
    // ----------------------------------------------------------------
    function automatic logic [31:0] bin_to_gray (input logic [31:0] bin);
        return bin ^ (bin >> 1);
    endfunction

    function automatic logic [31:0] gray_to_bin (input logic [31:0] gray);
        logic [31:0] b;
        b[31] = gray[31];
        for (int i = 30; i >= 0; i--)
            b[i] = b[i+1] ^ gray[i];
        return b;
    endfunction

endpackage
