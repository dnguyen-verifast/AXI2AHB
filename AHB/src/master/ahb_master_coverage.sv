`ifndef AHB_MASTER_COVERAGE_INCLUDED_
`define AHB_MASTER_COVERAGE_INCLUDED_
class ahb_master_coverage extends uvm_subscriber #(ahb_master_tx);
    `uvm_component_utils(ahb_master_coverage)

    covergroup ahb_master_covergroup with function sample(ahb_master_tx packet);
        option.per_instance =1;

        HBURST_CP : coverpoint   packet.hburst {
            bins b_SINGLE = {SINGLE};
            bins b_INCR   = {INCR};
            bins b_WRAP4  = {WRAP4};
            bins b_INCR4  = {INCR4};
            bins b_WRAP8  = {WRAP8};
            bins b_INCR8  = {INCR8};
            bins b_WRAP16 = {WRAP16};
            bins b_INCR16 = {INCR16};
        }

        HSIZE_CP : coverpoint packet.hsize {
            bins b_HSIZE_BYTE   = {HSIZE_BYTE};
            bins b_HSIZE_HWORD  = {HSIZE_HWORD};
            bins b_HSIZE_WORD   = {HSIZE_WORD};
            // bins b_HSIZE_DWORD  = {HSIZE_DWORD};
            // bins b_HSIZE_LINE4  = {HSIZE_LINE4};
            // bins b_HSIZE_LINE8  = {HSIZE_LINE8};
            // bins b_HSIZE_LINE16 = {HSIZE_LINE16};
            // bins b_HSIZE_LINE32 = {HSIZE_LINE32};
        }

        HTRANS_CP : coverpoint packet.htrans {
            bins IDLE   = {2'b00};
            bins BUSY   = {2'b01};
            bins NONSEQ = {2'b10};
            bins SEQ    = {2'b11};
        }

        HMASTLOCK_CP : coverpoint packet.hmastlock {
            bins unlocked = {0};
            bins locked   = {1};
        }

        HWRITE_CP : coverpoint packet.hwrite {
            bins READ  = {0};
            bins WRITE = {1};
        }

        HREADYOUT_CP : coverpoint packet.hreadyout {
            bins not_ready = {0};
            bins ready     = {1};
        }

        HRESP_CP : coverpoint packet.hresp {
            bins OKAY  = {0};
            bins ERROR = {1};
        }

        HBURST_CP_x_HSIZE_CP : cross HBURST_CP, HSIZE_CP;
        HTRANS_CP_x_HWRITE_CP : cross HTRANS_CP, HWRITE_CP;
        HBURST_CP_x_HWRITE_CP : cross HBURST_CP, HWRITE_CP;
        HRESP_CP_x_HWRITE_CP : cross HWRITE_CP, HRESP_CP;
        HTRANS_CP_x_HREADYOUT_CP : cross  HTRANS_CP, HREADYOUT_CP;

        // HADDR_CP : coverpoint packet.haddr {
        //     bins all_zeros = {0};
        //     // bins low_range = {[1 : 32'h0000_FFFF]};
        //     // bins mid_range = {[32'h0001_0000 : 32'hFFFF_FFFE]};
        //     bins all_ones  = {'1};
        //     bins others    = default;
        // }

        // HRDATA_CP : coverpoint packet.hrdata {
        //     bins all_zeros = {0};
        //     bins all_ones  = {'1};
        //     bins others    = default;
        // }

        // HWDTA_CP : coverpoint packet.hwdata {
        //     bins all_zeros = {0};
        //     bins all_ones  = {'1};
        //     bins others    = default;
        // }

        // HEXOKAY_CP : coverpoint packet.hexokay {
        //     bins FAIL    = {0};
        //     bins SUCCESS = {1};
        // }

        // HSEL_CP : coverpoint packet.hsel {
        //     bins not_selected = {0};
        //     bins selected     = {1};
        // }

        // HEXCL_CP : coverpoint packet.hexcl {
        //     bins normal    = {0};
        //     bins exclusive = {1};
        // }

        // HWSTRB_CP : coverpoint packet.hwstrb {
        //     bins all_zeros = {0};
        //     bins all_ones  = {'1};
        //     bins mixed     = default;
        // }
        //coverpoint hprot;
        //coverpoint hmaster;
        
        // HNONSEC_CP : coverpoint packet.hnonsec {
        //     bins secure     = {0};
        //     bins non_secure = {1};
        // }
    endgroup : ahb_master_covergroup
extern function new(string name = "ahb_master_coverage", uvm_component parent=null);
extern virtual function void write(ahb_master_tx t);
extern virtual function void report_phase(uvm_phase phase);
endclass : ahb_master_coverage 

function ahb_master_coverage::new(string name = "ahb_master_coverage", uvm_component parent=null);
    super.new(name, parent);
    ahb_master_covergroup =new();
endfunction : new

function void ahb_master_coverage::write(ahb_master_tx t);
 `uvm_info(get_type_name(),$sformatf("Before calling SAMPLE METHOD"),UVM_HIGH);
  ahb_master_covergroup.sample(t);
  `uvm_info(get_type_name(),"After calling SAMPLE METHOD",UVM_HIGH);
endfunction: write

function void ahb_master_coverage::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(),$sformatf("AHB Master Agent Coverage = %0.2f %%", ahb_master_covergroup.get_coverage()), UVM_NONE);
endfunction: report_phase

`endif