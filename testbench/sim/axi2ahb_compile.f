-F $(AXIVIP_PATH)/sim/axi4_compile.f
-F $(AHBVIP_PATH)/sim/ahb_compile.f
+incdir+../env/
+incdir+../test/sequences/master_sequences/
+incdir+../test/sequences/slave_sequences/
+incdir+../test/virtual_sequences/
+incdir+../test/testcase/
+incdir+${DUT_PATH}/
+incdir+../
../env/x2h_env_pkg.sv
../test/sequences/master_sequences/axi4_master_seq_pkg.sv
../test/sequences/slave_sequences/ahb_slave_seq_pkg.sv
../test/virtual_sequences/x2h_virtual_seq_pkg.sv
../test/testcase/x2h_test_pkg.sv
${DUT_PATH}/axi_ahb_pkg.sv      
${DUT_PATH}/sync_fifo.sv         
${DUT_PATH}/axi_write_engine.sv   
${DUT_PATH}/axi_read_engine.sv   
${DUT_PATH}/axi4_to_ahb_lite.sv   
${DUT_PATH}/ahb_lite_slave_mem.sv

../top.sv