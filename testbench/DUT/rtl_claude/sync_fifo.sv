// ============================================================
//  sync_fifo.sv
//  Synchronous FIFO — single clock domain
//  Used when CDC_ENABLE=0 (axi_clk == ahb_clk)
//
//  Features:
//    - Fall-through / show-ahead (rdata valid while !empty)
//    - DEPTH must be a power of 2
//    - Simultaneous read+write supported (no bubble)
// ============================================================

`timescale 1ns/1ps

module sync_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 8   // must be power-of-2
)(
    input  logic              clk,
    input  logic              rstn,

    // Write port
    input  logic              wen,
    input  logic [WIDTH-1:0]  wdata,
    output logic              full,

    // Read port
    input  logic              ren,
    output logic [WIDTH-1:0]  rdata,
    output logic              empty
);

    // ----------------------------------------------------------------
    //  Local parameters
    // ----------------------------------------------------------------
    localparam int ADDR_W = $clog2(DEPTH);

    // ----------------------------------------------------------------
    //  Storage
    // ----------------------------------------------------------------
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // ----------------------------------------------------------------
    //  Pointers (one extra bit for full/empty distinguish)
    // ----------------------------------------------------------------
    logic [ADDR_W:0] wptr;
    logic [ADDR_W:0] rptr;

    // ----------------------------------------------------------------
    //  Occupancy counter (for convenience / assertions)
    // ----------------------------------------------------------------
    logic [ADDR_W:0] count;
    assign count = wptr - rptr;

    // ----------------------------------------------------------------
    //  Flags
    // ----------------------------------------------------------------
    assign full  = (count == DEPTH[ADDR_W:0]);
    assign empty = (count == '0);

    // ----------------------------------------------------------------
    //  Write path
    // ----------------------------------------------------------------
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            wptr <= '0;
        end else begin
            if (wen && !full) begin
                mem[wptr[ADDR_W-1:0]] <= wdata;
                wptr <= wptr + 1'b1;
            end
        end
    end

    // ----------------------------------------------------------------
    //  Read path
    // ----------------------------------------------------------------
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rptr <= '0;
        end else begin
            if (ren && !empty) begin
                rptr <= rptr + 1'b1;
            end
        end
    end

    // Combinational show-ahead read
    assign rdata = mem[rptr[ADDR_W-1:0]];

    // ----------------------------------------------------------------
    //  Simultaneous read+write when full: treat as bypass
    //  (write accepted, old entry read, count stays same)
    // ----------------------------------------------------------------

    // ----------------------------------------------------------------
    //  Assertions (simulation only)
    // ----------------------------------------------------------------
    // synthesis translate_off
    always_ff @(posedge clk) begin
        if (rstn) begin
            if (wen && full)
                $warning("[sync_fifo] Write while FULL — data lost! (WIDTH=%0d DEPTH=%0d)", WIDTH, DEPTH);
            if (ren && empty)
                $warning("[sync_fifo] Read while EMPTY — invalid data! (WIDTH=%0d DEPTH=%0d)", WIDTH, DEPTH);
        end
    end
    // synthesis translate_on

    // ----------------------------------------------------------------
    //  Parameter sanity check
    // ----------------------------------------------------------------
    initial begin
        if ((DEPTH & (DEPTH - 1)) != 0)
            $fatal(1, "[sync_fifo] DEPTH=%0d is not a power of 2!", DEPTH);
        if (DEPTH < 2)
            $fatal(1, "[sync_fifo] DEPTH=%0d must be >= 2!", DEPTH);
    end

endmodule
