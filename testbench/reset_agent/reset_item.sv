class reset_item extends uvm_sequence_item;
  rand int unsigned cycles; 

  constraint c_cycles { cycles inside {[5:20]}; } 

  `uvm_object_utils_begin(reset_item)
    `uvm_field_int(cycles, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "reset_item");
    super.new(name);
  endfunction
endclass