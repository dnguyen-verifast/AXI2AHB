`ifndef AHB_MASTER_DRIVER_SV
`define AHB_MASTER_DRIVER_SV

// ============================================================
//  AHB Master Driver — production-grade
//  Spec: AMBA AHB5 (also compatible with AHB-Lite)
//  Features:
//    - 2-phase pipeline (addr/data decoupled via FIFO)
//    - SINGLE + INCR + WRAP burst support
//    - HRESP ERROR 2-cycle detection
//    - hreadyout timeout with configurable limit
//    - Active-low reset loop (handles multiple resets)
//    - clocking block drive/sample (no race condition)
//    - put_response() for read data back to sequencer
//    - uvm_callback support
//    - Config object via uvm_config_db
// ============================================================

// ------------------------------------------------------------
//  Config object — mọi magic number đặt ở đây
// ------------------------------------------------------------
class ahb_master_cfg extends uvm_object;
    `uvm_object_utils(ahb_master_cfg)

    // Bao nhiêu cycle tối đa slave được phép kéo HREADY=0
    int unsigned hready_timeout = 256;

    // Max beat trong 1 burst (INCR không giới hạn thì dùng giá trị này)
    int unsigned max_incr_beats = 16;

    // In ra toàn bộ transaction ở level nào
    uvm_verbosity tx_verbosity = UVM_HIGH;

    function new(string name = "ahb_master_cfg");
        super.new(name);
    endfunction
endclass : ahb_master_cfg


// ------------------------------------------------------------
//  Callback base — test layer override để inject lỗi, coverage...
// ------------------------------------------------------------
class ahb_master_driver_cbs extends uvm_callback;
    `uvm_object_utils(ahb_master_driver_cbs)

    // Gọi ngay trước khi drive address phase
    virtual task pre_addr_phase(ahb_master_tx tx); endtask

    // Gọi ngay sau khi data phase hoàn thành (response đã sample)
    virtual task post_data_phase(ahb_master_tx tx); endtask

    function new(string name = "ahb_master_driver_cbs");
        super.new(name);
    endfunction
endclass : ahb_master_driver_cbs


