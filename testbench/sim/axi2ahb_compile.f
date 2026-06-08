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

${DUT_PATH}/addr_fifo.v
${DUT_PATH}/data_fifo.v
${DUT_PATH}/write_fifo.v
${DUT_PATH}/id_send_fifo.v
${DUT_PATH}/size_fifo.v
${DUT_PATH}/rdata_fifo.v
${DUT_PATH}/resp_fifo.v
${DUT_PATH}/id_resp_fifo.v
${DUT_PATH}/axi2fifo.v
${DUT_PATH}/fifo2axi.v

${DUT_PATH}/fifo_wrapper.v
${DUT_PATH}/axi_controller.v
${DUT_PATH}/ahb_controller.v
${DUT_PATH}/axi2ahb_bridge_top.v

../top.sv