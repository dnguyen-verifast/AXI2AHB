`ifndef AHB_SLAVE_LOCKED_SEQUENCE_SEQ_INCLUDE_
`define AHB_SLAVE_LOCKED_SEQUENCE_SEQ_INCLUDE_

class ahb_slave_locked_sequence_seq extends ahb_slave_base_seq;
    `uvm_object_utils(ahb_slave_locked_sequence_seq)

    extern function new(string name = "ahb_slave_locked_sequence_seq");
    extern task body();
endclass : ahb_slave_locked_sequence_seq
function ahb_slave_locked_sequence_seq::new(string name = "ahb_slave_locked_sequence_seq");
    super.new(name);
endfunction : new

task ahb_slave_locked_sequence_seq::body();
    ahb_slave_tx cloned_req;
    super.body();
    start_item(req_slv);
    if(!req_slv.randomize() with {
        hresp == HRESP_OKAY;
        wait_state == 0;
    }) begin
        `uvm_fatal("ahb_slave","Rand failed");
    end
    $cast(cloned_req,req_slv.clone());
    p_sequencer.seq_expect_item_port.write(cloned_req);
    finish_item(req_slv);
endtask : body
`endif
