 

`ifndef CMD_DATA_TYPES
`define CMD_DATA_TYPES


typedef enum bit [5:0]{
  
    
  // Write Request

  WR16 = 6'b001000,   //16-byte WRITE request
  WR32 = 6'b001001,
  WR48 = 6'b001010,
  WR64 = 6'b001011,
  WR80 = 6'b001100,
  WR96 = 6'b001101,
  WR112 = 6'b001110,
  WR128 = 6'b001111,


  //MODE WRITE, BIT WRITE, and ATOMIC Requests
  MD_WR = 6'b010000,  //MODE WRITE request
  BWR   = 6'b010001,
  T_ADD8 = 6'b010010,
  ADD16    = 6'b010011,


 
  // Posted Write Request
  P_WR16 = 6'b011000,   //16-byte POSTED WRITErequest
  P_WR32 = 6'b011001,
  P_WR48 = 6'b011010,
  P_WR64 = 6'b011011,
  P_WR80 = 6'b011100,
  P_WR96 = 6'b011101,
  P_WR112 = 6'b011110,
  P_WR128 = 6'b011111,
  
  //POSTED BIT WRITE, and POSTED ATOMIC Requests
  P_BWR = 6'b100001,
  P_2ADD8 = 6'b100010,
  P_ADD16 = 6'b100011,


  //READ Requests
  RD16 = 6'b110000,   //16-byte READ request
  RD32 = 6'b110001,
  RD48 = 6'b110010,
  RD64 = 6'b110011,
  RD80 = 6'b110100,
  RD96 = 6'b110101,
  RD112 = 6'b110110,
  RD128 = 6'b110111,

  //Mode Read Requests
  MD_RD = 6'b101000 //MODE READ request
  
} Req_Command;
             




`endif 
