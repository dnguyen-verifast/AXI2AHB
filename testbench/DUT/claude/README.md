# AXI4 → AHB-Lite Bridge (v3)

Cầu chuyển đổi **AXI4 (slave) → AHB-Lite (master)** bằng SystemVerilog.
Kiến trúc **outstanding + out-of-order (OoO)** mạnh, đồng thời bổ sung đầy đủ
các tính năng theo **Xilinx PG177** (AXI4 to AHB-Lite Bridge v3.0).

Đã kiểm chứng bằng **4 bộ testbench** chạy Verilator — tất cả PASS.

---

## 1. Cấu trúc thư mục

```
bridge/
├── rtl/
│   ├── axi_ahb_pkg.sv        # Hằng số + hàm: burst-map, addr-gen, 1KB-cross,
│   │                          #   size-legal, HSIZE-from-strobe helper, HPROT-map
│   ├── sync_fifo.sv          # FIFO đồng bộ tham số hóa
│   ├── axi_write_engine.sv   # GHI: AW/W/B, AW-W match, WSTRB, narrow, 1KB, timeout
│   ├── axi_read_engine.sv    # ĐỌC: AR/R, streaming FIFO + backpressure, 1KB, timeout
│   ├── axi4_to_ahb_lite.sv   # TOP: 2 engine + AHB arbiter (burst-lock, read-priority)
│   └── ahb_lite_slave_mem.sv # Mô hình AHB slave cho sim (honor HSIZE byte-lane)
├── tb/
│   ├── tb_axi4_to_ahb_lite.sv# Bộ test cơ bản
│   ├── tb_bridge_advanced.sv # WSTRB / AxSIZE / burst-map / AW-W / per-ID order
│   ├── tb_spec_features.sv   # WRAP2 / 1KB-cross / FIXED-narrow / HPROT / narrow-single
│   └── tb_timeout.sv         # Bridge timeout -> SLVERR (read & write)
├── run.sh                    # ./run.sh {basic|advanced|spec|timeout|all}
└── README.md
```

---

## 2. Tính năng & mức tuân thủ PG177

| Tính năng PG177 | Trạng thái | Ghi chú |
|---|---|---|
| INCR length 1→256 | ✅ | INCR4/8/16 map đúng; còn lại INCR-undefined |
| WRAP 2/4/8/16 | ✅ | WRAP4/8/16 native; **WRAP2 → 2 AHB SINGLE** |
| FIXED length 1→16 | ✅ | → AHB SINGLE, địa chỉ cố định, mọi beat NONSEQ |
| Narrow transfers | ✅ | single → HSIZE từ WSTRB; burst → HSIZE từ AxSIZE |
| **1KB boundary crossing** | ✅ | tách thành burst INCR-undefined mới (NONSEQ restart) |
| **Bridge timeout** | ✅ | param `TIMEOUT`; hết giờ → SLVERR + IDLE |
| **HPROT mapping** | ✅ | từ AxPROT/AxCACHE theo Table 3-1 |
| Read ưu tiên Write | ✅ | arbiter ưu tiên read khi cùng lúc |
| Chỉ OKAY/SLVERR | ✅ | không EXOKAY/DECERR |
| Unaligned/Sparse | ✅ | không hỗ trợ → SLVERR (đúng spec) |
| Địa chỉ pass-through | ✅ | không modify |
| Data width 32/64 | ✅ | tham số hóa |
| HSEL / HREADY / HREADYOUT | ✅ | tách đúng 1 master ↔ 1 slave |
| **Out-of-order** | ✅ (mở rộng) | PG177 *không* hỗ trợ OoO; bản này **có** (theo yêu cầu) |

> Điểm khác PG177 có chủ đích: bridge này **mạnh hơn** — hỗ trợ nhiều giao dịch
> outstanding và hoàn tất out-of-order giữa các ID khác nhau (PG177 là in-order,
> single-outstanding). Trong cùng một ID vẫn in-order đúng chuẩn AXI4.

---

## 3. Tham số

