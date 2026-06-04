`ifndef AHB_VIRTUAL_SEQUENCE_PKG_INCLUDED_
`define AHB_VIRTUAL_SEQUENCE_PKG_INCLUDED_

package ahb_virtual_sequence_pkg;

    import uvm_pkg::*;
    import ahb_global_pkg::*;
    import ahb_base_pkg::*;
    import ahb_master_sequence_pkg::*;
    import ahb_slave_sequence_pkg::*;
    import ahb_env_pkg::*;

    `include "uvm_macros.svh"

    `include "ahb_virtual_base_seq.sv"
    `include "ahb_virtual_basic_single_w_seq.sv"
    `include "ahb_virtual_basic_single_r_seq.sv"
    `include "ahb_virtual_basic_single_burst_seq.sv"
    `include "ahb_virtual_hsize_byte_strb_seq.sv"
    `include "ahb_virtual_hsize_halfword_strb_seq.sv"
    `include "ahb_virtual_idle_transfer_seq.sv"
    `include "ahb_virtual_incr_burst_seq.sv"
    `include "ahb_virtual_undefine_length_incr_seq.sv"
    `include "ahb_virtual_rand_burst_size_wr_seq.sv"
    `include "ahb_virtual_wrap_burst_seq.sv"
    `include "ahb_virtual_busy_burst_seq.sv"
    `include "ahb_virtual_1kb_boundary_violation_seq.sv"
    `include "ahb_virtual_random_wait_state_seq.sv"
    `include "ahb_virtual_manager_signal_stability_seq.sv"
    `include "ahb_virtual_error_response_seq.sv"
    `include "ahb_virtual_locked_sequence_seq.sv"
    `include "ahb_virtual_write_strobe_sparse_seq.sv"
    `include "ahb_virtual_exclusive_access_seq.sv"
    `include "ahb_virtual_parity_error_injection_seq.sv"
    `include "ahb_virtual_convert_trans_waitstate_seq.sv"

endpackage : ahb_virtual_sequence_pkg

`endif // AHB_VIRTUAL_SEQUENCE_PKG_INCLUDED_
