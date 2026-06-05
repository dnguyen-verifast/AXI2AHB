Config evn for bridge in x2h_env_config.sv :
    bit has_scoreboard_ahb = 0;
    bit has_virtual_seqr_ahb = 0;
    int no_of_slaves_ahb = 1;
    int no_of_masters_ahb = 0;

    bit has_scoreboard_axi = 0;
    bit has_virtual_seqr_axi = 0;
    int no_of_slaves_axi = 0;
    int no_of_masters_axi = 1;

Config vip axi , ahb in build_phase x2h_base_test.sv
Parameter config in axi4_globals_pkg.sv and ahb_global_pkg.sv
  parameter bit MASTER_AGENT_ACTIVE = 1;

  //Parameter: SLAVE_AGENT_ACTIVE
  //Used to set the slave agent either active or passive
  parameter bit SLAVE_AGENT_ACTIVE = 1;

  //Parameter: NO_OF_MASTERS
  //Used to set number of masters required
  parameter int NO_OF_MASTERS = 1;

  //Parameter: NO_OF_SLAVES
  //Used to set number of slaves required
  parameter int NO_OF_SLAVES = 1;
  
   
    