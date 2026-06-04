`ifndef AHB_MASTER_RAND_BURST_SIZE_WR_SEQ_INCLUDE_
`define AHB_MASTER_RAND_BURST_SIZE_WR_SEQ_INCLUDE_

class ahb_master_rand_burst_size_wr_seq extends ahb_master_base_seq;
    `uvm_object_utils(ahb_master_rand_burst_size_wr_seq)

    extern function new(string name = "ahb_master_rand_burst_size_wr_seq");
    extern task body();
endclass : ahb_master_rand_burst_size_wr_seq

function ahb_master_rand_burst_size_wr_seq::new(string name = "ahb_master_rand_burst_size_wr_seq");
    super.new(name);
endfunction : new

task ahb_master_rand_burst_size_wr_seq::body();
    hburst_e burst_types[] = '{SINGLE, INCR4, INCR8, INCR16, WRAP4, WRAP8, WRAP16};
    hsize_e size_types[] = '{HSIZE_BYTE, HSIZE_HWORD, HSIZE_WORD};
    hburst_e selected_burst;
    hsize_e selected_size;
    int num_transfers;

    // Random write bursts with varying sizes
    repeat(10) begin
        selected_burst = burst_types[$urandom_range(0, burst_types.size()-1)];
        selected_size = size_types[$urandom_range(0, size_types.size()-1)];
        num_transfers = ($urandom_range(1, 5));
        
        do_burst_transfer(32'h1000_0000 + ($urandom_range(0, 32'h0000_0FFF)), 
                         HWRITE_WRITE, 
                         selected_burst, 
                         selected_size, 
                         0, 
                         num_transfers);
        do_idle(1, 32'h1000_0000);
    end

endtask : body

`endif
