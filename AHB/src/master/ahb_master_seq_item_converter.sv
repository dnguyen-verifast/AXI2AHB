`ifndef AHB_MASTER_SEQ_ITEM_CONVERTER_INCLUDED_
`define AHB_MASTER_SEQ_ITEM_CONVERTER_INCLUDED_

//--------------------------------------------------------------------------------------------
// class : ahb_master_seq_item_converter
// Description:
// class converting seq_item transactions into struct data items and vice versa for AHB
//--------------------------------------------------------------------------------------------

class ahb_master_seq_item_converter extends uvm_object;
  `uvm_object_utils(ahb_master_seq_item_converter)
  
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "ahb_master_seq_item_converter");
  
  extern static function void from_class(input ahb_master_tx input_conv_h, output ahb_transfer_struct output_conv_h);
  extern static function void to_class(input ahb_transfer_struct input_conv_h, output ahb_master_tx output_conv_h);
  
  extern function void do_print(uvm_printer printer);
endclass : ahb_master_seq_item_converter

//--------------------------------------------------------------------------------------------
// Construct: new
//--------------------------------------------------------------------------------------------
function ahb_master_seq_item_converter::new(string name = "ahb_master_seq_item_converter");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: from_class
// Converting seq_item transactions into struct data items (Enum -> Logic/Bit)
//--------------------------------------------------------------------------------------------
function void ahb_master_seq_item_converter::from_class(input ahb_master_tx input_conv_h, output ahb_transfer_struct output_conv_h);
  
  // Direct bit assignments
  output_conv_h.haddr     = input_conv_h.haddr;
  output_conv_h.hmastlock = input_conv_h.hmastlock;
  output_conv_h.hprot     = input_conv_h.hprot;
  output_conv_h.hwdata    = input_conv_h.hwdata;
  output_conv_h.hwstrb    = input_conv_h.hwstrb;
  output_conv_h.hrdata    = input_conv_h.hrdata;
  output_conv_h.hreadyout = input_conv_h.hreadyout;
  output_conv_h.hsel      = input_conv_h.hsel;

  // Enum to Logic casting
  $cast(output_conv_h.hburst,  input_conv_h.hburst);
  $cast(output_conv_h.hsize,   input_conv_h.hsize);
  $cast(output_conv_h.hnonsec, input_conv_h.hnonsec);
  $cast(output_conv_h.hexcl,   input_conv_h.hexcl);
  $cast(output_conv_h.hmaster, input_conv_h.hmaster);
  $cast(output_conv_h.htrans,  input_conv_h.htrans);
  $cast(output_conv_h.hwrite,  input_conv_h.hwrite);
  $cast(output_conv_h.hresp,   input_conv_h.hresp);
  $cast(output_conv_h.hexokay, input_conv_h.hexokay);

endfunction : from_class

//--------------------------------------------------------------------------------------------
// Function: to_class
// Converting struct data items into seq_item transactions (Logic/Bit -> Enum)
//--------------------------------------------------------------------------------------------
function void ahb_master_seq_item_converter::to_class(input ahb_transfer_struct input_conv_h, output ahb_master_tx output_conv_h);
  
  output_conv_h = new();

  // Direct bit assignments
  output_conv_h.haddr     = input_conv_h.haddr;
  output_conv_h.hmastlock = input_conv_h.hmastlock;
  output_conv_h.hprot     = input_conv_h.hprot;
  output_conv_h.hwdata    = input_conv_h.hwdata;
  output_conv_h.hwstrb    = input_conv_h.hwstrb;
  output_conv_h.hrdata    = input_conv_h.hrdata;
  output_conv_h.hreadyout = input_conv_h.hreadyout;
  output_conv_h.hsel      = input_conv_h.hsel;

  // Logic to Enum casting
  $cast(output_conv_h.hburst,  input_conv_h.hburst);
  $cast(output_conv_h.hsize,   input_conv_h.hsize);
  $cast(output_conv_h.hnonsec, input_conv_h.hnonsec);
  $cast(output_conv_h.hexcl,   input_conv_h.hexcl);
  $cast(output_conv_h.hmaster, input_conv_h.hmaster);
  $cast(output_conv_h.htrans,  input_conv_h.htrans);
  $cast(output_conv_h.hwrite,  input_conv_h.hwrite);
  $cast(output_conv_h.hresp,   input_conv_h.hresp);
  $cast(output_conv_h.hexokay, input_conv_h.hexokay);

endfunction : to_class

//--------------------------------------------------------------------------------------------
// Function: do_print method
//--------------------------------------------------------------------------------------------
function void ahb_master_seq_item_converter::do_print(uvm_printer printer);
  ahb_transfer_struct ahb_st;
  super.do_print(printer);
  
  printer.print_field("haddr",     ahb_st.haddr,     $bits(ahb_st.haddr),     UVM_HEX);
  printer.print_field("hburst",    ahb_st.hburst,    $bits(ahb_st.hburst),    UVM_BIN);
  printer.print_field("hmastlock", ahb_st.hmastlock, $bits(ahb_st.hmastlock), UVM_BIN);
  printer.print_field("hprot",     ahb_st.hprot,     $bits(ahb_st.hprot),     UVM_BIN);
  printer.print_field("hsize",     ahb_st.hsize,     $bits(ahb_st.hsize),     UVM_BIN);
  printer.print_field("hnonsec",   ahb_st.hnonsec,   $bits(ahb_st.hnonsec),   UVM_BIN);
  printer.print_field("hexcl",     ahb_st.hexcl,     $bits(ahb_st.hexcl),     UVM_BIN);
  printer.print_field("hmaster",   ahb_st.hmaster,   $bits(ahb_st.hmaster),   UVM_BIN);
  printer.print_field("htrans",    ahb_st.htrans,    $bits(ahb_st.htrans),    UVM_BIN);
  printer.print_field("hwdata",    ahb_st.hwdata,    $bits(ahb_st.hwdata),    UVM_HEX);
  printer.print_field("hwstrb",    ahb_st.hwstrb,    $bits(ahb_st.hwstrb),    UVM_HEX);
  printer.print_field("hwrite",    ahb_st.hwrite,    $bits(ahb_st.hwrite),    UVM_BIN);
  printer.print_field("hrdata",    ahb_st.hrdata,    $bits(ahb_st.hrdata),    UVM_HEX);
  printer.print_field("hreadyout", ahb_st.hreadyout, $bits(ahb_st.hreadyout), UVM_BIN);
  printer.print_field("hresp",     ahb_st.hresp,     $bits(ahb_st.hresp),     UVM_BIN);
  printer.print_field("hexokay",   ahb_st.hexokay,   $bits(ahb_st.hexokay),   UVM_BIN);
  printer.print_field("hsel",      ahb_st.hsel,      $bits(ahb_st.hsel),      UVM_BIN);

endfunction : do_print

`endif