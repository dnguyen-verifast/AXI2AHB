`ifndef AHB_SLAVE_SEQUENCE_PKG_INCLUDED_
`define AHB_SLAVE_SEQUENCE_PKG_INCLUDED_

package ahb_slave_sequence_pkg;

    import uvm_pkg::*;
    import ahb_global_pkg::*;
    import ahb_base_pkg::*;
    import ahb_slave_pkg::*;

    `include "uvm_macros.svh"

    `include "ahb_slave_base_seq.sv"
    `include "ahb_slave_basic_single_w_seq.sv"
    `include "ahb_slave_basic_single_r_seq.sv"
    `include "ahb_slave_basic_single_burst_seq.sv"
    `include "ahb_slave_hsize_byte_strb_seq.sv"
    `include "ahb_slave_hsize_halfword_strb_seq.sv"
    `include "ahb_slave_idle_transfer_seq.sv"
    `include "ahb_slave_incr_burst_seq.sv"
    `include "ahb_slave_undefine_length_incr_seq.sv"
    `include "ahb_slave_rand_burst_size_wr_seq.sv"
    `include "ahb_slave_wrap_burst_seq.sv"
    `include "ahb_slave_busy_burst_seq.sv"
    `include "ahb_slave_1kb_boundary_violation_seq.sv"
    `include "ahb_slave_random_wait_state_seq.sv"
    `include "ahb_slave_manager_signal_stability_seq.sv"
    `include "ahb_slave_error_response_seq.sv"
    `include "ahb_slave_locked_sequence_seq.sv"
    `include "ahb_slave_write_strobe_sparse_seq.sv"
    `include "ahb_slave_exclusive_access_seq.sv"
    `include "ahb_slave_parity_error_injection_seq.sv"
    `include "ahb_slave_convert_trans_waitstate_seq.sv"

endpackage : ahb_slave_sequence_pkg

`endif // AHB_SLAVE_SEQUENCE_PKG_INCLUDED_
