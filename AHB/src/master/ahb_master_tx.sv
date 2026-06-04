`ifndef AHB_MASTER_TX_INCLUDE_
`define AHB_MASTER_TX_INCLUDE_
class ahb_master_tx extends ahb_base_tx;   
    `uvm_object_utils(ahb_master_tx)

    constraint haddr_c0 {soft haddr%(2**hsize)==0;}
    constraint hburst_c0 {soft hburst == SINGLE;}
    constraint hmastlock_c0 {soft hmastlock == 0;}
    constraint hprot_c0 {soft hprot ==0;}
    constraint hsize_c0 {soft 8*(2**hsize) <= DATA_WIDTH;}
    constraint hnonsec_c0 {soft hnonsec == 0;}
    constraint hexcl_c0 {soft hexcl == 0;}
    constraint hmaster_c0 {soft hmaster == 0;}
    constraint htrans_c0 {soft htrans == HTRANS_IDLE;}
    constraint hsel_c0 {soft hsel == 1;}   
    extern function void post_randomize();
endclass : ahb_master_tx
function void ahb_master_tx::post_randomize();
if(hwrite == HWRITE_WRITE) begin
    bit [HWSTRB-1:0] local_hstrb;
    bit [HWSTRB-1:0] rand_hstrb;
    int       total_lane;
    int       lane_transfer;
    int       num_byte_act;
    int       lane_active;
    num_byte_act = 2**hsize;
    total_lane   = ADDR_WIDTH / 8;
    lane_transfer  = haddr % total_lane; // take bit 0,1  
    lane_active = ((1 << num_byte_act) -1) << lane_transfer;
    local_hstrb = lane_active[HWSTRB-1:0];
    rand_hstrb  = $urandom() & ((1<<HWSTRB)-1);
    hwstrb      = local_hstrb; //& rand_hstrb;
end else hwstrb = 0;
endfunction : post_randomize
`endif