`ifndef AHB_SLAVE_PKG_INCLUDED_
`define AHB_SLAVE_PKG_INCLUDED_

package ahb_slave_pkg;

    import uvm_pkg::*;
    import ahb_global_pkg::*;
    import ahb_base_pkg::*;

    `include "uvm_macros.svh"
    `include "ahb_slave_memory.sv"
    `include "ahb_slave_tx.sv"
    `include "ahb_slave_config.sv"
    `include "ahb_slave_seq_item_converter.sv"
    `include "ahb_slave_sequencer.sv"
    `include "ahb_slave_driver.sv"
    `include "ahb_slave_monitor.sv"
    `include "ahb_slave_coverage.sv"
    `include "ahb_slave_agent.sv"

endpackage : ahb_slave_pkg

`endif // AHB_SLAVE_PKG_INCLUDED_
