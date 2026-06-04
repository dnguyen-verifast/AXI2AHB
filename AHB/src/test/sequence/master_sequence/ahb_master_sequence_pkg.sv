`ifndef AHB_MASTER_SEQUENCE_PKG_INCLUDED_
`define AHB_MASTER_SEQUENCE_PKG_INCLUDED_

package ahb_master_sequence_pkg;

    import uvm_pkg::*;
    import ahb_global_pkg::*;
    import ahb_base_pkg::*;
    import ahb_master_pkg::*;

    `include "uvm_macros.svh"

    `include "ahb_master_base_seq.sv"
    `include "ahb_master_basic_single_w_seq.sv"
    `include "ahb_master_basic_single_r_seq.sv"
    `include "ahb_master_basic_single_burst_seq.sv"
    `include "ahb_master_hsize_byte_strb_seq.sv"
    `include "ahb_master_hsize_halfword_strb_seq.sv"
    `include "ahb_master_idle_transfer_seq.sv"
    `include "ahb_master_incr_burst_seq.sv"
    `include "ahb_master_undefine_length_incr_seq.sv"
    `include "ahb_master_rand_burst_size_wr_seq.sv"
    `include "ahb_master_wrap_burst_seq.sv"
    `include "ahb_master_busy_burst_seq.sv"
    `include "ahb_master_1kb_boundary_violation_seq.sv"
    `include "ahb_master_random_wait_state_seq.sv"
    `include "ahb_master_manager_signal_stability_seq.sv"
    `include "ahb_master_error_response_seq.sv"
    `include "ahb_master_locked_sequence_seq.sv"
    `include "ahb_master_write_strobe_sparse_seq.sv"
    `include "ahb_master_exclusive_access_seq.sv"
    `include "ahb_master_parity_error_injection_seq.sv"
    `include "ahb_master_convert_trans_waitstate_seq.sv"

endpackage : ahb_master_sequence_pkg

`endif // AHB_MASTER_SEQUENCE_PKG_INCLUDED_
