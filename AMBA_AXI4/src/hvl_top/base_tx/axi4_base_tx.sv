`ifndef AXI4_BASE_TX_SV_INCLUDED_
`define AXI4_BASE_TX_SV_INCLUDED_
//--------------------------------------------------------------------------------------------
// Class: axi4_base_tx
//--------------------------------------------------------------------------------------------
class axi4_base_tx extends uvm_sequence_item;
`uvm_object_utils(axi4_base_tx)
  //-------------------------------------------------------
  // WRITE ADDRESS CHANNEL SIGNALS
  //-------------------------------------------------------
  //Variable : awid
  //Used to send the write address id
  rand awid_e awid;

  //Variable : awaddr
  //Used to send the write address
  rand bit [ADDRESS_WIDTH-1:0] awaddr;

  //Variable : awlen
  //Used to send the write address length
  rand bit [LENGTH-1:0] awlen;

  //Variable : awsize
  //Used to send the write address size
  rand awsize_e awsize;
  
  //Variable : awburst
  //Used to send the write address burst
  rand awburst_e awburst;

  //Variable : awlock
  //Used to send the write address lock
  rand awlock_e awlock;
  
  //Variable : awcache
  //Used to send the write address cache
  rand awcache_e awcache;

  //Variable : awprot
  //Used to send the write address prot
  rand awprot_e awprot;

  //Variable : awqos
  //Used to send the write address quality of service
  rand bit [3:0] awqos;

  //Variable : awregion
  //Used to send the write address region selected
  rand awregion_e awregion;

  //Variable : awuser
  //Used to send the write address user
  rand bit awuser;

  //------------------------------------------------------s
   // WRITE DATA CHANNEL SIGNALS
  //-------------------------------------------------------
  //Variable : wdata
  //Used to randomise write data
  //varaible[$] gives a unbounded queue
  //variable[$:value] gives a bounded queue to a value of given value 
  rand bit [DATA_WIDTH-1:0] wdata [$:2**LENGTH];

  //Variable : wstrb
  //Used to randomise write strobe
  //varaible[$] gives a unbounded queue
  //variable[$:value] gives a bounded queue to a value of given value 
  rand bit [(DATA_WIDTH/8)-1:0] wstrb [$:2**LENGTH];

  //Variable : wlast
  //Used to store the write last transfer
  rand bit wlast;

  //Variable : wuser
  //Used to send the user bit value
  rand bit [3:0] wuser;

  //-------------------------------------------------------
  // WRITE RESPONSE CHANNEL SIGNALS
  //-------------------------------------------------------
  //Variable : bid
  //Used to send the response id
  rand bid_e bid;

  //Variable : bresp
  //Used to capture the write response of the trasnaction
  rand bresp_e bresp;
  
  //Variable : buser
  //Used to capture the buser
  rand bit buser;

  //-------------------------------------------------------
  // READ ADDRESS CHANNEL SIGNALS
  //-------------------------------------------------------
  //Variable : arid
  //Used to send the read address id
  rand arid_e arid;
 
  //Variable : araddr
  //Used to send the read address
  rand bit [ADDRESS_WIDTH-1:0] araddr;

  //Variable : arlen
  //Used to send the read address length
  rand bit [LENGTH-1:0] arlen;

  //Variable : arsize
  //Used to send the read address size
  rand arsize_e arsize;
  
  //Variable : arburst
  //Used to send the read address burst
  rand arburst_e arburst;

  //Variable : arlock
  //Used to send the read address lock
  rand arlock_e arlock;
  
  //Variable : arcache
  //Used to send the read address cache
  rand arcache_e arcache;

  //Variable : arprot
  //Used to send the read address prot
  rand arprot_e arprot;

  //Variable : arqos
  //Used to send the read address quality of service
  rand bit arqos;

  //Variable : aruser
  //Used to send the read address user data
  rand bit aruser;

  //Variable : arregion
  //Used to send the read address region data
  rand arregion_e arregion;

  //-------------------------------------------------------
  // READ DATA CHANNEL SIGNALS 
  //-------------------------------------------------------
  //Variable : rid
  //Used to send the read address id
  rand rid_e rid;
  
  //Variable : rdata
  //Used to randomise read data
  //varaible[$] gives a unbounded queue
  //variable[$:value] gives a bounded queue to a value of given value 
  rand bit [DATA_WIDTH-1:0] rdata [$:2**LENGTH];

  //Variable : rresp
  //Used to capture the read response of the trasnaction
  rand rresp_e rresp;

  //Variable : rlast
  //Used to store the read last transfer
  rand bit rlast;

  //Variable : ruser
  //Used to read the read user value
  rand bit ruser;
  
  //Variable : endian
  //Used to differentiate the type of memory storage
  rand endian_e endian;

  //Variable : tx_type
  //Used to determine the transaction type
  rand tx_type_e tx_type;

  //Variable: transfer_type
  //Used to the determine the type of the transfer
  rand transfer_type_e transfer_type;
  
  //Variable : no_of_wait_states
  //Used to count number of wait states
  rand int no_of_wait_states;

  //Variable : compare_mode
  //Used to determine the compare mode for the transaction
  compare_mode_e compare_mode;

  //Variable: wait_count_write_address_channel
  //Used to determine wait count for write address channel
  int wait_count_write_address_channel;

  //Variable: wait_count_write_data_channel
  //Used to determine wait count for write data channel
  int wait_count_write_data_channel;
  
  //Variable: wait_count_write_response_channel
  //Used to determine wait count for write response channel
  int wait_count_write_response_channel;

  //Variable: wait_count_read_address_channel
  //Used to determine wait count for write response channel
  int wait_count_read_address_channel;

  //Variable: wait_count_read_data_channel
  //Used to determine wait count for write response channel
  int wait_count_read_data_channel;
  
  //Variable: outstanding_write_tx
  //Used to determine the outstanding write tx count
  int outstanding_write_tx;
  
  //Variable: outstanding_write_tx
  //Used to determine the outstanding write tx count
  int outstanding_read_tx;
  
  extern function new (string name = "axi4_base_tx");
  extern function void do_copy(uvm_object rhs);
  extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
endclass : axi4_base_tx

function axi4_base_tx::new(string name ="axi4_base_tx");
    super.new(name);
endfunction: new

function void axi4_base_tx::do_copy(uvm_object rhs);
  axi4_base_tx axi4_base_tx_copy_obj;

  if(!$cast(axi4_base_tx_copy_obj,rhs)) begin
    `uvm_fatal("do_copy","cast of the rhs object failed")
  end
  super.do_copy(rhs);
  
  //WRITE ADDRESS CHANNEL
  awid    = axi4_base_tx_copy_obj.awid;
  awaddr  = axi4_base_tx_copy_obj.awaddr;
  awlen   = axi4_base_tx_copy_obj.awlen;
  awsize  = axi4_base_tx_copy_obj.awsize;
  awburst = axi4_base_tx_copy_obj.awburst;
  awlock  = axi4_base_tx_copy_obj.awlock;
  awcache = axi4_base_tx_copy_obj.awcache;
  awprot  = axi4_base_tx_copy_obj.awprot;
  awqos   = axi4_base_tx_copy_obj.awqos;
  //WRITE DATA CHANNEL
  wdata = axi4_base_tx_copy_obj.wdata;
  wstrb = axi4_base_tx_copy_obj.wstrb;
  wuser = axi4_base_tx_copy_obj.wuser;
  //WRITE RESPONSE CHANNEL
  bid   = axi4_base_tx_copy_obj.bid;
  bresp = axi4_base_tx_copy_obj.bresp;
  buser = axi4_base_tx_copy_obj.buser;
  //READ ADDRESS CHANNEL
  arid     = axi4_base_tx_copy_obj.arid;
  araddr   = axi4_base_tx_copy_obj.araddr;
  arlen    = axi4_base_tx_copy_obj.arlen;
  arsize   = axi4_base_tx_copy_obj.arsize;
  arburst  = axi4_base_tx_copy_obj.arburst;
  arlock   = axi4_base_tx_copy_obj.arlock;
  arcache  = axi4_base_tx_copy_obj.arcache;
  arprot   = axi4_base_tx_copy_obj.arprot;
  arqos    = axi4_base_tx_copy_obj.arqos;
  arregion = axi4_base_tx_copy_obj.arregion;
  aruser   = axi4_base_tx_copy_obj.aruser;
  //READ DATA CHANNEL
  rid   = axi4_base_tx_copy_obj.rid;
  rdata = axi4_base_tx_copy_obj.rdata;
  rresp = axi4_base_tx_copy_obj.rresp;
  ruser = axi4_base_tx_copy_obj.ruser;
  //OTHERS
  tx_type       = axi4_base_tx_copy_obj.tx_type;
  transfer_type = axi4_base_tx_copy_obj.transfer_type;
