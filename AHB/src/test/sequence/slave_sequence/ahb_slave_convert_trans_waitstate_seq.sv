`ifndef AHB_SLAVE_CONVERT_TRANS_WAITSTATE_SEQ_INCLUDE_
`define AHB_SLAVE_CONVERT_TRANS_WAITSTATE_SEQ_INCLUDE_

class ahb_slave_convert_trans_waitstate_seq extends ahb_slave_base_seq;
    `uvm_object_utils(ahb_slave_convert_trans_waitstate_seq)

    extern function new(string name = "ahb_slave_convert_trans_waitstate_seq");
    extern task body();
endclass : ahb_slave_convert_trans_waitstate_seq

function ahb_slave_convert_trans_waitstate_seq::new(string name = "ahb_slave_convert_trans_waitstate_seq");
    super.new(name);
endfunction : new

task ahb_slave_convert_trans_waitstate_seq::body();
    ahb_slave_tx cloned_req;
    super.body();
    
    // Respond to multiple transactions with varying wait states
    repeat(10) begin
        start_item(req_slv);
        if(!req_slv.randomize() with {
            hresp == HRESP_OKAY;
            wait_state dist {0:=20, 1:=10, 2:=30, 3:=40};
        }) 
        begin
            `uvm_fatal("ahb_slave", "Randomization failed for convert_trans_waitstate");
        end
        $cast(cloned_req, req_slv.clone());
        p_sequencer.seq_expect_item_port.write(cloned_req);
        finish_item(req_slv);
    end

endtask : body

`endif