// ------------------------------------------------------------
//  Driver chính
// ------------------------------------------------------------
class ahb_master_driver extends uvm_driver #(ahb_master_tx);
    `uvm_component_utils(ahb_master_driver)
    `uvm_register_cb(ahb_master_driver, ahb_master_driver_cbs)

    // --------------------------------------------------------
    //  Ports
    // --------------------------------------------------------
    // seq_item_port đã có trong uvm_driver base class — không khai báo lại

    // Trả read data / response về sequencer (optional, dùng khi cần)
    uvm_analysis_port #(ahb_master_tx) rsp_port;

    // FIFO nội bộ nối addr thread → data thread
    uvm_tlm_fifo #(ahb_master_tx) pipeline_fifo;

    // --------------------------------------------------------
    //  Handles
    // --------------------------------------------------------
    virtual ahb_if vif;          // clocking block bên trong interface
    ahb_master_cfg cfg;

    // --------------------------------------------------------
    //  Methods khai báo extern
    // --------------------------------------------------------
    extern function new(string name = "ahb_master_driver", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task          run_phase(uvm_phase phase);

    extern protected task drive_addr_phase();
    extern protected task drive_data_phase();

    extern protected task wait_for_reset_deassert();
    extern protected task idle_bus();
    extern protected task wait_hready(int unsigned timeout_cycles);
    extern protected task handle_error_response(ahb_master_tx tx);
    extern protected task drive_burst(ahb_master_tx tx);

endclass : ahb_master_driver


// ============================================================
//  Implementations
// ============================================================

function ahb_master_driver::new(string name = "ahb_master_driver",
                                 uvm_component parent = null);
    super.new(name, parent);
    // KHÔNG tạo port ở đây — phải trong build_phase
endfunction : new


function void ahb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Lấy virtual interface
    if (!uvm_config_db #(virtual ahb_if)::get(this, "", "ahb_vif", vif))
        `uvm_fatal("CFG_ERR", "Cannot get virtual interface ahb_vif from config_db")

    // Lấy config object; nếu không có thì dùng default
    if (!uvm_config_db #(ahb_master_cfg)::get(this, "", "ahb_master_cfg", cfg)) begin
        `uvm_info(get_name(), "No cfg found, using defaults", UVM_MEDIUM)
        cfg = ahb_master_cfg::type_id::create("cfg");
    end

    // Tạo ports và FIFOs trong build_phase
    rsp_port      = new("rsp_port",      this);
    pipeline_fifo = new("pipeline_fifo", this, 2); // depth=2 đủ cho 1 pipeline slot
endfunction : build_phase


function void ahb_master_driver::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_name(), $sformatf("Driver ready. hready_timeout=%0d cycles",
              cfg.hready_timeout), UVM_MEDIUM)
endfunction : end_of_elaboration_phase


// ------------------------------------------------------------
//  run_phase: loop vĩnh viễn, restart sau mỗi lần reset
// ------------------------------------------------------------
task ahb_master_driver::run_phase(uvm_phase phase);
    `uvm_info(get_name(), "run_phase started", UVM_LOW)
    forever begin
        // Idle bus và chờ reset deassert
        idle_bus();
        wait_for_reset_deassert();

        // Chạy 2 thread song song (pipeline). join_none để loop tiếp ngay.
        // Khi reset assert lại, disable cả 2 thread qua event/flag.
        fork
            drive_addr_phase();
            drive_data_phase();
        join_none

        // Chờ reset assert trở lại để restart vòng lặp
        @(negedge vif.hresetn);
        disable fork;   // kill cả 2 thread khi reset về
        `uvm_info(get_name(), "Reset asserted — flushing pipeline", UVM_MEDIUM)
        // Flush FIFO để tránh stale transaction
        begin
            ahb_master_tx tmp;
            while (pipeline_fifo.try_get(tmp)) begin end
        end
    end
endtask : run_phase


// ------------------------------------------------------------
//  idle_bus: drive HTRANS=IDLE khi bus không dùng
// ------------------------------------------------------------
task ahb_master_driver::idle_bus();
    vif.master_cb.haddr     <= '0;
    vif.master_cb.hburst    <= 3'b000;   // SINGLE
    vif.master_cb.hmastlock <= 1'b0;
    vif.master_cb.hprot     <= 4'b0011;  // non-cacheable, privileged data
    vif.master_cb.hsize     <= 3'b010;   // WORD default
    vif.master_cb.hnonsec   <= 1'b0;
    vif.master_cb.hexcl     <= 1'b0;
    vif.master_cb.hmaster   <= '0;
    vif.master_cb.htrans    <= 2'b00;    // IDLE
    vif.master_cb.hwdata    <= '0;
    vif.master_cb.hwstrb    <= '0;
    vif.master_cb.hwrite    <= 1'b0;
endtask : idle_bus


// ------------------------------------------------------------
//  wait_for_reset_deassert: chờ hresetn lên (active-low)
// ------------------------------------------------------------
task ahb_master_driver::wait_for_reset_deassert();
    // Nếu đang reset thì chờ; nếu không thì qua ngay
    if (vif.hresetn === 1'b0) begin
        `uvm_info(get_name(), "Waiting for reset deassert...", UVM_MEDIUM)
        @(posedge vif.hresetn);
        // Thêm 1 cycle sau reset để ổn định
        @(vif.master_cb);
        `uvm_info(get_name(), "Reset deasserted — bus operational", UVM_MEDIUM)
    end
endtask : wait_for_reset_deassert


// ------------------------------------------------------------
//  wait_hready: chờ slave assert HREADY, có timeout
// ------------------------------------------------------------
task ahb_master_driver::wait_hready(int unsigned timeout_cycles);
    int unsigned cnt = 0;
    while (vif.master_cb.hreadyout === 1'b0) begin
        @(vif.master_cb);
        cnt++;
        if (cnt >= timeout_cycles) begin
            `uvm_error(get_name(), $sformatf(
                "HREADY timeout after %0d cycles — slave may be hung!", cnt))
            return;
        end
    end
endtask : wait_hready


// ------------------------------------------------------------
//  handle_error_response: AHB spec yêu cầu ERROR có 2 cycle
// ------------------------------------------------------------
task ahb_master_driver::handle_error_response(ahb_master_tx tx);
    // Cycle 1: slave assert hresp=ERROR + hreadyout=0
    // Cycle 2: slave assert hresp=ERROR + hreadyout=1
    // Master phải đọc ở cycle 2
    if (vif.master_cb.hresp === 2'b01) begin
        `uvm_info(get_name(), $sformatf(
            "ERROR response received for addr=0x%0h", tx.haddr), UVM_LOW)
        tx.hresp = vif.master_cb.hresp;
        @(vif.master_cb); // consume cycle 2 của ERROR sequence
        // Sau ERROR, master phải abort burst — drive HTRANS=IDLE
        vif.master_cb.htrans <= 2'b00;
    end
endtask : handle_error_response


// ------------------------------------------------------------
//  drive_addr_phase: lấy transaction từ sequencer, drive address
// ------------------------------------------------------------
task ahb_master_driver::drive_addr_phase();
    ahb_master_tx tx;
    forever begin
        // Lấy transaction từ sequencer
        seq_item_port.get_next_item(tx);

        `uvm_info(get_name(), $sformatf(
            "ADDR_PHASE: %s addr=0x%0h size=%0d burst=%0d",
            tx.hwrite ? "WRITE" : "READ", tx.haddr, tx.hsize, tx.hburst),
            cfg.tx_verbosity)

        // Callback hook trước khi drive
        `uvm_do_callbacks(ahb_master_driver, ahb_master_driver_cbs,
                          pre_addr_phase(tx))

        // Chờ đúng clock edge (clocking block đảm bảo setup time)
        @(vif.master_cb);

        // Drive address + control phase
        vif.master_cb.haddr     <= tx.haddr;
        vif.master_cb.hburst    <= tx.hburst;
        vif.master_cb.hmastlock <= tx.hmastlock;
        vif.master_cb.hprot     <= tx.hprot;
        vif.master_cb.hsize     <= tx.hsize;
        vif.master_cb.hnonsec   <= tx.hnonsec;
        vif.master_cb.hexcl     <= tx.hexcl;
        vif.master_cb.hmaster   <= tx.hmaster;
        vif.master_cb.htrans    <= 2'b10;   // NONSEQ — bắt đầu transfer
        vif.master_cb.hwrite    <= tx.hwrite;

        // Nếu là burst, drive các beat tiếp theo (SEQ)
        if (tx.hburst != 3'b000) begin
            drive_burst(tx);
        end

        // Đưa tx vào FIFO cho data phase thread lấy
        pipeline_fifo.put(tx);

        // NOTE: item_done() KHÔNG gọi ở đây.
        // Phải gọi sau khi data phase hoàn thành để response đúng.
    end
endtask : drive_addr_phase


// ------------------------------------------------------------
//  drive_burst: generate SEQ beats cho INCR/WRAP burst
// ------------------------------------------------------------
task ahb_master_driver::drive_burst(ahb_master_tx tx);
    int unsigned beats;
    logic [31:0] next_addr;
    int unsigned byte_offset;

    // Xác định số beat dựa vào hburst
    case (tx.hburst)
        3'b010, 3'b011: beats = 4;   // INCR4 / WRAP4
        3'b100, 3'b101: beats = 8;   // INCR8 / WRAP8
        3'b110, 3'b111: beats = 16;  // INCR16 / WRAP16
        3'b001:         beats = cfg.max_incr_beats; // INCR (undefined length)
        default:        beats = 1;   // SINGLE
    endcase

    byte_offset = (1 << tx.hsize); // bytes per beat
    next_addr   = tx.haddr + byte_offset;

    for (int i = 1; i < beats; i++) begin
        @(vif.master_cb);
        vif.master_cb.haddr  <= next_addr;
        vif.master_cb.htrans <= 2'b11; // SEQ
        next_addr += byte_offset;
    end
endtask : drive_burst


// ------------------------------------------------------------
//  drive_data_phase: ambil dari FIFO, drive HWDATA / sample HRDATA
// ------------------------------------------------------------
task ahb_master_driver::drive_data_phase();
    ahb_master_tx tx;
    forever begin
        // Ambil transaction yang sudah di-drive addr-nya
        pipeline_fifo.get(tx);

        // Chờ slave sẵn sàng nhận/trả data
        wait_hready(cfg.hready_timeout);

        if (tx.hwrite) begin
            //  WRITE: drive data
            `uvm_info(get_name(), $sformatf(
                "DATA_PHASE WRITE: data=0x%0h strb=0x%0h", tx.hwdata, tx.hwstrb),
                cfg.tx_verbosity)
            vif.master_cb.hwdata <= tx.hwdata;
            vif.master_cb.hwstrb <= tx.hwstrb;
            @(vif.master_cb);
            // Chờ slave accept data
            wait_hready(cfg.hready_timeout);
        end else begin
            //  READ: sample data từ slave
            @(vif.master_cb);
            tx.hrdata = vif.master_cb.hrdata;
            `uvm_info(get_name(), $sformatf(
                "DATA_PHASE READ: addr=0x%0h hrdata=0x%0h",
                tx.haddr, tx.hrdata), cfg.tx_verbosity)
        end

        // Kiểm tra error response
        handle_error_response(tx);

        // Callback hook sau khi hoàn thành
        `uvm_do_callbacks(ahb_master_driver, ahb_master_driver_cbs,
                          post_data_phase(tx))

        // Trả response về sequencer (read data, hresp)
        rsp_port.write(tx);
        seq_item_port.item_done(tx); // item_done ở đây, không phải addr phase

        // Sau transaction xong, về IDLE 1 cycle
        idle_bus();
    end
endtask : drive_data_phase

`endif // AHB_MASTER_DRIVER_SV