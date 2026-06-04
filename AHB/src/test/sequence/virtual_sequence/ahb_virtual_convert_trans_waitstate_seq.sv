`ifndef AHB_VIRTUAL_CONVERT_TRANS_WAITSTATE_SEQ_INCLUDE_
`define AHB_VIRTUAL_CONVERT_TRANS_WAITSTATE_SEQ_INCLUDE_

class ahb_virtual_convert_trans_waitstate_seq extends ahb_virtual_base_seq;
    `uvm_object_utils(ahb_virtual_convert_trans_waitstate_seq)
    
    ahb_master_convert_trans_waitstate_seq ahb_master_convert_trans_waitstate_seq_h;
    ahb_slave_convert_trans_waitstate_seq ahb_slave_convert_trans_waitstate_seq_h;

    extern function new(string name = "ahb_virtual_convert_trans_waitstate_seq");
    extern task body();
endclass : ahb_virtual_convert_trans_waitstate_seq

function ahb_virtual_convert_trans_waitstate_seq::new(string name = "ahb_virtual_convert_trans_waitstate_seq");
    super.new(name);
endfunction : new

task ahb_virtual_convert_trans_waitstate_seq::body();
    ahb_master_convert_trans_waitstate_seq_h = ahb_master_convert_trans_waitstate_seq::type_id::create("ahb_master_convert_trans_waitstate_seq_h");
    ahb_slave_convert_trans_waitstate_seq_h = ahb_slave_convert_trans_waitstate_seq::type_id::create("ahb_slave_convert_trans_waitstate_seq_h");

    `uvm_info(get_type_name(), $sformatf("DEBUG :: Inside ahb_virtual_convert_trans_waitstate_seq"), UVM_NONE);

    fork
        begin : T1_SL_CONVERT_WAIT
            forever begin
                ahb_slave_convert_trans_waitstate_seq_h.start(p_sequencer.ahb_slave_sequencer_h);
            end
        end
    join_none

    fork
        repeat(1) begin
            ahb_master_convert_trans_waitstate_seq_h.start(p_sequencer.ahb_master_sequencer_h);
        end
    join

endtask : body

`endif
