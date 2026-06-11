class reset_driver extends uvm_driver#(reset_item);
  `uvm_component_utils(reset_driver)
  
  virtual reset_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual reset_if)::get(this, "", "rst_vif", vif)) begin
      `uvm_fatal("RST_DRV", "Không tìm thấy reset_if trong config_db")
    end
  endfunction

  task run_phase(uvm_phase phase);
    vif.rst_n <= 1'b1; 
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("RST_DRV", $sformatf("Bắt đầu ASSERT RESET trong %0d chu kỳ clk", req.cycles), UVM_LOW)
      @(posedge vif.clk);
      vif.rst_n <= 1'b0;
      repeat(req.cycles) @(posedge vif.clk);
      vif.rst_n <= 1'b1;
      `uvm_info("RST_DRV", "Đã DEASSERT RESET (Hệ thống trở lại bình thường)", UVM_LOW)
      
      seq_item_port.item_done();
    end
  endtask
endclass