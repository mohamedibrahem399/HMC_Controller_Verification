interface AXI_Req_IF #(parameter FPW = 4)(input clk, res);
  
  logic TREADY;
  logic TVALID;
  logic [FPW*128-1:0]TDATA; // DWIDTH = FPW*128
  logic [FPW*16-1:0]TUSER; //NUM_DATA_BYTES = FPW*16
  
  logic [FPW-1:0]Valid; //VALID Flags
  logic [FPW-1:0]Hdr;   //HEADER Flags
  logic [FPW-1:0]Tail;  //TAIL Flags

  assign Valid = TUSER[FPW-1:0];
  assign Hdr = TUSER[2*FPW-1:FPW];
  assign Tail = TUSER[3*FPW-1:2*FPW];
	
endinterface:AXI_Req_IF
