`ifndef  AHB_SLAVE_TX_INCLUDE_
`define AHB_SLAVE_TX_INCLUDE_
class ahb_slave_tx extends ahb_base_tx;
    `uvm_object_utils(ahb_slave_tx)
    constraint hresp_c0 {if(htrans == HTRANS_BUSY || htrans == HTRANS_IDLE) hresp == HRESP_OKAY;}
    constraint wait_state_c0 {if(htrans == HTRANS_BUSY || htrans == HTRANS_IDLE) wait_state == 0;}
    constraint hexokey_c0 {soft hexokay == HEXOKAY_PASS;}
    constraint hrdata_c0 {soft hrdata > 0;}
endclass : ahb_slave_tx
`endif