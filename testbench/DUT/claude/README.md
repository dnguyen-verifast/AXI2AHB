# AXI4 → AHB-Lite Bridge (v2)

Cầu chuyển đổi **AXI4 (slave) → AHB-Lite (master)** viết bằng SystemVerilog,
**đã sửa toàn bộ 7 lỗi** của bản trước, **tách thành nhiều file** cho dễ đọc,
và **đã kiểm chứng bằng 2 bộ testbench** (chạy Verilator, tất cả PASS).

---

## 1. Cấu trúc thư mục (đã tách file)

```
bridge/
├── rtl/
│   ├── axi_ahb_pkg.sv        # Hằng số, hàm dùng chung (burst map, addr-gen, size-legal)
│   ├── sync_fifo.sv          # FIFO đồng bộ tham số hóa (dùng lại nhiều nơi)
│   ├── axi_write_engine.sv   # Đường GHI: AW/W/B, AW-W matching, WSTRB, AWSIZE
│   ├── axi_read_engine.sv    # Đường ĐỌC: AR/R, streaming FIFO + backpressure
│   ├── axi4_to_ahb_lite.sv   # TOP: ghép 2 engine + AHB arbiter (nơi tạo OoO thật)
│   └── ahb_lite_slave_mem.sv # Mô hình AHB slave (honor HSIZE byte-lane) cho sim
├── tb/
│   ├── tb_axi4_to_ahb_lite.sv# Bộ test cơ bản
│   └── tb_bridge_advanced.sv # Bộ test nhắm đúng 7 lỗi đã sửa
├── run.sh                    # Script build & chạy
└── README.md
```

Đọc theo thứ tự: `axi_ahb_pkg` → `sync_fifo` → `axi_write_engine` /
`axi_read_engine` → `axi4_to_ahb_lite`.

---

## 2. Bảng các lỗi đã sửa

| # | Lỗi bản cũ | Cách chữa ở bản v2 | Test xác minh |
|---|------------|--------------------|---------------|
| 1 | **AW-W matching sai** | AXI4 cấm write-data interleaving → W beat đi theo đúng thứ tự AW. `axi_write_engine` dùng 1 AW-FIFO + 1 W-FIFO, pop 1 AW rồi tiêu thụ đúng `len+1` beat W. Không giả định/đảo interleave. | `E AW-W match *` |
| 2 | **WSTRB không xử lý** | AHB-Lite không có HWSTRB. Engine giải mã WSTRB → kiểm tra **liền kề & đúng size**; sinh `HSIZE`+offset `HADDR` để slave ghi đúng byte-lane. Strobe không hợp lệ (rời rạc) → SLVERR. | `A WSTRB sub-word` |
| 3 | **Ép global ordering** (`seq` toàn cục) | Bỏ hoàn toàn `seq` toàn cục. Thứ tự chỉ ràng buộc **trong cùng ID** một cách tự nhiên do mỗi engine xử lý FIFO theo thứ tự. | `F same-ID in-order` |
| 4 | **OoO không thật** (chỉ ROB chọn lại) | OoO thật nằm ở **AHB arbiter**: nó xen kẽ phát read/write lên bus đơn AHB. Hai giao dịch khác ID có thể hoàn tất theo thứ tự bất kỳ; mỗi ID vẫn in-order. | arbiter + `T3` |
| 5 | **Burst chỉ giả lập** (tất cả thành SINGLE) | `map_hburst()` ánh xạ đúng: len0→SINGLE, 4→INCR4, 8→INCR8, 16→INCR16, WRAP4/8/16; còn lại→INCR (undefined-length). Per-beat HTRANS NONSEQ→SEQ. | `D HBURST INCR4 map` |
| 6 | **AWSIZE legality bỏ qua** | `size_legal()` kiểm tra `AxSIZE ≤ log2(bus_bytes)`. Vi phạm → SLVERR, **không** đụng tới AHB. Áp dụng cho cả đọc và ghi. | `B`, `C` |
| 7 | **Read ROB rất nặng** (256 beat/slot) | Bỏ hẳn. Dùng **1 R-data FIFO nhỏ có giới hạn**, streaming từng beat ra kênh R; khi FIFO gần đầy thì **backpressure** dừng phát AHB (HTRANS=IDLE). | toàn bộ test đọc |

---

## 3. Kiến trúc

```
   AXI4 slave                                        AHB-Lite master
   ┌───────────────────────────────────────────────────────────────┐
   │                                                                 │
AW │   ┌──────────────────────┐                                     │
W ─┼──►│  axi_write_engine     │──┐                                  │
B ◄┼───│  (AW-FIFO + W-FIFO    │  │   wr_req/grant                   │
   │   │   + B-FIFO, FSM)      │  │   ┌──────────────┐  HADDR/HTRANS │
   │   └──────────────────────┘  ├──►│ AHB arbiter  │──► HSIZE/...   ├──► AHB slave
AR │   ┌──────────────────────┐  │   │ (round-robin)│  HWDATA/HRDATA │
   ├──►│  axi_read_engine      │──┘   └──────────────┘  HREADY/HRESP │
R ◄┼───│  (AR-FIFO + R-FIFO    │      rd_req/grant                   │
   │   │   streaming, FSM)     │                                     │
   │   └──────────────────────┘                                     │
   └───────────────────────────────────────────────────────────────┘
```

- **Outstanding**: AW-FIFO / AR-FIFO đệm nhiều lệnh → master không bị chặn.
- **Out-of-order across IDs**: arbiter xen kẽ phát read↔write lên bus AHB đơn;
  vì AHB-Lite tuần tự, OoO chỉ thật khi ta được phép **đảo thứ tự phát** — và
  đó chính là việc arbiter làm.
