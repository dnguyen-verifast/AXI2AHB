Issue 1: In fifo2axi.sv, break down axi handshake rule and a undepend chanel.
    wire ready;
	assign ready = bready&rready;  // (ready rely on bready and rready).

	wire fifo_empty; 
	assign fifo_empty = rdata_fifo_empty|resp_fifo_empty|id_resp_fifo_empty;

	wire read_en;
	assign read_en = (!rdata_fifo_empty)&(!resp_fifo_empty)&(!id_resp_fifo_empty)&ready; // a strong mistake, valid waiting ready are asserted.    

