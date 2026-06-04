`ifndef AHB_TEST_BASE_INCLUDED_
`define AHB_TEST_BASE_INCLUDED_

class ahb_test_base extends uvm_test;
    `uvm_component_utils(ahb_test_base)

    ahb_env ahb_env_h;

    ahb_env_config ahb_env_config_h;
    

    extern function new(string name = "ahb_test_base", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void setup_ahb_master_agent_cfg();
    extern virtual function void setup_ahb_slave_agent_cfg();    
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
endclass : ahb_test_base

function ahb_test_base::new(string name = "ahb_test_base",uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void ahb_test_base::build_phase(uvm_phase phase);
  super.build_phase(phase);

  ahb_env_config_h = ahb_env_config::type_id::create("ahb_env_config_h");
  ahb_env_config_h.has_scoreboard = 1;
  ahb_env_config_h.has_virtual_seqr = 1;
  ahb_env_config_h.no_of_slaves = 1;
  ahb_env_config_h.no_of_masters = 1;
  setup_ahb_master_agent_cfg();
  setup_ahb_slave_agent_cfg();
  uvm_config_db #(ahb_env_config)::set(this,"*","ahb_env_config",ahb_env_config_h);
  `uvm_info(get_type_name(),$sformatf("\nAHB_ENV_CONFIG\n%s",ahb_env_config_h.sprint()),UVM_LOW);
  ahb_env_h = ahb_env::type_id::create("ahb_env_h",this);
endfunction : build_phase

function void ahb_test_base::setup_ahb_master_agent_cfg();
  ahb_env_config_h.ahb_master_config_h = new[ahb_env_config_h.no_of_masters];
  foreach(ahb_env_config_h.ahb_master_config_h[i]) begin
    ahb_env_config_h.ahb_master_config_h[i] = ahb_master_config::type_id::create($sformatf("ahb_master_config_h[i]",i));
    uvm_config_db#(ahb_master_config)::set(this,"*env*",$sformatf("ahb_master_config[%0d]",i),ahb_env_config_h.ahb_master_config_h[i]);
  end
endfunction : setup_ahb_master_agent_cfg

function void ahb_test_base::setup_ahb_slave_agent_cfg();
  ahb_env_config_h.ahb_slave_config_h = new[ahb_env_config_h.no_of_slaves];
  foreach(ahb_env_config_h.ahb_slave_config_h[i]) begin
    ahb_env_config_h.ahb_slave_config_h[i] = ahb_slave_config::type_id::create($sformatf("ahb_slave_config_h[i]",i));
    uvm_config_db#(ahb_slave_config)::set(this,"*env*",$sformatf("ahb_slave_config[%0d]",i),ahb_env_config_h.ahb_slave_config_h[i]);
  end
endfunction : setup_ahb_slave_agent_cfg

function void ahb_test_base::end_of_elaboration_phase(uvm_phase phase);
  uvm_top.print_topology();
 // uvm_test_done.set_drain_time(this,100ns);
endfunction : end_of_elaboration_phase

task ahb_test_base::run_phase(uvm_phase phase);
  phase.raise_objection(this, "ahb_test_base");
  `uvm_info(get_type_name(), $sformatf("Inside BASE_TEST"), UVM_NONE);
  super.run_phase(phase);
  #100;
  `uvm_info(get_type_name(), $sformatf("Done BASE_TEST"), UVM_NONE);
  phase.drop_objection(this);
endtask : run_phase
`endif