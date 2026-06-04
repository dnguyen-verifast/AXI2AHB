`ifndef AHB_BASE_PKG_INCLUDED_
`define AHB_BASE_PKG_INCLUDED_

package ahb_base_pkg;

    import uvm_pkg::*;
    import ahb_global_pkg::*;
    `include "uvm_macros.svh"

    `include "ahb_base_tx.sv"

endpackage : ahb_base_pkg

`endif // AHB_BASE_PKG_INCLUDED_
