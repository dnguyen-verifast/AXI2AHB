`ifndef X2H_ENV_PKG_INCLUDED_
`define X2H_ENV_PKG_INCLUDED_

package x2h_env_pkg;
    import uvm_pkg::*;
    import ahb_env_pkg::*;
    import axi4_env_pkg::*;

    `include "uvm_macros.svh"
    
    `include "x2h_virtual_sequencer.sv"
    `include "x2h_scoreboard.sv"
    `include "x2h_env.sv"
endpackage : x2h_env_pkg

`endif
