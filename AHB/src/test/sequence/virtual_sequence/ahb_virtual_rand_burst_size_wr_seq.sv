`ifndef AHB_VIRTUAL_RAND_BURST_SIZE_WR_SEQ_INCLUDE_
`define AHB_VIRTUAL_RAND_BURST_SIZE_WR_SEQ_INCLUDE_

class ahb_virtual_rand_burst_size_wr_seq extends ahb_virtual_base_seq;
    `uvm_object_utils(ahb_virtual_rand_burst_size_wr_seq)
    ahb_master_rand_burst_size_wr_seq ahb_master_rand_burst_size_wr_seq_h;
    ahb_slave_rand_burst_size_wr_seq ahb_slave_rand_burst_size_wr_seq_h;

    extern function new(string name = "ahb_virtual_rand_burst_size_wr_seq");
    extern virtual task body();
endclass : ahb_virtual_rand_burst_size_wr_seq

function ahb_virtual_rand_burst_size_wr_seq::new(string name = "ahb_virtual_rand_burst_size_wr_seq");
    super.new(name);
endfunction : new

task ahb_virtual_rand_burst_size_wr_seq::body();
    ahb_master_rand_burst_size_wr_seq_h = ahb_master_rand_burst_size_wr_seq::type_id::create("ahb_master_rand_burst_size_wr_seq_h");
    ahb_slave_rand_burst_size_wr_seq_h = ahb_slave_rand_burst_size_wr_seq::type_id::create("ahb_slave_rand_burst_size_wr_seq_h");

    `uvm_info(get_type_name(), $sformatf("Starting %s", get_type_name()), UVM_LOW);

    fork
        begin : T1_SL_RD
        forever begin
            ahb_slave_rand_burst_size_wr_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
        end
        end
    join_none

    fork
        begin: T1_MST_WR
        repeat(1) begin
            ahb_master_rand_burst_size_wr_seq_h.start(p_sequencer.ahb_master_sequencer_h);
        end
        end
    join
endtask : body

`endif
