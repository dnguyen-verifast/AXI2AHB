`ifndef AHB_TOP_INCLUDED_
`define AHB_TOP_INCLUDED_

//--------------------------------------------------------------------------------------------
// Module      : HDL Top
// Description : Has a interface master and slave agent bfm.
//--------------------------------------------------------------------------------------------

module ahb_top;

  import uvm_pkg::*;
  import ahb_global_pkg::*;
  import ahb_testcase_pkg::*;
  `include "uvm_macros.svh"

  //-------------------------------------------------------
  // Clock Reset Initialization
  //-------------------------------------------------------
  bit clk;
  bit resetn;

  //-------------------------------------------------------
  // Display statement for HDL_TOP
  //-------------------------------------------------------
  initial begin
    $display("AHB_TOP");
  end

  //-------------------------------------------------------
  // System Clock Generation
  //-------------------------------------------------------
  initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
  end

  //-------------------------------------------------------
  // System Reset Generation
  // Active low reset
  //-------------------------------------------------------
  initial begin
    resetn = 1'b1;
    #20 resetn = 1'b0;

    repeat (1) begin
      @(posedge clk);
    end
    resetn = 1'b1;
  end

  // Variable : intf
  // axi4 Interface Instantiation
  ahb_if ahb_if(.clk(clk),
               .resetn(resetn));

    initial begin : START_TEST
        uvm_config_db#(virtual ahb_if)::set(null, "uvm_test_top.*", "ahb_if", ahb_if);
        run_test("ahb_basic_single_rw_test");
    end
endmodule : ahb_top
`endif

