`ifndef AHB_ENV_PKG_INCLUDED_
`define AHB_ENV_PKG_INCLUDED_

package ahb_env_pkg;

    import uvm_pkg::*;
    import ahb_global_pkg::*;
    import ahb_base_pkg::*;
    import ahb_master_pkg::*;
    import ahb_slave_pkg::*;

    `include "uvm_macros.svh"
    `include "ahb_env_config.sv"
    `include "ahb_virtual_seqr.sv"
    `include "ahb_scoreboard.sv"
    `include "ahb_env.sv"

endpackage : ahb_env_pkg

`endif // AHB_ENV_PKG_INCLUDED_
