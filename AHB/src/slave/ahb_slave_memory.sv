`ifndef ahb_slave_memory_INCLUDED_
`define ahb_slave_memory_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_slave_agent
// This agent has sequencer, driver_proxy, monitor_proxy for axi4  
//--------------------------------------------------------------------------------------------
class ahb_slave_memory extends uvm_object;
  `uvm_object_utils(ahb_slave_memory)

  //Variable : slave_memory
  //Declaration of slave_memory to store the data from master
  protected bit [7:0] slave_memory [longint];

  protected bit [31:0] exclusive_monitor [int];

   //Variable : fifo_memory
  //Variable : fifo_memory
  //Declaration of fifo_memory to store the data from master of type fixed
  protected bit [7:0] fifo_memory [$];

  extern function new(string name = "ahb_slave_memory");

  extern virtual function void record_read_exclusive (bit [ADDRESS_WIDTH-1:0] address, bit [3:0] id);
  extern virtual function bit check_exclusive_write (bit [ADDRESS_WIDTH-1:0] address, bit [3:0] id);
  extern virtual function void clear_monitor_on_write (bit [ADDRESS_WIDTH-1:0] address); 
  extern virtual function bit [ADDRESS_WIDTH-1:0] get_region_base_addr(bit [ADDRESS_WIDTH-1:0] base_addr, region_e region_id);  
  extern virtual function void mem_write(input bit [ADDRESS_WIDTH-1:0]slave_address, bit [DATA_WIDTH-1:0]data);
  extern virtual function void mem_read (input bit [ADDRESS_WIDTH-1:0]slave_address, output bit [DATA_WIDTH-1:0]data);
  extern virtual function void fifo_write(input bit [DATA_WIDTH-1:0]data);
  extern virtual function void fifo_read (output bit [DATA_WIDTH-1:0]data);

endclass : ahb_slave_memory

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - axi4_slave_agent_config
//--------------------------------------------------------------------------------------------
function ahb_slave_memory::new(string name = "ahb_slave_memory");
  super.new(name); 
endfunction : new


function void ahb_slave_memory::record_read_exclusive (bit [ADDRESS_WIDTH-1:0] address, bit [3:0] id);
  exclusive_monitor[address] = id;
  `uvm_info("EXCL_MON", $sformatf("Manager ID %0d granted exclusive tracking at Addr 32'h%0h", id, address), UVM_LOW)
endfunction : record_read_exclusive

 function bit ahb_slave_memory::check_exclusive_write (bit [ADDRESS_WIDTH-1:0] address, bit [3:0] id);
  if(exclusive_monitor.exists(address) && exclusive_monitor[address] == id) begin
    exclusive_monitor.delete(id);
    return 1; 
    `uvm_info("EXCL_MON", $sformatf("Manager ID %0d granted exclusive tracking at Addr 32'h%0h", id, address), UVM_HIGH)
  end else begin
    `uvm_warning(get_type_name(), $sformatf("Exclusive write violation at address %h by ID %0d", address, id))
    return 0;
  end
endfunction : check_exclusive_write

 function void ahb_slave_memory::clear_monitor_on_write (bit [ADDRESS_WIDTH-1:0] address);
  bit [3:0] id_queue [$];
  foreach(exclusive_monitor[id]) begin
      if(exclusive_monitor[id] == address) begin
        id_queue.push_back(id);
      end
  end
  foreach(id_queue[i]) begin
    exclusive_monitor.delete(id_queue[i]);
    `uvm_info("EXCL_MON", $sformatf("Clearing exclusive monitor for ID %0d at Addr 32'h%0h due to write operation", id_queue[i], address), UVM_LOW)
  end
endfunction : clear_monitor_on_write


//--------------------------------------------------------------------------------------------
//Task : mem_write
//Used to store the slave data into the slave memory
//Parameter :
//slave_address - bit [ADDRESS_WIDTH-1 :0]
//data          - bit [DATA_WIDTH-1:0]
//--------------------------------------------------------------------------------------------
function void ahb_slave_memory::mem_write(input bit [ADDRESS_WIDTH-1 :0]slave_address, bit [DATA_WIDTH-1:0]data);
  slave_memory[slave_address] = data;
endfunction : mem_write

//--------------------------------------------------------------------------------------------
//Task : mem_read
//Used to store the slave data into the slave memory
//Parameter :
//slave_address - bit [ADDRESS_WIDTH-1 :0]
//data          - bit [DATA_WIDTH-1:0]
//--------------------------------------------------------------------------------------------
function void ahb_slave_memory::mem_read(input bit [ADDRESS_WIDTH-1 :0]slave_address, output bit [DATA_WIDTH-1:0]data);
   if(slave_memory.exists(slave_address)) begin
     data = slave_memory[slave_address];
   end else begin
     `uvm_warning(get_type_name(), $sformatf("Address %h does not exist in slave memory", slave_address))
     data = '0; // Return default value if address does not exist
     return;
   end
endfunction : mem_read

//--------------------------------------------------------------------------------------------
//Task : fifo_write
//Used to store the slave data into the slave memory
//Parameter :
//data          - bit [DATA_WIDTH-1:0]
//--------------------------------------------------------------------------------------------
function void ahb_slave_memory::fifo_write(input bit [DATA_WIDTH-1:0]data);
  fifo_memory.push_front(data);
endfunction : fifo_write

//--------------------------------------------------------------------------------------------
//Task : fifo_read
//Used to store the slave data into the slave memory
//Parameter :
//data          - bit [DATA_WIDTH-1:0]
//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
//Task : is_slave_addr_exists
//Used to check the address exists are not in the memory
//slave_address - bit [ADDRESS_WIDTH-1 :0]
//--------------------------------------------------------------------------------------------
function bit ahb_slave_memory::is_slave_addr_exists(input bit [ADDRESS_WIDTH-1 :0]slave_address);
  is_slave_addr_exists = slave_memory.exists(slave_address);
endfunction: is_slave_addr_exists

`endif
