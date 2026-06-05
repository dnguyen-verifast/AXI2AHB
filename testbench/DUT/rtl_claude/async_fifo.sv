// ============================================================
//  async_fifo.sv
//  Asynchronous FIFO for Clock Domain Crossing (CDC)
//
//  Design rules:
//    - Write pointer runs in wclk domain
//    - Read  pointer runs in rclk domain
//    - Both pointers are Gray-coded before crossing
//    - 2-FF synchronisers on both pointer paths
//    - DEPTH must be a power of 2 (enforced by parameter check)
//    - FULL  is evaluated in wclk domain
//    - EMPTY is evaluated in rclk domain
//    - No simultaneous read+write to same location (guaranteed by
//      full/empty flags)
// ============================================================

`timescale 1ns/1ps

module async_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 8   // must be power-of-2
)(
    // Write port (producer side)
    input  logic              wclk,
    input  logic              wrstn,
    input  logic              wen,
    input  logic [WIDTH-1:0]  wdata,
    output logic              full,

    // Read port (consumer side)
    input  logic              rclk,
    input  logic              rrstn,
    input  logic              ren,
    output logic [WIDTH-1:0]  rdata,
    output logic              empty
);

    // ----------------------------------------------------------------
    //  Local parameters
    // ----------------------------------------------------------------
    localparam int ADDR_W = $clog2(DEPTH);  // e.g. DEPTH=8 -> ADDR_W=3

    // ----------------------------------------------------------------
    //  Storage array (dual-port inferred RAM)
    // ----------------------------------------------------------------
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // ----------------------------------------------------------------
    //  Binary pointers  (one extra bit for wrap-around full/empty detect)
    // ----------------------------------------------------------------
    logic [ADDR_W:0] wptr_bin, wptr_bin_next;   // write domain
    logic [ADDR_W:0] rptr_bin, rptr_bin_next;   // read  domain

    // Gray-coded pointers
    logic [ADDR_W:0] wptr_gray;
    logic [ADDR_W:0] rptr_gray;

    // Synchronised pointers (2-FF)
    logic [ADDR_W:0] wptr_gray_s1, wptr_gray_s2;   // rclk domain
    logic [ADDR_W:0] rptr_gray_s1, rptr_gray_s2;   // wclk domain

    // ----------------------------------------------------------------
    //  Gray encode
    // ----------------------------------------------------------------
    assign wptr_gray = wptr_bin ^ (wptr_bin >> 1);
    assign rptr_gray = rptr_bin ^ (rptr_bin >> 1);

    // ----------------------------------------------------------------
    //  2-FF synchronisers
    //    wptr_gray  -> sync into rclk domain -> wptr_gray_s2
    //    rptr_gray  -> sync into wclk domain -> rptr_gray_s2
    // ----------------------------------------------------------------
    always_ff @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            wptr_gray_s1 <= '0;
            wptr_gray_s2 <= '0;
        end else begin
            wptr_gray_s1 <= wptr_gray;
            wptr_gray_s2 <= wptr_gray_s1;
        end
    end

    always_ff @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            rptr_gray_s1 <= '0;
            rptr_gray_s2 <= '0;
        end else begin
            rptr_gray_s1 <= rptr_gray;
            rptr_gray_s2 <= rptr_gray_s1;
        end
    end

    // ----------------------------------------------------------------
    //  Gray decode (synced pointers back to binary)
    // ----------------------------------------------------------------
    function automatic logic [ADDR_W:0] gray_to_bin_local (
        input logic [ADDR_W:0] gray
    );
        logic [ADDR_W:0] b;
        b[ADDR_W] = gray[ADDR_W];
        for (int i = ADDR_W-1; i >= 0; i--)
            b[i] = b[i+1] ^ gray[i];
        return b;
    endfunction

    logic [ADDR_W:0] wptr_bin_sync;  // wptr synced into rclk (binary)
    logic [ADDR_W:0] rptr_bin_sync;  // rptr synced into wclk (binary)

    assign wptr_bin_sync = gray_to_bin_local(wptr_gray_s2);
    assign rptr_bin_sync = gray_to_bin_local(rptr_gray_s2);

    // ----------------------------------------------------------------
    //  FULL flag (wclk domain)
    //    Full when write pointer has lapped read pointer:
    //    MSB of wptr_bin != MSB of synced rptr, lower bits equal
    // ----------------------------------------------------------------
    assign full = (wptr_gray == {~rptr_gray_s2[ADDR_W:ADDR_W-1],
                                  rptr_gray_s2[ADDR_W-2:0]});

    // ----------------------------------------------------------------
    //  EMPTY flag (rclk domain)
    //    Empty when both gray pointers are equal
    // ----------------------------------------------------------------
    assign empty = (rptr_gray == wptr_gray_s2);

    // ----------------------------------------------------------------
    //  Write logic (wclk domain)
    // ----------------------------------------------------------------
    always_ff @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            wptr_bin <= '0;
        end else begin
            if (wen && !full) begin
                mem[wptr_bin[ADDR_W-1:0]] <= wdata;
                wptr_bin <= wptr_bin + 1'b1;
            end
        end
    end

    // ----------------------------------------------------------------
    //  Read logic (rclk domain)
    // ----------------------------------------------------------------
    always_ff @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            rptr_bin <= '0;
        end else begin
            if (ren && !empty) begin
                rptr_bin <= rptr_bin + 1'b1;
            end
        end
    end

    // Combinational read output (registered read can also be used,
    // but combinational minimises latency for bridge throughput)
    assign rdata = mem[rptr_bin[ADDR_W-1:0]];

    // ----------------------------------------------------------------
    //  Parameter sanity check (elaboration-time)
    // ----------------------------------------------------------------
    initial begin
        if ((DEPTH & (DEPTH - 1)) != 0) begin
            $fatal(1, "[async_fifo] DEPTH=%0d is not a power of 2!", DEPTH);
        end
        if (DEPTH < 4) begin
            $fatal(1, "[async_fifo] DEPTH=%0d must be >= 4!", DEPTH);
        end
    end

endmodule
