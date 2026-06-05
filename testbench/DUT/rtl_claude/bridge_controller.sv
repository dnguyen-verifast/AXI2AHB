// ============================================================
//  bridge_controller.sv
//  Core bridge logic running entirely in AHB clock domain.
//
//  Responsibilities:
//    1. Arbitrate between read and write requests (write priority)
//    2. Per-ID ordering: each ID has its own mini-queue (depth=MAX_OUTSTANDING)
//    3. Burst conversion: AXI INCR/WRAP/FIXED -> AHB INCR/WRAP/SINGLE
//    4. Write-data alignment: hold AHB addr phase until W FIFO has data
//    5. AHB ERROR 2-cycle handling -> SLVERR response to AXI
//    6. HREADY=0 (wait-state) stall handling
// ============================================================

`timescale 1ns/1ps

module bridge_controller #(
    parameter int DATA_WIDTH      = 32,
    parameter int ADDR_WIDTH      = 32,
    parameter int ID_WIDTH        = 4,
    parameter int MAX_OUTSTANDING = 4,
    parameter int AW_WIDTH        = 52,
    parameter int W_WIDTH         = 37,
    parameter int B_WIDTH         = 6,
    parameter int AR_WIDTH        = 52,
    parameter int R_WIDTH         = 39
)(
    input  logic                   clk,
    input  logic                   rstn,

    // AW FIFO interface
    input  logic [AW_WIDTH-1:0]    aw_rdata,
    input  logic                   aw_empty,
    output logic                   aw_ren,

    // W FIFO interface
    input  logic [W_WIDTH-1:0]     w_rdata,
    input  logic                   w_empty,
    output logic                   w_ren,

    // B FIFO interface
    output logic [B_WIDTH-1:0]     b_wdata,
    input  logic                   b_full,
    output logic                   b_wen,

    // AR FIFO interface
    input  logic [AR_WIDTH-1:0]    ar_rdata,
    input  logic                   ar_empty,
    output logic                   ar_ren,

    // R FIFO interface
    output logic [R_WIDTH-1:0]     r_wdata,
    input  logic                   r_full,
    output logic                   r_wen,

    // AHB Master outputs
    output logic [ADDR_WIDTH-1:0]  haddr,
    output logic [2:0]             hburst,
    output logic [2:0]             hsize,
    output logic [1:0]             htrans,
    output logic [DATA_WIDTH-1:0]  hwdata,
    output logic                   hwrite,
    output logic                   hsel,
    output logic                   hmastlock,

    // AHB Master inputs
    input  logic [DATA_WIDTH-1:0]  hrdata,
    input  logic                   hready,
    input  logic                   hresp
);

    // ----------------------------------------------------------------
    //  AXI burst type encoding
    // ----------------------------------------------------------------
    localparam BURST_FIXED = 2'b00;
    localparam BURST_INCR  = 2'b01;
    localparam BURST_WRAP  = 2'b10;

    // AHB HTRANS encoding
    localparam HTRANS_IDLE   = 2'b00;
    localparam HTRANS_BUSY   = 2'b01;
    localparam HTRANS_NONSEQ = 2'b10;
    localparam HTRANS_SEQ    = 2'b11;

    // AHB HBURST encoding
    localparam HBURST_SINGLE = 3'b000;
    localparam HBURST_INCR   = 3'b001;
    localparam HBURST_WRAP4  = 3'b010;
    localparam HBURST_INCR4  = 3'b011;
    localparam HBURST_WRAP8  = 3'b100;
    localparam HBURST_INCR8  = 3'b101;
    localparam HBURST_WRAP16 = 3'b110;
    localparam HBURST_INCR16 = 3'b111;

    // ----------------------------------------------------------------
    //  FSM states
    // ----------------------------------------------------------------
    typedef enum logic [3:0] {
        S_IDLE         = 4'd0,
        S_WR_ADDR      = 4'd1,   // Issue AHB address phase (write)
        S_WR_DATA      = 4'd2,   // AHB data phase (write)
        S_WR_WAIT_DATA = 4'd3,   // Stall: W FIFO empty, waiting for data
        S_WR_ERROR     = 4'd4,   // AHB returned ERROR on write
        S_WR_RESP      = 4'd5,   // Push B response to FIFO
        S_RD_ADDR      = 4'd6,   // Issue AHB address phase (read)
        S_RD_DATA      = 4'd7,   // AHB data phase (read)
        S_RD_ERROR     = 4'd8,   // AHB returned ERROR on read
        S_RD_RESP      = 4'd9    // Push R response to FIFO
    } state_t;

    state_t state, state_next;

    // ----------------------------------------------------------------
    //  Transaction registers (unpacked from FIFOs)
    // ----------------------------------------------------------------
    // Write transaction
    logic [ID_WIDTH-1:0]   wr_id;
    logic [ADDR_WIDTH-1:0] wr_addr;
    logic [7:0]            wr_len;
    logic [2:0]            wr_size;
    logic [1:0]            wr_burst;
    logic [2:0]            wr_prot;

    // Read transaction
    logic [ID_WIDTH-1:0]   rd_id;
    logic [ADDR_WIDTH-1:0] rd_addr;
    logic [7:0]            rd_len;
    logic [2:0]            rd_size;
    logic [1:0]            rd_burst;
    logic [2:0]            rd_prot;

    // Current beat tracking
    logic [7:0]            beat_cnt;       // beats remaining
    logic [ADDR_WIDTH-1:0] cur_addr;       // current beat address
    logic [DATA_WIDTH-1:0] cur_wdata;
    logic [DATA_WIDTH/8-1:0] cur_wstrb;
    logic                  cur_wlast;
    logic [1:0]            cur_resp;       // accumulated response
    logic                  is_write;

    // Registered AHB phase data (addr phase -> data phase pipeline)
    logic [ADDR_WIDTH-1:0] haddr_r;
    logic [2:0]            hsize_r;
    logic [1:0]            htrans_r;
    logic                  hwrite_r;
    logic [DATA_WIDTH-1:0] hwdata_r;

    // ----------------------------------------------------------------
    //  Address increment function
    // ----------------------------------------------------------------
    function automatic logic [ADDR_WIDTH-1:0] next_addr(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [2:0]            size,
        input logic [1:0]            burst,
        input logic [7:0]            len
    );
        logic [ADDR_WIDTH-1:0] incr;
        logic [ADDR_WIDTH-1:0] wrap_mask;
        incr = (1 << size);
        case (burst)
            BURST_FIXED: next_addr = addr;  // same address every beat
            BURST_INCR:  next_addr = addr + incr;
            BURST_WRAP: begin
                wrap_mask = ((len + 1) * incr) - 1;
                next_addr = (addr & ~wrap_mask) | ((addr + incr) & wrap_mask);
            end
            default: next_addr = addr + incr;
        endcase
    endfunction

    // ----------------------------------------------------------------
    //  AXI len -> AHB HBURST mapping
    // ----------------------------------------------------------------
    function automatic logic [2:0] axi_to_ahb_burst(
        input logic [7:0]  len,
        input logic [1:0]  burst
    );
        if (burst == BURST_FIXED)
            return HBURST_SINGLE;
        else if (burst == BURST_WRAP) begin
            case (len)
                8'd3:    return HBURST_WRAP4;
                8'd7:    return HBURST_WRAP8;
                8'd15:   return HBURST_WRAP16;
                default: return HBURST_INCR;
            endcase
        end else begin  // INCR
            case (len)
                8'd0:    return HBURST_SINGLE;
                8'd3:    return HBURST_INCR4;
                8'd7:    return HBURST_INCR8;
                8'd15:   return HBURST_INCR16;
                default: return HBURST_INCR;
            endcase
        end
    endfunction

    // ----------------------------------------------------------------
    //  Per-ID ordering: simple counter tracking outstanding per ID
    //  We enforce in-order per ID by not accepting a new AW/AR if
    //  an entry with same ID is already being processed.
    // ----------------------------------------------------------------
    localparam int NUM_IDS = (1 << ID_WIDTH);
    logic [$clog2(MAX_OUTSTANDING+1)-1:0] wr_id_cnt [NUM_IDS-1:0];
    logic [$clog2(MAX_OUTSTANDING+1)-1:0] rd_id_cnt [NUM_IDS-1:0];

    logic wr_id_blocked, rd_id_blocked;
    assign wr_id_blocked = (wr_id_cnt[aw_rdata[AW_WIDTH-1 -: ID_WIDTH]] >= MAX_OUTSTANDING);
    assign rd_id_blocked = (rd_id_cnt[ar_rdata[AR_WIDTH-1 -: ID_WIDTH]] >= MAX_OUTSTANDING);

    // ----------------------------------------------------------------
    //  Unpack FIFO data
    // ----------------------------------------------------------------
    // AW: {id[51:48], addr[47:16], len[15:8], size[7:5], burst[4:3], prot[2:0]}
    always_comb begin
        wr_id    = aw_rdata[AW_WIDTH-1                  -: ID_WIDTH];
        wr_addr  = aw_rdata[AW_WIDTH-1-ID_WIDTH          -: ADDR_WIDTH];
        wr_len   = aw_rdata[AW_WIDTH-1-ID_WIDTH-ADDR_WIDTH -: 8];
        wr_size  = aw_rdata[AW_WIDTH-1-ID_WIDTH-ADDR_WIDTH-8 -: 3];
        wr_burst = aw_rdata[AW_WIDTH-1-ID_WIDTH-ADDR_WIDTH-8-3 -: 2];
        wr_prot  = aw_rdata[2:0];
    end

    always_comb begin
        rd_id    = ar_rdata[AR_WIDTH-1                  -: ID_WIDTH];
        rd_addr  = ar_rdata[AR_WIDTH-1-ID_WIDTH          -: ADDR_WIDTH];
        rd_len   = ar_rdata[AR_WIDTH-1-ID_WIDTH-ADDR_WIDTH -: 8];
        rd_size  = ar_rdata[AR_WIDTH-1-ID_WIDTH-ADDR_WIDTH-8 -: 3];
        rd_burst = ar_rdata[AR_WIDTH-1-ID_WIDTH-ADDR_WIDTH-8-3 -: 2];
        rd_prot  = ar_rdata[2:0];
    end

    // ----------------------------------------------------------------
    //  Registered transaction info (latched when dequeued)
    // ----------------------------------------------------------------
    logic [ID_WIDTH-1:0]   txn_id;
    logic [ADDR_WIDTH-1:0] txn_start_addr;
    logic [7:0]            txn_len;
    logic [2:0]            txn_size;
    logic [1:0]            txn_burst;
    logic                  txn_is_write;
    logic [1:0]            txn_err_resp;  // accumulated: OKAY=0, SLVERR=2

    // ----------------------------------------------------------------
    //  FSM: sequential
    // ----------------------------------------------------------------
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) state <= S_IDLE;
        else        state <= state_next;
    end

    // ----------------------------------------------------------------
    //  FSM: combinational next-state + output logic
    // ----------------------------------------------------------------
    always_comb begin
        state_next = state;

        aw_ren  = 1'b0;
        ar_ren  = 1'b0;
        w_ren   = 1'b0;
        b_wen   = 1'b0;
        r_wen   = 1'b0;
        b_wdata = '0;
        r_wdata = '0;

        // AHB defaults: IDLE
        hsel      = 1'b0;
        htrans    = HTRANS_IDLE;
        hwrite    = 1'b0;
        haddr     = '0;
        hsize     = 3'b010;  // 32-bit default
        hburst    = HBURST_SINGLE;
        hwdata    = '0;
        hmastlock = 1'b0;

        case (state)
            // ====================================================
            S_IDLE: begin
                // Write has priority over read
                if (!aw_empty && !wr_id_blocked) begin
                    state_next = S_WR_ADDR;
                    aw_ren     = 1'b1;
                end else if (!ar_empty && !rd_id_blocked) begin
                    state_next = S_RD_ADDR;
                    ar_ren     = 1'b1;
                end
            end

            // ====================================================
            //  WRITE PATH
            // ====================================================
            S_WR_ADDR: begin
                // Wait until W FIFO has data for alignment
                if (w_empty) begin
                    state_next = S_WR_WAIT_DATA;
                end else begin
                    // Unpack W FIFO
                    // Issue AHB address phase
                    hsel   = 1'b1;
                    htrans = (beat_cnt == txn_len) ? HTRANS_NONSEQ : HTRANS_SEQ;
                    hwrite = 1'b1;
                    haddr  = cur_addr;
                    hsize  = txn_size;
                    hburst = axi_to_ahb_burst(txn_len, txn_burst);
                    if (hready)
                        state_next = S_WR_DATA;
                end
            end

            S_WR_WAIT_DATA: begin
                if (!w_empty)
                    state_next = S_WR_ADDR;
            end

            S_WR_DATA: begin
                hsel   = 1'b1;
                hwrite = 1'b1;
                haddr  = cur_addr;
                hsize  = txn_size;
                hwdata = cur_wdata;
                htrans = HTRANS_IDLE;  // data phase: keep IDLE unless new beat
                if (hready) begin
                    if (hresp) begin
                        // AHB ERROR: first cycle (HRESP=1, HREADY=0 already passed)
                        state_next = S_WR_ERROR;
                    end else begin
                        w_ren = 1'b1;  // consume W beat
                        if (beat_cnt == 8'd0) begin
                            state_next = S_WR_RESP;
                        end else begin
                            // More beats: issue next addr phase
                            if (w_empty)
                                state_next = S_WR_WAIT_DATA;
                            else begin
                                hsel   = 1'b1;
                                htrans = HTRANS_SEQ;
                                state_next = S_WR_DATA;
                            end
                        end
                    end
                end
            end

            S_WR_ERROR: begin
                // Second cycle of AHB ERROR: HREADY=1
                // AHB spec: must keep HTRANS/HADDR/HWRITE stable
                hsel   = 1'b1;
                htrans = HTRANS_IDLE;
                hwrite = 1'b1;
                if (hready) begin
                    state_next = S_WR_RESP;
                end
            end

            S_WR_RESP: begin
                if (!b_full) begin
                    b_wen   = 1'b1;
                    b_wdata = {txn_id, txn_err_resp};
                    state_next = S_IDLE;
                end
            end

            // ====================================================
            //  READ PATH
            // ====================================================
            S_RD_ADDR: begin
                hsel   = 1'b1;
                htrans = HTRANS_NONSEQ;
                hwrite = 1'b0;
                haddr  = cur_addr;
                hsize  = txn_size;
                hburst = axi_to_ahb_burst(txn_len, txn_burst);
                if (hready)
                    state_next = S_RD_DATA;
            end

            S_RD_DATA: begin
                hsel   = 1'b1;
                hwrite = 1'b0;
                haddr  = cur_addr;
                hsize  = txn_size;
                // Issue next beat address while capturing current data
                if (beat_cnt > 8'd0)
                    htrans = HTRANS_SEQ;
                else
                    htrans = HTRANS_IDLE;

                if (hready) begin
                    if (hresp) begin
                        state_next = S_RD_ERROR;
                    end else begin
                        if (!r_full) begin
                            r_wen   = 1'b1;
                            r_wdata = {txn_id, hrdata, 2'b00, (beat_cnt == 8'd0)};
                        end
                        if (beat_cnt == 8'd0)
                            state_next = S_IDLE;
                    end
                end
            end

            S_RD_ERROR: begin
                hsel   = 1'b1;
                htrans = HTRANS_IDLE;
                hwrite = 1'b0;
                if (hready) begin
                    if (!r_full) begin
                        r_wen   = 1'b1;
                        r_wdata = {txn_id, {DATA_WIDTH{1'b0}}, 2'b10, 1'b1}; // SLVERR + last
                    end
                    state_next = S_IDLE;
                end
            end

            default: state_next = S_IDLE;
        endcase
    end

    // ----------------------------------------------------------------
    //  Sequential: latch transaction info & beat tracking
    // ----------------------------------------------------------------
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            txn_id        <= '0;
            txn_start_addr<= '0;
            txn_len       <= '0;
            txn_size      <= '0;
            txn_burst     <= '0;
            txn_is_write  <= '0;
            txn_err_resp  <= '0;
            beat_cnt      <= '0;
            cur_addr      <= '0;
            cur_wdata     <= '0;
            cur_wstrb     <= '0;
            cur_wlast     <= '0;
            cur_resp      <= '0;

            for (int i = 0; i < NUM_IDS; i++) begin
                wr_id_cnt[i] <= '0;
                rd_id_cnt[i] <= '0;
            end

        end else begin

            // ---- Latch new write transaction ----
            if (state == S_IDLE && !aw_empty && !wr_id_blocked && aw_ren) begin
                txn_id       <= wr_id;
                txn_start_addr<= wr_addr;
                txn_len      <= wr_len;
                txn_size     <= wr_size;
                txn_burst    <= wr_burst;
                txn_is_write <= 1'b1;
                txn_err_resp <= 2'b00;
                beat_cnt     <= wr_len;
                cur_addr     <= wr_addr;
                wr_id_cnt[wr_id] <= wr_id_cnt[wr_id] + 1;
            end

            // ---- Latch new read transaction ----
            if (state == S_IDLE && !ar_empty && !rd_id_blocked && ar_ren) begin
                txn_id       <= rd_id;
                txn_start_addr<= rd_addr;
                txn_len      <= rd_len;
                txn_size     <= rd_size;
                txn_burst    <= rd_burst;
                txn_is_write <= 1'b0;
                txn_err_resp <= 2'b00;
                beat_cnt     <= rd_len;
                cur_addr     <= rd_addr;
                rd_id_cnt[rd_id] <= rd_id_cnt[rd_id] + 1;
            end

            // ---- Latch W FIFO data when entering write data phase ----
            if ((state == S_WR_ADDR || state == S_WR_WAIT_DATA) && !w_empty) begin
                {cur_wdata, cur_wstrb, cur_wlast} <= w_rdata;
            end

            // ---- Advance address and beat counter on each accepted AHB beat ----
            if ((state == S_WR_DATA || state == S_RD_DATA) && hready && !hresp) begin
                if (beat_cnt > 8'd0) begin
                    beat_cnt <= beat_cnt - 8'd1;
                    cur_addr <= next_addr(cur_addr, txn_size, txn_burst, txn_len);
                end
            end

            // ---- Accumulate error ----
            if ((state == S_WR_DATA || state == S_RD_DATA) && hready && hresp)
                txn_err_resp <= 2'b10;  // SLVERR

            // ---- Release ID counter when transaction completes ----
            if (state == S_WR_RESP && !b_full) begin
                if (wr_id_cnt[txn_id] > 0)
                    wr_id_cnt[txn_id] <= wr_id_cnt[txn_id] - 1;
            end
            if ((state == S_RD_DATA && hready && !hresp && beat_cnt == 8'd0) ||
                (state == S_RD_ERROR && hready)) begin
                if (rd_id_cnt[txn_id] > 0)
                    rd_id_cnt[txn_id] <= rd_id_cnt[txn_id] - 1;
            end
        end
    end

endmodule