| Tham số | Mặc định | Ý nghĩa |
|---------|----------|---------|
| `AXI_ADDR_WIDTH` | 32 | Độ rộng địa chỉ |
| `AXI_DATA_WIDTH` | 32 | Độ rộng dữ liệu (32 hoặc 64) |
| `AXI_ID_WIDTH`   | 4  | Độ rộng ID |
| `WR_OUTSTANDING` | 8  | Số lệnh ghi outstanding (pow2) |
| `RD_OUTSTANDING` | 8  | Số lệnh đọc outstanding (pow2) |
| `W_FIFO_DEPTH`   | 16 | Đệm write-data (pow2) |
| `R_FIFO_DEPTH`   | 16 | Đệm read-data streaming (pow2) |
| `NARROW_EN`      | 1  | Bật hỗ trợ narrow transfer |
| `TIMEOUT`        | 0  | Số clock chờ AHB trước khi SLVERR (0 = chờ vô hạn) |

---

## 4. Tín hiệu AHB-Lite (1 master ↔ 1 slave)

| Tín hiệu | Hướng | Ý nghĩa |
|---|---|---|
| `HSEL`      | out | Active khi `HTRANS != IDLE` |
| `HREADYOUT` | in  | Sẵn sàng từ slave |
| `HREADY`    | out | Vào master (= HREADYOUT cho 1 slave) |
| `HPROT`     | out | Map từ AxPROT/AxCACHE (mặc định 0011) |

Mở rộng nhiều slave: thêm decoder/mux ở giữa; bridge không cần sửa.

---

## 5. Chạy mô phỏng

Cần **Verilator ≥ 5.0**.
```bash
cd bridge
chmod +x run.sh
./run.sh all        # 4 bộ test
# hoặc từng bộ: ./run.sh basic | advanced | spec | timeout
```

Kết quả mong đợi (rút gọn):
```
==== ALL TESTS PASSED ====            (basic, 8)
==== ALL ADVANCED TESTS PASSED ====   (advanced, 8)
==== ALL SPEC-FEATURE TESTS PASSED == (spec, 11)
==== ALL TIMEOUT TESTS PASSED ====    (timeout, 3)
```

---

## 6. Kiến trúc

```
   AXI4 slave                                         AHB-Lite master
   ┌──────────────────────┐    wr_req/busy/grant    ┌──────────────┐
AW │ axi_write_engine      │───────────────────────►│              │
W ─┤  AW/W/B FIFO + FSM     │                         │ AHB arbiter  │ HSEL/HADDR
B ◄┤  WSTRB, narrow, 1KB,   │   HADDR/HSIZE/HBURST   │ (burst-lock, │ HTRANS/HSIZE
   │  timeout, HPROT        │◄──── HTRANS/HPROT ─────│  read-prio)  │ HBURST/HPROT
AR │ axi_read_engine       │                         │              │ HWDATA/HRDATA
   ┤  AR/R streaming FIFO    │───────────────────────►│              │ HREADY/HRESP
R ◄┤  backpressure,1KB,     │    rd_req/busy/grant   └──────────────┘
   │  timeout, HPROT        │
   └──────────────────────┘
```

- **Outstanding**: AW/AR FIFO đệm nhiều lệnh.
- **OoO across IDs**: arbiter xen kẽ phát read↔write; mỗi engine xử lý FIFO của
  nó in-order ⇒ same-ID in-order (đúng AXI4).
- **Pipeline AHB đúng chuẩn**: address phase beat N+1 chồng data phase beat N,
  không chèn IDLE giữa các beat; arbiter giữ grant cả burst.

---

## 7. Lịch sử các lỗi/tính năng đã xử lý

1–7. AW-W matching, WSTRB, bỏ global-ordering, OoO thật, burst-map, AxSIZE
legality, bỏ ROB 256-beat (streaming). 8. HSEL/HREADY/HREADYOUT.
9. FIXED → SINGLE/NONSEQ. 10–11. Pipeline timing + HWDATA alignment.
12. FIXED+narrow địa chỉ pass-through (không cộng strobe-offset).
13. WRAP2 → 2 single. 14. Narrow single → HSIZE từ WSTRB. 15. Read-priority.
16. 1KB boundary crossing. 17. Timeout module. 18. HPROT mapping.
