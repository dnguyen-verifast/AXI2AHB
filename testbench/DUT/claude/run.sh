#!/usr/bin/env bash
#============================================================================
# run.sh -- build & run the bridge simulations with Verilator.
# Usage:  ./run.sh basic      # basic functional suite
#         ./run.sh advanced   # targeted suite (WSTRB, AxSIZE, burst-map, ...)
#         ./run.sh all        # both
#============================================================================
set -e

RTL="rtl/axi_ahb_pkg.sv rtl/sync_fifo.sv rtl/axi_write_engine.sv \
     rtl/axi_read_engine.sv rtl/axi4_to_ahb_lite.sv rtl/ahb_lite_slave_mem.sv"

VFLAGS="--binary --timing --timescale 1ns/1ps -Wno-fatal"

run_one () {
  local TOP=$1; local TB=$2; local OUT=$3
  echo "=== Building $TOP ==="
  verilator $VFLAGS --top-module $TOP $RTL $TB -o $OUT
  echo "=== Running $TOP ==="
  ./obj_dir/$OUT
}

case "${1:-all}" in
  basic)    run_one tb_axi4_to_ahb_lite tb/tb_axi4_to_ahb_lite.sv sim_basic ;;
  advanced) run_one tb_bridge_advanced  tb/tb_bridge_advanced.sv  sim_adv   ;;
  all)
    run_one tb_axi4_to_ahb_lite tb/tb_axi4_to_ahb_lite.sv sim_basic
    run_one tb_bridge_advanced  tb/tb_bridge_advanced.sv  sim_adv
    ;;
  *) echo "usage: $0 {basic|advanced|all}"; exit 1 ;;
esac
