`ifndef AHB_GLOBAL_PKG_INCLUDED_
`define AHB_GLOBAL_PKG_INCLUDED_

package ahb_global_pkg;

    parameter int ADDR_WIDTH = 32;
    parameter int DATA_WIDTH = 32;
    parameter int HWSTRB = DATA_WIDTH/8;

    // typedef enum bit {
    //     UVM_PASSTIVE = 1'b0,
    //     UVM_ACTIVE = 1'b1
    // } uvm_active_passive_enum;

    typedef enum bit {
        RANDOM_RESP = 1'b0,
        MEM_RESP = 1'b1
    } response_mode_e;

    typedef enum bit [2:0]{
        SINGLE  = 3'b000,
        INCR    = 3'b001,
        WRAP4   = 3'b010,
        INCR4   = 3'b011,
        WRAP8   = 3'b100,
        INCR8   = 3'b101,
        WRAP16   = 3'b110,
        INCR16   = 3'b111
    } hburst_e;

typedef enum bit [2:0] {
        HSIZE_BYTE   = 3'b000,
        HSIZE_HWORD  = 3'b001,
        HSIZE_WORD   = 3'b010,
        HSIZE_DWORD  = 3'b011,
        HSIZE_LINE4  = 3'b100,
        HSIZE_LINE8  = 3'b101,
        HSIZE_LINE16 = 3'b110,
        HSIZE_LINE32 = 3'b111
    } hsize_e;

    typedef enum bit {
        HNONSEC_SECURE    = 1'b0,
        HNONSEC_NONSECURE = 1'b1
    } hnonsec_e;

    typedef enum bit {
        HEXCL_NORMAL    = 1'b0,
        HEXCL_EXCLUSIVE = 1'b1
    } hexcl_e;

    typedef enum bit [3:0] {
        HMASTER_0  = 4'h0,
        HMASTER_1  = 4'h1,
        HMASTER_2  = 4'h2,
        HMASTER_3  = 4'h3,
        HMASTER_4  = 4'h4,
        HMASTER_5  = 4'h5,
        HMASTER_6  = 4'h6,
        HMASTER_7  = 4'h7,
        HMASTER_8  = 4'h8,
        HMASTER_9  = 4'h9,
        HMASTER_10 = 4'hA,
        HMASTER_11 = 4'hB,
        HMASTER_12 = 4'hC,
        HMASTER_13 = 4'hD,
        HMASTER_14 = 4'hE,
        HMASTER_15 = 4'hF
    } hmaster_e;

    typedef enum bit [1:0] {
        HTRANS_IDLE   = 2'b00,
        HTRANS_BUSY   = 2'b01,
        HTRANS_NONSEQ = 2'b10,
        HTRANS_SEQ    = 2'b11
    } htrans_e;

    typedef enum bit {
        HWRITE_READ  = 1'b0,
        HWRITE_WRITE = 1'b1
    } hwrite_e;

    typedef enum bit {
        HRESP_OKAY  = 1'b0,
        HRESP_ERROR = 1'b1
    } hresp_e;

    typedef enum bit {
        HEXOKAY_FAIL = 1'b0,
        HEXOKAY_PASS = 1'b1
    } hexokay_e;

    typedef enum bit {
        ADDR_PHASE = 1'b0,
        DATA_PHASE = 1'b1
    } compare_phase_e;

    typedef struct {
        bit [ADDR_WIDTH-1 : 0]    haddr;
        bit [2:0]                 hburst;
        bit                       hmastlock;
        bit [3:0]                 hprot;
        bit [2:0]                 hsize;
        bit                       hnonsec;
        bit                       hexcl;
        bit [3:0]                 hmaster;
        bit [1:0]                 htrans;
        bit [DATA_WIDTH-1:0]      hwdata;
        bit [HWSTRB-1:0]          hwstrb;
        bit                       hwrite;

        // singal generate by subordinate
        bit [DATA_WIDTH-1:0]      hrdata;
        bit                       hreadyout;
        bit                       hresp;
        bit                       hexokay;
        bit                       hready;
        bit                       hsel;
    } ahb_transfer_struct ;

endpackage
`endif
