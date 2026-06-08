// ============================================================
//  axi_ahb_bridge_top.sv
//  Top-level: AXI4 Slave <-> AHB-Lite Master Bridge
//
//  Parameters
//    DATA_WIDTH   : 32 (fixed per spec)
//    ADDR_WIDTH   : 32 (fixed per spec)
//    ID_WIDTH     : 4
//    MAX_OUTSTANDING : 4  (per-ID queue depth = 4)
//    FIFO_DEPTH   : 8  (async FIFO depth, power-of-2)
//    CDC_ENABLE   : 1 -> use async FIFOs (dual-clock)
//                   0 -> use sync FIFOs  (single-clock)
//
//  Notes
//    - AXI exclusive access is downgraded to normal access
//    - AXI FIXED burst is converted to multiple SINGLE AHB beats
//    - AHB ERROR response (2-cycle) is handled and mapped to SLVERR
//    - In-order per ID: each ID has its own 4-entry request queue
// ============================================================

module axi_ahb_bridge_top #(
    parameter int DATA_WIDTH      = 32,
    parameter int ADDR_WIDTH      = 32,
    parameter int ID_WIDTH        = 4,
    parameter int MAX_OUTSTANDING = 4,
    parameter int FIFO_DEPTH      = 8,
    parameter bit CDC_ENABLE      = 1
)(
    // ---- AXI clock / reset ----
    input  logic                    axi_clk,
    input  logic                    axi_rstn,

    // ---- AHB clock / reset ----
    input  logic                    ahb_clk,
    input  logic                    ahb_rstn,

    // ========== AXI Slave Interface ==========
    // Write Address Channel
    input  logic [ID_WIDTH-1:0]     s_axi_awid,
    input  logic [ADDR_WIDTH-1:0]   s_axi_awaddr,
    input  logic [7:0]              s_axi_awlen,
    input  logic [2:0]              s_axi_awsize,
    input  logic [1:0]              s_axi_awburst,
    input  logic                    s_axi_awlock,
    input  logic [3:0]              s_axi_awcache,
    input  logic [2:0]              s_axi_awprot,
    input  logic                    s_axi_awvalid,
    output logic                    s_axi_awready,

    // Write Data Channel
    input  logic [DATA_WIDTH-1:0]   s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input  logic                    s_axi_wlast,
    input  logic                    s_axi_wvalid,
    output logic                    s_axi_wready,

    // Write Response Channel
    output logic [ID_WIDTH-1:0]     s_axi_bid,
    output logic [1:0]              s_axi_bresp,
    output logic                    s_axi_bvalid,
    input  logic                    s_axi_bready,

    // Read Address Channel
    input  logic [ID_WIDTH-1:0]     s_axi_arid,
    input  logic [ADDR_WIDTH-1:0]   s_axi_araddr,
    input  logic [7:0]              s_axi_arlen,
    input  logic [2:0]              s_axi_arsize,
    input  logic [1:0]              s_axi_arburst,
    input  logic                    s_axi_arlock,
    input  logic [3:0]              s_axi_arcache,
    input  logic [2:0]              s_axi_arprot,
    input  logic                    s_axi_arvalid,
    output logic                    s_axi_arready,

    // Read Data Channel
    output logic [ID_WIDTH-1:0]     s_axi_rid,
    output logic [DATA_WIDTH-1:0]   s_axi_rdata,
    output logic [1:0]              s_axi_rresp,
    output logic                    s_axi_rlast,
    output logic                    s_axi_rvalid,
    input  logic                    s_axi_rready,

    // ========== AHB-Lite Master Interface ==========
    output logic [ADDR_WIDTH-1:0]   m_ahb_haddr,
    output logic [2:0]              m_ahb_hburst,
    output logic [2:0]              m_ahb_hsize,
    output logic [1:0]              m_ahb_htrans,
    output logic [DATA_WIDTH-1:0]   m_ahb_hwdata,
    output logic                    m_ahb_hwrite,
    output logic                    m_ahb_hsel,
    output logic                    m_ahb_hmastlock,
    input  logic [DATA_WIDTH-1:0]   m_ahb_hrdata,
    input  logic                    m_ahb_hready,
    input  logic                    m_ahb_hresp
);

    // ----------------------------------------------------------------
    //  Internal FIFO payload widths
    //    AW/AR: id + addr + len + size + burst + prot  = 4+32+8+3+2+3 = 52
    //    W    : data + strb + last                     = 32+4+1        = 37
    //    B    : id + resp                              = 4+2           = 6
    //    R    : id + data + resp + last                = 4+32+2+1      = 39
    // ----------------------------------------------------------------
    localparam int AW_WIDTH = ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 + 3; // 52
    localparam int W_WIDTH  = DATA_WIDTH + DATA_WIDTH/8 + 1;          // 37
    localparam int B_WIDTH  = ID_WIDTH + 2;                           // 6
    localparam int AR_WIDTH = ID_WIDTH + ADDR_WIDTH + 8 + 3 + 2 + 3; // 52
    localparam int R_WIDTH  = ID_WIDTH + DATA_WIDTH + 2 + 1;          // 39

    // ----------------------------------------------------------------
    //  FIFO signals
    // ----------------------------------------------------------------
    // AW
    logic [AW_WIDTH-1:0] aw_wdata, aw_rdata;
    logic                aw_wen,   aw_ren;
    logic                aw_full,  aw_empty;

    // W
    logic [W_WIDTH-1:0]  w_wdata,  w_rdata;
    logic                w_wen,    w_ren;
    logic                w_full,   w_empty;

    // B (AHB->AXI direction)
    logic [B_WIDTH-1:0]  b_wdata,  b_rdata;
    logic                b_wen,    b_ren;
    logic                b_full,   b_empty;

    // AR
    logic [AR_WIDTH-1:0] ar_wdata, ar_rdata;
    logic                ar_wen,   ar_ren;
    logic                ar_full,  ar_empty;

    // R (AHB->AXI direction)
    logic [R_WIDTH-1:0]  r_wdata,  r_rdata;
    logic                r_wen,    r_ren;
    logic                r_full,   r_empty;

    // ----------------------------------------------------------------
    //  Pack/Unpack AW channel
    // ----------------------------------------------------------------
    assign aw_wdata = {s_axi_awid, s_axi_awaddr, s_axi_awlen,
                       s_axi_awsize, s_axi_awburst, s_axi_awprot};
    assign aw_wen   = s_axi_awvalid & ~aw_full;
    assign s_axi_awready = ~aw_full;

    // ----------------------------------------------------------------
    //  Pack/Unpack W channel
    // ----------------------------------------------------------------
    assign w_wdata = {s_axi_wdata, s_axi_wstrb, s_axi_wlast};
    assign w_wen   = s_axi_wvalid & ~w_full;
    assign s_axi_wready = ~w_full;

    // ----------------------------------------------------------------
    //  Unpack B channel -> AXI B outputs
    // ----------------------------------------------------------------
    logic [ID_WIDTH-1:0] b_id;
    logic [1:0]          b_resp;
    assign {b_id, b_resp} = b_rdata;

    // B channel handshake (AXI side)
    logic b_valid_reg;
    logic [ID_WIDTH-1:0] b_id_reg;
    logic [1:0]          b_resp_reg;

    always_ff @(posedge axi_clk or negedge axi_rstn) begin
        if (!axi_rstn) begin
            b_valid_reg <= 1'b0;
            b_id_reg    <= '0;
            b_resp_reg  <= 2'b00;
        end else begin
            if (!b_valid_reg && !b_empty) begin
                b_valid_reg <= 1'b1;
                b_id_reg    <= b_id;
                b_resp_reg  <= b_resp;
                b_ren       <= 1'b1;
            end else begin
                b_ren <= 1'b0;
                if (b_valid_reg && s_axi_bready)
                    b_valid_reg <= 1'b0;
            end
        end
    end

    assign s_axi_bvalid = b_valid_reg;
    assign s_axi_bid    = b_id_reg;
    assign s_axi_bresp  = b_resp_reg;

    // ----------------------------------------------------------------
    //  Pack/Unpack AR channel
    // ----------------------------------------------------------------
    assign ar_wdata = {s_axi_arid, s_axi_araddr, s_axi_arlen,
                       s_axi_arsize, s_axi_arburst, s_axi_arprot};
    assign ar_wen   = s_axi_arvalid & ~ar_full;
    assign s_axi_arready = ~ar_full;

    // ----------------------------------------------------------------
    //  Unpack R channel -> AXI R outputs
    // ----------------------------------------------------------------
    logic [R_WIDTH-1:0] r_rdata_reg;
    logic               r_valid_reg;

    always_ff @(posedge axi_clk or negedge axi_rstn) begin
        if (!axi_rstn) begin
            r_valid_reg <= 1'b0;
            r_rdata_reg <= '0;
            r_ren       <= 1'b0;
        end else begin
            if (!r_valid_reg && !r_empty) begin
                r_valid_reg <= 1'b1;
                r_rdata_reg <= r_rdata;
                r_ren       <= 1'b1;
            end else begin
                r_ren <= 1'b0;
                if (r_valid_reg && s_axi_rready)
                    r_valid_reg <= 1'b0;
            end
        end
    end

    assign s_axi_rvalid = r_valid_reg;
    assign {s_axi_rid, s_axi_rdata, s_axi_rresp, s_axi_rlast} = r_rdata_reg;

    // ----------------------------------------------------------------
    //  FIFO instantiation (async or sync based on CDC_ENABLE)
    // ----------------------------------------------------------------
    generate
        if (CDC_ENABLE) begin : gen_async
            // AW FIFO  (write: axi_clk, read: ahb_clk)
            async_fifo #(.WIDTH(AW_WIDTH), .DEPTH(FIFO_DEPTH)) u_aw_fifo (
                .wclk(axi_clk), .wrstn(axi_rstn),
                .rclk(ahb_clk), .rrstn(ahb_rstn),
                .wen(aw_wen),   .wdata(aw_wdata),
                .ren(aw_ren),   .rdata(aw_rdata),
                .full(aw_full), .empty(aw_empty)
            );
            // W FIFO
            async_fifo #(.WIDTH(W_WIDTH), .DEPTH(FIFO_DEPTH)) u_w_fifo (
                .wclk(axi_clk), .wrstn(axi_rstn),
                .rclk(ahb_clk), .rrstn(ahb_rstn),
                .wen(w_wen),   .wdata(w_wdata),
                .ren(w_ren),   .rdata(w_rdata),
                .full(w_full), .empty(w_empty)
            );
            // B FIFO  (write: ahb_clk, read: axi_clk)
            async_fifo #(.WIDTH(B_WIDTH), .DEPTH(FIFO_DEPTH)) u_b_fifo (
                .wclk(ahb_clk), .wrstn(ahb_rstn),
                .rclk(axi_clk), .rrstn(axi_rstn),
                .wen(b_wen),   .wdata(b_wdata),
                .ren(b_ren),   .rdata(b_rdata),
                .full(b_full), .empty(b_empty)
            );
            // AR FIFO
            async_fifo #(.WIDTH(AR_WIDTH), .DEPTH(FIFO_DEPTH)) u_ar_fifo (
                .wclk(axi_clk), .wrstn(axi_rstn),
                .rclk(ahb_clk), .rrstn(ahb_rstn),
                .wen(ar_wen),   .wdata(ar_wdata),
                .ren(ar_ren),   .rdata(ar_rdata),
                .full(ar_full), .empty(ar_empty)
            );
            // R FIFO  (write: ahb_clk, read: axi_clk)
            async_fifo #(.WIDTH(R_WIDTH), .DEPTH(FIFO_DEPTH)) u_r_fifo (
                .wclk(ahb_clk), .wrstn(ahb_rstn),
                .rclk(axi_clk), .rrstn(axi_rstn),
                .wen(r_wen),   .wdata(r_wdata),
                .ren(r_ren),   .rdata(r_rdata),
                .full(r_full), .empty(r_empty)
            );
        end else begin : gen_sync
            // AW FIFO
            sync_fifo #(.WIDTH(AW_WIDTH), .DEPTH(FIFO_DEPTH)) u_aw_fifo (
                .clk(axi_clk), .rstn(axi_rstn),
                .wen(aw_wen),  .wdata(aw_wdata),
                .ren(aw_ren),  .rdata(aw_rdata),
                .full(aw_full),.empty(aw_empty)
            );
            sync_fifo #(.WIDTH(W_WIDTH), .DEPTH(FIFO_DEPTH)) u_w_fifo (
                .clk(axi_clk), .rstn(axi_rstn),
                .wen(w_wen),   .wdata(w_wdata),
                .ren(w_ren),   .rdata(w_rdata),
                .full(w_full), .empty(w_empty)
            );
            sync_fifo #(.WIDTH(B_WIDTH), .DEPTH(FIFO_DEPTH)) u_b_fifo (
                .clk(axi_clk), .rstn(axi_rstn),
                .wen(b_wen),   .wdata(b_wdata),
                .ren(b_ren),   .rdata(b_rdata),
                .full(b_full), .empty(b_empty)
            );
            sync_fifo #(.WIDTH(AR_WIDTH), .DEPTH(FIFO_DEPTH)) u_ar_fifo (
                .clk(axi_clk), .rstn(axi_rstn),
                .wen(ar_wen),  .wdata(ar_wdata),
                .ren(ar_ren),  .rdata(ar_rdata),
                .full(ar_full),.empty(ar_empty)
            );
            sync_fifo #(.WIDTH(R_WIDTH), .DEPTH(FIFO_DEPTH)) u_r_fifo (
                .clk(axi_clk), .rstn(axi_rstn),
                .wen(r_wen),   .wdata(r_wdata),
                .ren(r_ren),   .rdata(r_rdata),
                .full(r_full), .empty(r_empty)
            );
        end
    endgenerate

    // ----------------------------------------------------------------
    //  Bridge Controller (AHB clock domain)
    // ----------------------------------------------------------------
    bridge_controller #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .ID_WIDTH       (ID_WIDTH),
        .MAX_OUTSTANDING(MAX_OUTSTANDING),
        .AW_WIDTH       (AW_WIDTH),
        .W_WIDTH        (W_WIDTH),
        .B_WIDTH        (B_WIDTH),
        .AR_WIDTH       (AR_WIDTH),
        .R_WIDTH        (R_WIDTH)
    ) u_ctrl (
        .clk            (ahb_clk),
        .rstn           (ahb_rstn),
        // AW FIFO (read side)
        .aw_rdata       (aw_rdata),
        .aw_empty       (aw_empty),
        .aw_ren         (aw_ren),
        // W FIFO (read side)
        .w_rdata        (w_rdata),
        .w_empty        (w_empty),
        .w_ren          (w_ren),
        // B FIFO (write side)
        .b_wdata        (b_wdata),
        .b_full         (b_full),
        .b_wen          (b_wen),
        // AR FIFO (read side)
        .ar_rdata       (ar_rdata),
        .ar_empty       (ar_empty),
        .ar_ren         (ar_ren),
        // R FIFO (write side)
        .r_wdata        (r_wdata),
        .r_full         (r_full),
        .r_wen          (r_wen),
        // AHB Master
        .haddr          (m_ahb_haddr),
        .hburst         (m_ahb_hburst),
        .hsize          (m_ahb_hsize),
        .htrans         (m_ahb_htrans),
        .hwdata         (m_ahb_hwdata),
        .hwrite         (m_ahb_hwrite),
        .hsel           (m_ahb_hsel),
        .hmastlock      (m_ahb_hmastlock),
        .hrdata         (m_ahb_hrdata),
        .hready         (m_ahb_hready),
        .hresp          (m_ahb_hresp)
    );

endmodule
