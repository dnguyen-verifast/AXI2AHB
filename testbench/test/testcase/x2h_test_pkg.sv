`ifndef x2h_TEST_PKG_INCLUDED_
`define x2h_TEST_PKG_INCLUDED_

//-----------------------------------------------------------------------------------------
// Package: Test
// Description:
// Includes all the files written to run the simulation
//--------------------------------------------------------------------------------------------
package x2h_test_pkg;

  //-------------------------------------------------------
  // Import uvm package
  //-------------------------------------------------------
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import axi4_globals_pkg::*;
  import ahb_global_pkg::*;
  import axi4_master_pkg::*;
  import axi4_slave_pkg::*;
  import ahb_master_pkg::*;
  import ahb_slave_pkg::*;
  import axi4_env_pkg::*;
  import ahb_env_pkg::*;
  import x2h_env_pkg::*;
  import x2h_virtual_seq_pkg::*;

  //import fifo_bfm_test_pkg::*;
  //import fifo_bfm_seq_pkg::*;

  //including base_test for testing
  `include "x2h_base_test.sv"
  // `include "x2h_write_test.sv"
  // `include "x2h_read_test.sv"
  // `include "x2h_write_read_test.sv"
  `include "x2h_blocking_8b_write_data_test.sv"
  `include "x2h_blocking_16b_write_data_test.sv"
  `include "x2h_blocking_32b_write_data_test.sv"
  `include "x2h_blocking_okay_response_write_test.sv"
  `include "x2h_blocking_incr_burst_write_test.sv"
  `include "x2h_blocking_wrap_burst_write_test.sv"
  `include "x2h_blocking_8b_write_read_test.sv"
  `include "x2h_blocking_16b_write_read_test.sv"
  `include "x2h_blocking_32b_write_read_test.sv"
  `include "x2h_blocking_okay_response_write_read_test.sv"
  `include "x2h_blocking_slave_error_write_read_test.sv"
  `include "x2h_blocking_unaligned_addr_write_read_test.sv"
  `include "x2h_blocking_fixed_burst_write_read_test.sv"
  `include "x2h_blocking_outstanding_transfer_write_read_test.sv"
  `include "x2h_blocking_cross_write_read_test.sv"
  `include "x2h_blocking_incr_burst_read_test.sv"
  `include "x2h_blocking_wrap_burst_read_test.sv"
  `include "x2h_blocking_8b_data_read_test.sv"
  `include "x2h_blocking_16b_data_read_test.sv"
  `include "x2h_blocking_32b_data_read_test.sv"
  `include "x2h_blocking_okay_response_read_test.sv"
  `include "x2h_blocking_write_read_test.sv"
  `include "x2h_blocking_wrap_burst_write_read_test.sv"
  `include "x2h_blocking_incr_burst_write_read_test.sv"
  `include "x2h_blocking_1kb_cross_incr_read_test.sv"
  `include "x2h_blocking_1kb_cross_incr_write_test.sv"
  `include "x2h_blocking_read_timeout_test.sv"
  `include "x2h_blocking_write_timeout_test.sv"
  `include "x2h_blocking_read_write_priority_test.sv"
  `include "x2h_blocking_hprot_instruction_bufferable_test.sv"
  `include "x2h_blocking_reset_test.sv"
  `include "x2h_blocking_back_to_back_write_read_test.sv"
  `include "x2h_blocking_hprot_privileged_data_test.sv"
  
  // `include "x2h_non_blocking_8b_write_data_test.sv"
  // `include "x2h_non_blocking_16b_write_data_test.sv"
  // `include "x2h_non_blocking_32b_write_data_test.sv"
  // `include "x2h_non_blocking_64b_write_data_test.sv"
  // `include "x2h_non_blocking_exokay_response_write_test.sv"
  // `include "x2h_non_blocking_okay_response_write_test.sv"
  // `include "x2h_non_blocking_incr_burst_write_test.sv"
  // `include "x2h_non_blocking_wrap_burst_write_test.sv"
  // `include "x2h_non_blocking_write_read_test.sv"
  // `include "x2h_non_blocking_incr_burst_read_test.sv"
  // `include "x2h_non_blocking_wrap_burst_read_test.sv"
  // `include "x2h_non_blocking_8b_data_read_test.sv"
  // `include "x2h_non_blocking_16b_data_read_test.sv"
  // `include "x2h_non_blocking_32b_data_read_test.sv"
  // `include "x2h_non_blocking_64b_data_read_test.sv"
  // `include "x2h_non_blocking_okay_response_read_test.sv"
  // `include "x2h_non_blocking_exokay_response_read_test.sv"
  
  
  // `include "x2h_non_blocking_8b_write_read_test.sv"
  // `include "x2h_non_blocking_16b_write_read_test.sv"
  // `include "x2h_non_blocking_32b_write_read_test.sv"
  // `include "x2h_non_blocking_64b_write_read_test.sv"
  // `include "x2h_non_blocking_incr_burst_write_read_test.sv"
  // `include "x2h_non_blocking_wrap_burst_write_read_test.sv"
  // `include "x2h_non_blocking_okay_response_write_read_test.sv"
  // `include "x2h_non_blocking_fixed_burst_write_read_test.sv"
  // `include "x2h_non_blocking_outstanding_transfer_write_read_test.sv"
  // `include "x2h_non_blocking_unaligned_addr_write_read_test.sv"
  // `include "x2h_non_blocking_cross_write_read_test.sv"
  // `include "x2h_non_blocking_slave_error_write_read_test.sv"

  // `include "x2h_non_blocking_write_read_rand_test.sv"
  // `include "x2h_blocking_write_read_rand_test.sv"


  //`include "fifo_bfm_base_test.sv"
  //`include "fifo_bfm_wr_rd_test.sv"
endpackage : x2h_test_pkg

`endif