endfunction : do_copy

function bit axi4_base_tx::do_compare (uvm_object rhs, uvm_comparer comparer);
  axi4_base_tx axi4_base_tx_compare_obj;
  bit result; 

  if(!$cast(axi4_base_tx_compare_obj,rhs)) begin
    `uvm_fatal("FATAL_AXI_BASE_TX_DO_COMPARE_FAILED","cast of the rhs object failed")
    return 0;
  end
	result = 1;
 // result = super.do_compare(axi4_base_tx_compare_obj, comparer);
  case(compare_mode)
    CHECK_WRITE_ADDRESS: begin
      result &= (awaddr  == axi4_base_tx_compare_obj.awaddr)  &&   
                (awid    == axi4_base_tx_compare_obj.awid)    &&
                (awlen   == axi4_base_tx_compare_obj.awlen)   &&
                (awsize  == axi4_base_tx_compare_obj.awsize)  &&
                (awburst == axi4_base_tx_compare_obj.awburst) &&
                (awlock  == axi4_base_tx_compare_obj.awlock)  &&
                (awcache == axi4_base_tx_compare_obj.awcache) &&
                (awqos   == axi4_base_tx_compare_obj.awqos)   &&
                (awprot  == axi4_base_tx_compare_obj.awprot);
    end

    CHECK_WRITE_DATA: begin
      result &= (wdata == axi4_base_tx_compare_obj.wdata) &&
                (wstrb == axi4_base_tx_compare_obj.wstrb);
    end

    CHECK_WRITE_RESP: begin
      result &= (bid   == axi4_base_tx_compare_obj.bid)   &&
                (bresp == axi4_base_tx_compare_obj.bresp) &&
                (buser == axi4_base_tx_compare_obj.buser);
    end

    CHECK_READ_ADDRESS: begin
      result &= (araddr   == axi4_base_tx_compare_obj.araddr)   &&
                (arid     == axi4_base_tx_compare_obj.arid)     &&
                (arlen    == axi4_base_tx_compare_obj.arlen)    &&
                (arsize   == axi4_base_tx_compare_obj.arsize)   &&
                (arburst  == axi4_base_tx_compare_obj.arburst)  &&
                (arlock   == axi4_base_tx_compare_obj.arlock)   &&
                (arcache  == axi4_base_tx_compare_obj.arcache)  &&
                (arqos    == axi4_base_tx_compare_obj.arqos)    &&
                (arregion == axi4_base_tx_compare_obj.arregion) &&
                (arprot   == axi4_base_tx_compare_obj.arprot);
    end

    CHECK_READ_DATA: begin
      result &= (rid   == axi4_base_tx_compare_obj.rid)   &&  
                (rdata == axi4_base_tx_compare_obj.rdata) && 
                (rresp == axi4_base_tx_compare_obj.rresp) &&
                (ruser == axi4_base_tx_compare_obj.ruser);
    end

    CHECK_ALL: begin
      result &= (
        //WRITE ADDRESS
        awaddr == axi4_base_tx_compare_obj.awaddr && awid == axi4_base_tx_compare_obj.awid &&
        awlen == axi4_base_tx_compare_obj.awlen && awsize == axi4_base_tx_compare_obj.awsize &&
        awburst == axi4_base_tx_compare_obj.awburst && awlock == axi4_base_tx_compare_obj.awlock &&
        awcache == axi4_base_tx_compare_obj.awcache && awqos == axi4_base_tx_compare_obj.awqos &&
        awprot == axi4_base_tx_compare_obj.awprot &&
        //WRITE DATA
        wdata == axi4_base_tx_compare_obj.wdata && wstrb == axi4_base_tx_compare_obj.wstrb &&
        //WRITE RESPONSE
        bid == axi4_base_tx_compare_obj.bid && bresp == axi4_base_tx_compare_obj.bresp &&
        buser == axi4_base_tx_compare_obj.buser &&
        //READ ADDRESS
        araddr == axi4_base_tx_compare_obj.araddr && arid == axi4_base_tx_compare_obj.arid &&
        arlen == axi4_base_tx_compare_obj.arlen && arsize == axi4_base_tx_compare_obj.arsize &&
        arburst == axi4_base_tx_compare_obj.arburst && arlock == axi4_base_tx_compare_obj.arlock &&
        arcache == axi4_base_tx_compare_obj.arcache && arqos == axi4_base_tx_compare_obj.arqos &&
        arregion== axi4_base_tx_compare_obj.arregion && arprot == axi4_base_tx_compare_obj.arprot &&
        //READ DATA
        rid == axi4_base_tx_compare_obj.rid && rdata == axi4_base_tx_compare_obj.rdata && 
        rresp == axi4_base_tx_compare_obj.rresp && ruser == axi4_base_tx_compare_obj.ruser
      );
    end

    NO_CHECK: begin
      result = 1;
    end
  endcase
  return result;

endfunction : do_compare

function void axi4_base_tx::do_print(uvm_printer printer);
  printer.print_string("tx_type",tx_type.name());
  if(tx_type == WRITE) begin
  //`uvm_info("------------------------------------------WRITE_ADDRESS_CHANNEL","-------------------------------------",UVM_LOW);
    printer.print_string("awid",awid.name());
    printer.print_field("awaddr",awaddr,$bits(awaddr),UVM_HEX);
    printer.print_field("awlen",awlen,$bits(awlen),UVM_DEC);
    printer.print_string("awsize",awsize.name());
    printer.print_string("awburst",awburst.name());
    printer.print_string("awlock",awlock.name());
    printer.print_string("awcache",awcache.name());
    printer.print_string("awregion",awregion.name());
    printer.print_string("awprot",awprot.name());
    printer.print_field("awqos",awqos,$bits(awqos),UVM_HEX);
    printer.print_field("wait_count_write_address_channel",wait_count_write_address_channel,
                         $bits(wait_count_write_address_channel),UVM_HEX);
    //`uvm_info("------------------------------------------WRITE_DATA_CHANNEL","---------------------------------------",UVM_LOW);
    foreach(wdata[i])begin
      printer.print_field($sformatf("wdata[%0d]",i),wdata[i],$bits(wdata[i]),UVM_HEX);
    end
    foreach(wstrb[i])begin
      // MSHA: printer.print_field($sformatf("wstrb[%0d]",i),wstrb[i],$bits(wstrb[i]),UVM_HEX);
      printer.print_field($sformatf("wstrb[%0d]",i),wstrb[i],$bits(wstrb[i]),UVM_HEX);
    end
    printer.print_field("wait_count_write_data_channel",wait_count_write_data_channel,
                         $bits(wait_count_write_data_channel),UVM_HEX);
    //`uvm_info("-----------------------------------------WRITE_RESPONSE_CHANNEL","------------------------------------",UVM_LOW);
    printer.print_string("bid",bid.name());
    printer.print_string("bresp",bresp.name());
    printer.print_field("no_of_wait_states",no_of_wait_states,$bits(no_of_wait_states),UVM_DEC);
    printer.print_field("wait_count_write_response_channel",wait_count_write_response_channel,
                         $bits(wait_count_write_response_channel),UVM_HEX);
  end
  
  if(tx_type == READ) begin
    //`uvm_info("------------------------------------------READ_ADDRESS_CHANNEL","-------------------------------------",UVM_LOW);
    printer.print_string("arid",arid.name());
    printer.print_field("araddr",araddr,$bits(araddr),UVM_HEX);
    printer.print_field("arlen",arlen,$bits(arlen),UVM_DEC);
    printer.print_string("arsize",arsize.name());
    printer.print_string("arburst",arburst.name());
    printer.print_string("arlock",arlock.name());
    printer.print_string("arregion",arregion.name());
    printer.print_string("arcache",arcache.name());
    printer.print_string("arprot",arprot.name());
    printer.print_field("arqos",arqos,$bits(arqos),UVM_HEX);
    printer.print_field("wait_count_read_address_channel",wait_count_read_address_channel,
                         $bits(wait_count_read_address_channel),UVM_HEX);
    //`uvm_info("------------------------------------------READ_DATA_CHANNEL","----------------------------------------",UVM_LOW);
    printer.print_string("rid",rid.name());
    foreach(rdata[i])begin
      printer.print_field($sformatf("rdata[%0d]",i),rdata[i],$bits(rdata[i]),UVM_HEX);
    end
    printer.print_string("rresp",rresp.name());
    printer.print_field("ruser",ruser,$bits(ruser),UVM_HEX);
    printer.print_field("no_of_wait_states",no_of_wait_states,$bits(no_of_wait_states),UVM_DEC);
    printer.print_field("wait_count_read_data_channel",wait_count_read_data_channel,$bits(wait_count_read_data_channel),UVM_HEX);
  end
  printer.print_string("transfer_type",transfer_type.name());
endfunction : do_print

`endif
