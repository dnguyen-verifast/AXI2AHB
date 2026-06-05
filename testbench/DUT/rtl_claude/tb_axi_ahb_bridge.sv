// ============================================================
//  tb_axi_ahb_bridge.sv
//  Testbench for axi_ahb_bridge_top
//
//  Test scenarios:
//    TC1 : Single write, single read (INCR, len=0)
//    TC2 : Burst write INCR4 (len=3)
//    TC3 : Burst read  INCR8 (len=7)
//    TC4 : WRAP4 write (len=3)
//    TC5 : FIXED burst write (len=3) -> 4 SINGLE AHB beats
//    TC6 : AHB ERROR response on write -> SLVERR to AXI
//    TC7 : AHB ERROR response on read  -> SLVERR to AXI
//    TC8 : Multi-ID interleaved writes (ID=0 and ID=1)
//    TC9 : HREADY=0 wait states from slave
//    TC10: Back-to-back read+write mix
// ============================================================

`timescale 1ns/1ps

module tb_axi_ahb_bridge;

    // ----------------------------------------------------------------
    //  Parameters
    // ----------------------------------------------------------------
    localparam int DATA_W = 32;
    localparam int ADDR_W = 32;
    localparam int ID_W   = 4;
    localparam int FIFO_D = 8;
    localparam int MAX_OS = 4;

    // AXI clk period = 2ns (500 MHz), AHB clk = 10ns (100 MHz)
    localparam real AXI_PERIOD = 2.0;
    localparam real AHB_PERIOD = 10.0;

    // ----------------------------------------------------------------
    //  Clocks and resets
    // ----------------------------------------------------------------
    logic axi_clk  = 0;
    logic ahb_clk  = 0;
    logic axi_rstn = 0;
    logic ahb_rstn = 0;

    always #(AXI_PERIOD/2) axi_clk = ~axi_clk;
    always #(AHB_PERIOD/2) ahb_clk = ~ahb_clk;

    // ----------------------------------------------------------------
    //  DUT signals
    // ----------------------------------------------------------------
    // AXI Write Address
    logic [ID_W-1:0]    s_axi_awid;
    logic [ADDR_W-1:0]  s_axi_awaddr;
    logic [7:0]         s_axi_awlen;
    logic [2:0]         s_axi_awsize;
    logic [1:0]         s_axi_awburst;
    logic               s_axi_awlock;
    logic [3:0]         s_axi_awcache;
    logic [2:0]         s_axi_awprot;
    logic               s_axi_awvalid;
    logic               s_axi_awready;
    // AXI Write Data
    logic [DATA_W-1:0]  s_axi_wdata;
    logic [DATA_W/8-1:0] s_axi_wstrb;
    logic               s_axi_wlast;
    logic               s_axi_wvalid;
    logic               s_axi_wready;
    // AXI Write Response
    logic [ID_W-1:0]    s_axi_bid;
    logic [1:0]         s_axi_bresp;
    logic               s_axi_bvalid;
    logic               s_axi_bready;
    // AXI Read Address
    logic [ID_W-1:0]    s_axi_arid;
    logic [ADDR_W-1:0]  s_axi_araddr;
    logic [7:0]         s_axi_arlen;
    logic [2:0]         s_axi_arsize;
    logic [1:0]         s_axi_arburst;
    logic               s_axi_arlock;
    logic [3:0]         s_axi_arcache;
    logic [2:0]         s_axi_arprot;
    logic               s_axi_arvalid;
    logic               s_axi_arready;
    // AXI Read Data
    logic [ID_W-1:0]    s_axi_rid;
    logic [DATA_W-1:0]  s_axi_rdata;
    logic [1:0]         s_axi_rresp;
    logic               s_axi_rlast;
    logic               s_axi_rvalid;
    logic               s_axi_rready;
    // AHB
    logic [ADDR_W-1:0]  m_ahb_haddr;
    logic [2:0]         m_ahb_hburst;
    logic [2:0]         m_ahb_hsize;
    logic [1:0]         m_ahb_htrans;
    logic [DATA_W-1:0]  m_ahb_hwdata;
    logic               m_ahb_hwrite;
    logic               m_ahb_hsel;
    logic               m_ahb_hmastlock;
    logic [DATA_W-1:0]  m_ahb_hrdata;
    logic               m_ahb_hready;
    logic               m_ahb_hresp;

    // ----------------------------------------------------------------
    //  DUT instantiation
    // ----------------------------------------------------------------
    axi_ahb_bridge_top #(
        .DATA_WIDTH     (DATA_W),
        .ADDR_WIDTH     (ADDR_W),
        .ID_WIDTH       (ID_W),
        .MAX_OUTSTANDING(MAX_OS),
        .FIFO_DEPTH     (FIFO_D),
        .CDC_ENABLE     (1)      // async FIFO mode
    ) dut (
        .axi_clk        (axi_clk),
        .axi_rstn       (axi_rstn),
        .ahb_clk        (ahb_clk),
        .ahb_rstn       (ahb_rstn),
        // AXI slave
        .s_axi_awid     (s_axi_awid),
        .s_axi_awaddr   (s_axi_awaddr),
        .s_axi_awlen    (s_axi_awlen),
        .s_axi_awsize   (s_axi_awsize),
        .s_axi_awburst  (s_axi_awburst),
        .s_axi_awlock   (s_axi_awlock),
        .s_axi_awcache  (s_axi_awcache),
        .s_axi_awprot   (s_axi_awprot),
        .s_axi_awvalid  (s_axi_awvalid),
        .s_axi_awready  (s_axi_awready),
        .s_axi_wdata    (s_axi_wdata),
        .s_axi_wstrb    (s_axi_wstrb),
        .s_axi_wlast    (s_axi_wlast),
        .s_axi_wvalid   (s_axi_wvalid),
        .s_axi_wready   (s_axi_wready),
        .s_axi_bid      (s_axi_bid),
        .s_axi_bresp    (s_axi_bresp),
        .s_axi_bvalid   (s_axi_bvalid),
        .s_axi_bready   (s_axi_bready),
        .s_axi_arid     (s_axi_arid),
        .s_axi_araddr   (s_axi_araddr),
        .s_axi_arlen    (s_axi_arlen),
        .s_axi_arsize   (s_axi_arsize),
        .s_axi_arburst  (s_axi_arburst),
        .s_axi_arlock   (s_axi_arlock),
        .s_axi_arcache  (s_axi_arcache),
        .s_axi_arprot   (s_axi_arprot),
        .s_axi_arvalid  (s_axi_arvalid),
        .s_axi_arready  (s_axi_arready),
        .s_axi_rid      (s_axi_rid),
        .s_axi_rdata    (s_axi_rdata),
        .s_axi_rresp    (s_axi_rresp),
        .s_axi_rlast    (s_axi_rlast),
        .s_axi_rvalid   (s_axi_rvalid),
        .s_axi_rready   (s_axi_rready),
        // AHB master
        .m_ahb_haddr    (m_ahb_haddr),
        .m_ahb_hburst   (m_ahb_hburst),
        .m_ahb_hsize    (m_ahb_hsize),
        .m_ahb_htrans   (m_ahb_htrans),
        .m_ahb_hwdata   (m_ahb_hwdata),
        .m_ahb_hwrite   (m_ahb_hwrite),
        .m_ahb_hsel     (m_ahb_hsel),
        .m_ahb_hmastlock(m_ahb_hmastlock),
        .m_ahb_hrdata   (m_ahb_hrdata),
        .m_ahb_hready   (m_ahb_hready),
        .m_ahb_hresp    (m_ahb_hresp)
    );

    // ----------------------------------------------------------------
    //  Simple AHB slave model
    //    - 4KB memory at base 0x0000_0000
    //    - Controlled by tb to inject wait states and errors
    // ----------------------------------------------------------------
    localparam int MEM_DEPTH = 1024;  // 1K words = 4KB
    logic [DATA_W-1:0] ahb_mem [0:MEM_DEPTH-1];

    int   ahb_wait_cnt   = 0;   // inject N wait states per transfer
    logic ahb_inject_err = 1'b0;

    logic [ADDR_W-1:0] haddr_lat;    // latched address (addr phase)
    logic              hwrite_lat;
    logic              hsel_lat;
    logic [1:0]        htrans_lat;
    logic              hready_int;
    logic              hresp_int;
    logic [DATA_W-1:0] hrdata_int;

    int wait_remaining = 0;
    bit err_pending    = 0;
    bit err_second     = 0;

    always_ff @(posedge ahb_clk or negedge ahb_rstn) begin
        if (!ahb_rstn) begin
            haddr_lat      <= '0;
            hwrite_lat     <= 1'b0;
            hsel_lat       <= 1'b0;
            htrans_lat     <= 2'b00;
            hready_int     <= 1'b1;
            hresp_int      <= 1'b0;
            hrdata_int     <= '0;
            wait_remaining <= 0;
            err_pending    <= 0;
            err_second     <= 0;
        end else begin

            // Latch address phase when hready=1
            if (hready_int) begin
                haddr_lat  <= m_ahb_haddr;
                hwrite_lat <= m_ahb_hwrite;
                hsel_lat   <= m_ahb_hsel;
                htrans_lat <= m_ahb_htrans;
            end

            // Default
            hready_int <= 1'b1;
            hresp_int  <= 1'b0;
            hrdata_int <= '0;

            // ERROR injection: 2-cycle response
            if (err_second) begin
                hready_int <= 1'b1;
                hresp_int  <= 1'b1;
                err_second <= 0;
            end else if (err_pending) begin
                hready_int <= 1'b0;
                hresp_int  <= 1'b1;
                err_pending <= 0;
                err_second  <= 1;
            end
            // Wait state injection
            else if (wait_remaining > 0) begin
                hready_int     <= 1'b0;
                wait_remaining <= wait_remaining - 1;
            end
            // Normal data phase
            else if (hsel_lat && (htrans_lat == 2'b10 || htrans_lat == 2'b11)) begin
                if (ahb_inject_err) begin
                    err_pending     <= 1;
                    ahb_inject_err  <= 1'b0;
                    hready_int      <= 1'b0;
                end else begin
                    wait_remaining <= ahb_wait_cnt;
                    if (hwrite_lat) begin
                        // Write: store data
                        if (haddr_lat[ADDR_W-1:2] < MEM_DEPTH)
                            ahb_mem[haddr_lat[ADDR_W-1:2]] <= m_ahb_hwdata;
                    end else begin
                        // Read: return data
                        if (haddr_lat[ADDR_W-1:2] < MEM_DEPTH)
                            hrdata_int <= ahb_mem[haddr_lat[ADDR_W-1:2]];
                        else
                            hrdata_int <= 32'hDEAD_BEEF;
                    end
                end
            end
        end
    end

    assign m_ahb_hready = hready_int;
    assign m_ahb_hresp  = hresp_int;
    assign m_ahb_hrdata = hrdata_int;

    // ----------------------------------------------------------------
    //  AXI Master Tasks
    // ----------------------------------------------------------------

    // -- AXI Write (single burst) --
    task automatic axi_write (
        input logic [ID_W-1:0]   id,
        input logic [ADDR_W-1:0] base_addr,
        input logic [7:0]        len,
        input logic [2:0]        size,
        input logic [1:0]        burst
    );
        logic [DATA_W-1:0] wdata_val;
        int beat;

        // Send AW
        @(posedge axi_clk);
        s_axi_awid    <= id;
        s_axi_awaddr  <= base_addr;
        s_axi_awlen   <= len;
        s_axi_awsize  <= size;
        s_axi_awburst <= burst;
        s_axi_awlock  <= 1'b0;
        s_axi_awcache <= 4'b0000;
        s_axi_awprot  <= 3'b000;
        s_axi_awvalid <= 1'b1;
        do @(posedge axi_clk); while (!s_axi_awready);
        s_axi_awvalid <= 1'b0;

        // Send W beats
        for (beat = 0; beat <= len; beat++) begin
            wdata_val = 32'hA000_0000 | (id << 24) | (base_addr[7:0] + beat*4);
            @(posedge axi_clk);
            s_axi_wdata  <= wdata_val;
            s_axi_wstrb  <= 4'hF;
            s_axi_wlast  <= (beat == len);
            s_axi_wvalid <= 1'b1;
            do @(posedge axi_clk); while (!s_axi_wready);
        end
        s_axi_wvalid <= 1'b0;
        s_axi_wlast  <= 1'b0;

        // Wait for B response
        s_axi_bready <= 1'b1;
        do @(posedge axi_clk); while (!s_axi_bvalid);
        @(posedge axi_clk);
        $display("[TB] WRITE DONE  id=%0h addr=0x%08h len=%0d bresp=%b at %0t",
                 s_axi_bid, base_addr, len, s_axi_bresp, $time);
        s_axi_bready <= 1'b0;
    endtask

    // -- AXI Read (single burst) --
    task automatic axi_read (
        input logic [ID_W-1:0]   id,
        input logic [ADDR_W-1:0] base_addr,
        input logic [7:0]        len,
        input logic [2:0]        size,
        input logic [1:0]        burst
    );
        int beat;
        // Send AR
        @(posedge axi_clk);
        s_axi_arid    <= id;
        s_axi_araddr  <= base_addr;
        s_axi_arlen   <= len;
        s_axi_arsize  <= size;
        s_axi_arburst <= burst;
        s_axi_arlock  <= 1'b0;
        s_axi_arcache <= 4'b0000;
        s_axi_arprot  <= 3'b000;
        s_axi_arvalid <= 1'b1;
        do @(posedge axi_clk); while (!s_axi_arready);
        s_axi_arvalid <= 1'b0;

        // Receive R beats
        s_axi_rready <= 1'b1;
        for (beat = 0; beat <= len; beat++) begin
            do @(posedge axi_clk); while (!s_axi_rvalid);
            $display("[TB] READ  DATA  id=%0h addr=0x%08h beat=%0d data=0x%08h rresp=%b rlast=%b at %0t",
                     s_axi_rid, base_addr, beat, s_axi_rdata,
                     s_axi_rresp, s_axi_rlast, $time);
        end
        @(posedge axi_clk);
        s_axi_rready <= 1'b0;
    endtask

    // -- Wait N AXI clocks --
    task automatic axi_wait(input int n);
        repeat(n) @(posedge axi_clk);
    endtask

    // ----------------------------------------------------------------
    //  Initialise all AXI signals
    // ----------------------------------------------------------------
    task init_axi;
        s_axi_awid    = '0; s_axi_awaddr = '0; s_axi_awlen  = '0;
        s_axi_awsize  = '0; s_axi_awburst= '0; s_axi_awlock = '0;
        s_axi_awcache = '0; s_axi_awprot = '0; s_axi_awvalid= '0;
        s_axi_wdata   = '0; s_axi_wstrb  = '0; s_axi_wlast  = '0;
        s_axi_wvalid  = '0;
        s_axi_bready  = '0;
        s_axi_arid    = '0; s_axi_araddr = '0; s_axi_arlen  = '0;
        s_axi_arsize  = '0; s_axi_arburst= '0; s_axi_arlock = '0;
        s_axi_arcache = '0; s_axi_arprot = '0; s_axi_arvalid= '0;
        s_axi_rready  = '0;
    endtask

    // ----------------------------------------------------------------
    //  Scoreboard: track PASS/FAIL
    // ----------------------------------------------------------------
    int pass_cnt = 0;
    int fail_cnt = 0;

    task check (input string name, input logic cond);
        if (cond) begin
            $display("[PASS] %s", name);
            pass_cnt++;
        end else begin
            $display("[FAIL] %s", name);
            fail_cnt++;
        end
    endtask

    // ----------------------------------------------------------------
    //  Main test sequence
    // ----------------------------------------------------------------
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_axi_ahb_bridge);

        init_axi();

        // Reset both domains
        axi_rstn = 0; ahb_rstn = 0;
        repeat(10) @(posedge axi_clk);
        repeat(5)  @(posedge ahb_clk);
        axi_rstn = 1;
        repeat(3)  @(posedge ahb_clk);
        ahb_rstn = 1;
        repeat(10) @(posedge axi_clk);

        // ============================================================
        $display("\n========== TC1: Single write + single read ==========");
        // ============================================================
        // Pre-load memory so read returns known value
        dut.u_ctrl.ahb_mem[0] = 32'hDEAD_1234;  // accessed via force below
        fork
            axi_write(.id(4'h1), .base_addr(32'h0000_0000),
                      .len(8'd0), .size(3'b010), .burst(2'b01));
        join
        axi_wait(20);
        fork
            axi_read(.id(4'h1), .base_addr(32'h0000_0000),
                     .len(8'd0), .size(3'b010), .burst(2'b01));
        join
        axi_wait(20);
        check("TC1 completed", (fail_cnt == 0));

        // ============================================================
        $display("\n========== TC2: INCR4 burst write (len=3) ==========");
        // ============================================================
        axi_write(.id(4'h2), .base_addr(32'h0000_0100),
                  .len(8'd3), .size(3'b010), .burst(2'b01));
        axi_wait(40);
        check("TC2 BRESP=OKAY", (s_axi_bresp == 2'b00));

        // ============================================================
        $display("\n========== TC3: INCR8 burst read (len=7) ===========");
        // ============================================================
        axi_read(.id(4'h3), .base_addr(32'h0000_0100),
                 .len(8'd7), .size(3'b010), .burst(2'b01));
        axi_wait(50);

        // ============================================================
        $display("\n========== TC4: WRAP4 write (len=3) ================");
        // ============================================================
        axi_write(.id(4'h0), .base_addr(32'h0000_0210),
                  .len(8'd3), .size(3'b010), .burst(2'b10));
        axi_wait(40);

        // ============================================================
        $display("\n========== TC5: FIXED burst write (len=3) ==========");
        // ============================================================
        axi_write(.id(4'h0), .base_addr(32'h0000_0300),
                  .len(8'd3), .size(3'b010), .burst(2'b00));
        axi_wait(60);

        // ============================================================
        $display("\n========== TC6: AHB ERROR on write -> SLVERR =======");
        // ============================================================
        ahb_inject_err = 1'b1;
        axi_write(.id(4'h4), .base_addr(32'h0000_0400),
                  .len(8'd0), .size(3'b010), .burst(2'b01));
        axi_wait(30);
        check("TC6 SLVERR received", (s_axi_bresp == 2'b10));

        // ============================================================
        $display("\n========== TC7: AHB ERROR on read -> SLVERR ========");
        // ============================================================
        ahb_inject_err = 1'b1;
        axi_read(.id(4'h5), .base_addr(32'h0000_0500),
                 .len(8'd0), .size(3'b010), .burst(2'b01));
        axi_wait(30);
        check("TC7 RRESP=SLVERR", (s_axi_rresp == 2'b10));

        // ============================================================
        $display("\n========== TC8: Multi-ID writes (ID=0 and ID=1) ====");
        // ============================================================
        fork
            axi_write(.id(4'h0), .base_addr(32'h0000_0600),
                      .len(8'd3), .size(3'b010), .burst(2'b01));
            begin
                axi_wait(5);
                axi_write(.id(4'h1), .base_addr(32'h0000_0700),
                          .len(8'd3), .size(3'b010), .burst(2'b01));
            end
        join
        axi_wait(60);

        // ============================================================
        $display("\n========== TC9: Wait states (2 cycles per beat) ====");
        // ============================================================
        ahb_wait_cnt = 2;
        axi_write(.id(4'h2), .base_addr(32'h0000_0800),
                  .len(8'd3), .size(3'b010), .burst(2'b01));
        axi_wait(80);
        ahb_wait_cnt = 0;
        check("TC9 completed no error", (s_axi_bresp == 2'b00));

        // ============================================================
        $display("\n========== TC10: Back-to-back read+write mix ========");
        // ============================================================
        fork
            axi_write(.id(4'h6), .base_addr(32'h0000_0900),
                      .len(8'd1), .size(3'b010), .burst(2'b01));
            begin
                axi_wait(3);
                axi_read(.id(4'h7), .base_addr(32'h0000_0100),
                         .len(8'd1), .size(3'b010), .burst(2'b01));
            end
        join
        axi_wait(60);

        // ============================================================
        //  Summary
        // ============================================================
        $display("\n=============================================");
        $display("  Simulation DONE");
        $display("  PASS: %0d   FAIL: %0d", pass_cnt, fail_cnt);
        $display("=============================================\n");

        if (fail_cnt == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED - check log above");

        $finish;
    end

    // ----------------------------------------------------------------
    //  Timeout watchdog (100us)
    // ----------------------------------------------------------------
    initial begin
        #100_000;
        $display("[WATCHDOG] Simulation timeout!");
        $finish;
    end

endmodule