- **In-order per-ID**: mỗi engine xử lý FIFO của nó theo thứ tự nên response của
  cùng một ID luôn đúng trình tự (đúng yêu cầu AXI4).

---

## 4. Tham số

| Tham số | Mặc định | Ý nghĩa |
|---------|----------|---------|
| `AXI_ADDR_WIDTH` | 32 | Độ rộng địa chỉ |
| `AXI_DATA_WIDTH` | 32 | Độ rộng dữ liệu (bus 4 byte) |
| `AXI_ID_WIDTH`   | 4  | Độ rộng ID |
| `WR_OUTSTANDING` | 8  | Số lệnh ghi outstanding (AW-FIFO, **pow2**) |
| `RD_OUTSTANDING` | 8  | Số lệnh đọc outstanding (AR-FIFO, **pow2**) |
| `W_FIFO_DEPTH`   | 16 | Độ sâu đệm write-data (**pow2**) |
| `R_FIFO_DEPTH`   | 16 | Độ sâu đệm read-data streaming (**pow2**) |

> Lưu ý: các FIFO yêu cầu độ sâu là lũy thừa của 2.

---

## 5. Chạy mô phỏng

Cần **Verilator ≥ 5.0**.

```bash
cd bridge
chmod +x run.sh
./run.sh all          # chạy cả 2 bộ test
# hoặc
./run.sh basic
./run.sh advanced
```

Kết quả mong đợi (rút gọn):

```
[PASS] T1 single rw ... [PASS] T3 id5 data
==== ALL TESTS PASSED ====

[PASS] A WSTRB sub-word
[PASS] B AWSIZE illegal SLVERR
[PASS] C ARSIZE illegal SLVERR
[PASS] D HBURST INCR4 map
[PASS] E AW-W match wr2 b0/b1, wr3 b0
[PASS] F same-ID in-order
==== ALL ADVANCED TESTS PASSED ====
```

Với simulator thương mại (Questa):
```bash
vlog -sv rtl/*.sv tb/tb_bridge_advanced.sv
vsim -c tb_bridge_advanced -do "run -all; quit"
```

---

## 6. Các test

**Cơ bản** (`tb_axi4_to_ahb_lite.sv`): ghi/đọc đơn, burst 4-beat, 3 đọc
outstanding khác ID.

**Nâng cao** (`tb_bridge_advanced.sv`) — nhắm đúng 7 lỗi:
- **A** WSTRB ghi 1 byte vào đúng lane, các byte khác không đổi.
- **B** AWSIZE=3 (8B > bus 4B) → BRESP = SLVERR, AHB không bị ghi.
- **C** ARSIZE=3 → mọi beat R trả SLVERR.
- **D** Burst 4-beat INCR → HBURST = INCR4 (011), HTRANS NONSEQ→SEQ.
- **E** Hai write back-to-back khác ID → dữ liệu vào đúng địa chỉ (AW-W match).
- **F** Hai read cùng ID outstanding → R trả về đúng thứ tự phát.

---

## 7. Giới hạn còn lại / hướng mở rộng

- Arbiter cấp **một beat mỗi lần** rồi tái phân xử → đơn giản, luôn hợp lệ
  protocol, nhưng chưa tối ưu throughput. Có thể nâng cấp cấp **cả burst** cho
  một engine để giảm overhead chuyển bus.
- WSTRB chỉ hỗ trợ strobe **liền kề, đúng size** (đủ cho mọi giao dịch AXI hợp
  lệ size-aligned). Strobe rời rạc trả SLVERR (AHB-Lite vốn không biểu diễn được).
- Chưa cài AXI `LOCK/CACHE/QOS/REGION/PROT` đầy đủ; dễ thêm vào struct lệnh.
- Mô hình slave là **zero wait-state**; muốn stress backpressure thì thêm
  HREADY ngẫu nhiên — read engine đã sẵn sàng nhờ cơ chế FIFO + backpressure.
- Có thể bổ sung **SVA assertions** cho luật AXI/AHB để verify mạnh hơn.


Giai đoạn 1 — FIXED burst sai HBURST/HTRANS
#LỗiBản chấtCách sửa9FIXED → HBURST=INCR + HTRANS NONSEQ→SEQFIXED bị gộp chung nhánh với INCR, báo địa chỉ tăng dần và liên tiếp (sai ngữ nghĩa)map_hburst: FIXED → SINGLE riêng; HTRANS: FIXED luôn NONSEQ
Giai đoạn 2 — Timing pipeline sai
#LỗiBản chấtCách sửa10Chèn HTRANS=IDLE giữa các beatFSM tách ADDR/DATA thành 2 state (2 cycle/beat) + arbiter quay về IDLE → data phase kéo dài gấp đôi, monitor bắt trùng data beat đầuArbiter đổi sang grant-lock cả burst (qua wr_busy/rd_busy); FSM gộp thành pipeline đúng AHB (address N+1 chồng data N)11HWDATA trễ 1 cycle (phát hiện khi trace lỗi 10)wd_pop registered làm FIFO head cập nhật trễ → HWDATA lệch beatĐổi wd_pop thành tổ hợp; hwdata_q giữ đúng data của beat trong data phase
Giai đoạn 3 — FIXED + sub-bus size sai địa chỉ
#LỗiBản chấtCách sửa12Địa chỉ FIXED nhảy lung tung (0x19E → 0x1A0 → 0x19E)wr_haddr = cur_addr + strb_off — cộng offset suy từ WSTRB vào địa chỉ là sai thiết kếwr_haddr = cur_addr (lấy thẳng địa chỉ AXI); thay strb_decode bằng strb_legal_for chỉ để kiểm tra strobe khớp offset địa chỉ, không sinh offset