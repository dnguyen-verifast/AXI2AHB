# AXI4-to-AHB-Lite Bridge — SystemVerilog Implementation

## Thông số thiết kế

| Tham số          | Giá trị              |
|------------------|----------------------|
| Data width       | 32-bit               |
| Address width    | 32-bit               |
| AXI ID width     | 4-bit                |
| Outstanding      | Max 4 per ID         |
| Ordering         | In-order per ID      |
| Clock domain     | Parameterizable (CDC)|
| Exclusive access | Downgrade → normal   |
| AXI FIXED burst  | → nhiều SINGLE AHB   |
| AHB ERROR        | → AXI SLVERR         |

---

## Cấu trúc file

```
axi_ahb_bridge/
├── axi_ahb_bridge_pkg.sv     # Package: types, enums, functions
├── axi_ahb_bridge_top.sv     # Top-level: port map + FIFO instantiation
├── bridge_controller.sv      # Core FSM (AHB clock domain)
├── async_fifo.sv             # Async FIFO với Gray code (CDC mode)
├── sync_fifo.sv              # Sync FIFO (single-clock mode)
└── tb_axi_ahb_bridge.sv      # Testbench (10 test cases)
```

---

## Kiến trúc tổng quan

```
AXI Master
  │
  ├─ AW ─►[Async FIFO]─►┐
  ├─ W  ─►[Async FIFO]─►┤
  │                      ├─► Bridge Controller (AHB clk) ─►[AHB Slave]
  ├─ AR ─►[Async FIFO]─►┤        │ FSM
  │                      │        │ - Serializer
  ├─◄ B ─[Async FIFO]─◄─┤        │ - Burst Converter
  └─◄ R ─[Async FIFO]─◄─┘        │ - Write Aligner
                                   │ - Resp Mapper
                                   │ - Per-ID counter
```

---

## Nguyên tắc thiết kế

### Serialization
AXI cho phép multiple outstanding, AHB thì không. Bridge queue
các transaction theo từng ID, chỉ issue sang AHB một tại một thời điểm.

### Burst Conversion

| AXI burst | AXI len | AHB HBURST  |
|-----------|---------|-------------|
| INCR      | 0       | SINGLE      |
| INCR      | 3       | INCR4       |
| INCR      | 7       | INCR8       |
| INCR      | 15      | INCR16      |
| INCR      | other   | INCR        |
| WRAP      | 3       | WRAP4       |
| WRAP      | 7       | WRAP8       |
| WRAP      | 15      | WRAP16      |
| **FIXED** | any     | **SINGLE×N**|

### Write Alignment
AXI tách AW và W channel. Bridge phải giữ AHB addr phase cho đến
khi W FIFO có data. Nếu W FIFO rỗng → FSM vào S_WR_WAIT_DATA.

### AHB ERROR Handling
AHB ERROR cần 2 cycle (HREADY=0 + HRESP=1, rồi HREADY=1 + HRESP=1).
Bridge xử lý đúng cả 2 cycle rồi map sang SLVERR cho AXI.

### CDC (Async FIFO)
Khi `CDC_ENABLE=1`:
- Mỗi AXI channel có 1 Async FIFO riêng
- Write pointer (wclk) → Gray encode → 2-FF sync → rclk domain
- Read pointer (rclk) → Gray encode → 2-FF sync → wclk domain
- FULL check trong wclk, EMPTY check trong rclk

---

## Chạy Simulation

### Với Verilator
```bash
verilator --sv --binary -top tb_axi_ahb_bridge \
    axi_ahb_bridge_pkg.sv \
    async_fifo.sv sync_fifo.sv \
    bridge_controller.sv \
    axi_ahb_bridge_top.sv \
    tb_axi_ahb_bridge.sv \
    -o sim_bridge && ./sim_bridge
```

### Với Icarus Verilog (iverilog)
```bash
iverilog -g2012 -o sim_bridge \
    axi_ahb_bridge_pkg.sv \
    async_fifo.sv sync_fifo.sv \
    bridge_controller.sv \
    axi_ahb_bridge_top.sv \
    tb_axi_ahb_bridge.sv \
    && vvp sim_bridge
```

### Với QuestaSim / ModelSim
```tcl
vlib work
vlog -sv axi_ahb_bridge_pkg.sv async_fifo.sv sync_fifo.sv \
         bridge_controller.sv axi_ahb_bridge_top.sv tb_axi_ahb_bridge.sv
vsim tb_axi_ahb_bridge -do "run -all"
```

---

## Test Cases

| TC  | Mô tả                                  | Check               |
|-----|----------------------------------------|---------------------|
| TC1 | Single write + single read (INCR, 1bt) | BRESP=OKAY          |
| TC2 | INCR4 burst write (len=3)              | BRESP=OKAY          |
| TC3 | INCR8 burst read  (len=7)              | 8 R beats           |
| TC4 | WRAP4 write (len=3)                    | Địa chỉ wrap đúng   |
| TC5 | FIXED burst write → 4 SINGLE          | 4 AHB SINGLE beats  |
| TC6 | AHB ERROR on write                     | BRESP=SLVERR        |
| TC7 | AHB ERROR on read                      | RRESP=SLVERR        |
| TC8 | Multi-ID concurrent write (ID=0,1)     | In-order per ID     |
| TC9 | Wait states (2 cycle per beat)         | BRESP=OKAY          |
| TC10| Back-to-back read+write mix            | Cả 2 hoàn thành     |

---

## Các điểm cần lưu ý khi tích hợp

1. **Reset**: `axi_rstn` và `ahb_rstn` phải assert async, deassert sync
   trong domain tương ứng. Đừng dùng chung 1 reset cho cả 2 domain.

2. **FIFO depth**: Nên chọn `FIFO_DEPTH` ≥ burst_length_max + 2×CDC_latency.
   Với CDC_ENABLE=1, tối thiểu nên là 8.

3. **Synthesis CDC constraints**: Thêm vào SDC:
   ```tcl
   set_false_path -from [get_clocks axi_clk] -to [get_clocks ahb_clk]
   set_false_path -from [get_clocks ahb_clk] -to [get_clocks axi_clk]
   ```

4. **AHB Lite vs Full AHB**: Bridge này implement AHB-Lite master
   (không có split/retry, không có multi-master arbitration).

5. **Exclusive access**: Downgrade về normal, không trả EXOKAY.
   Nếu cần exclusive, phải thêm hardware lock register riêng.
