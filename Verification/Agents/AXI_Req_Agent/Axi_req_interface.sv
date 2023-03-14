interface AX_REQ_IF #(parameter FPW = 4)(input clk);
  
  logic TREADY;
  logic TVALID;
  logic [FPW*128-1:0]TDATA; // DWIDTH = FPW*128
  logic [FPW*16-1:0]TUSER; //NUM_DATA_BYTES = FPW*16
	


endinterface:AX_REQ_IF
