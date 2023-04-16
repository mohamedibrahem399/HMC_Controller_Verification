/* sequence item
       request packets  -> done.
       responce packets -> working on it.
       sequences -> working on it.
       NULL packet  -> .......
       TRET packets -> .......
       sleep mode packets -> .........
       link retry packets -> .........


*/

class RA_seq_item extends uvm_sequence_item;
  `uvm_component_utils(RA_seq_item) 
  bit [127 :0]  packet[]    ;
  bit [63  :0]  flit_tail   ;
  bit [63  :0]  flit_header ;
  bit [ 3:0 ]  LNG_response ;    //= flit[10:7 ];


  //********************************************************************************
  //                                _________________                               
  //                                |from the specs.|                               
  //                                ?????????????????                               
  //********************************************************************************


  //packet tail fields
  // location for                 request packet    responce packet
  bit [7 :0]  RRP;        //=flit   [7 :0 ]           [7 :0 ]
  bit [7 :0]  FRP;        //=flit   [15:8 ]           [15:8 ]
  bit [2 :0]  SEQ;        //=flit   [18:16]           [18:16]
  bit         DINV;       //=flit   not_found         [   19]
  bit [2 :0]  SLID;       //=flit   [26:24]           not_found
  bit [6 :0]  ERRSTAT;    //=flit   not_found         [26:20]
  bit [4 :0]  RTC;        //=flit   [31:27]           [31:27] 
  bit [31:0]  CRC;        //=flit   [63:32]           [63:32]
  // not used                       [23:19]           not_found

  //********************************************************************************

  // header part

  //packet header fields in request packet.
  // location for                       request packet         responce packet
  logic [ 5:0 ]  cmd;  //= flit          [ 5:0 ]               [ 5:0 ]
  logic [ 3:0 ]  LNG;  //= flit          [10:7 ]               [10:7 ] // named before LEN
  logic [ 3:0 ]  DLN;  //= flit          [14:11]               [14:11] 
  logic [ 8:0 ]  TAG;  //= flit          [23:15]               [23:15]
  logic [ 8:0 ]  TGA;  //= flit          not_found             [32:24]
  logic [ 2:0 ] SLID;  //= flit          not_found             [41:39] 
  logic [33:0 ] addr;  //= flit          [57:24]               not_found
  logic [ 2:0 ]  CUB;  //= flit          [63:61]               not_found
  // not used                            [60:58]&[6]           [63:42]&[38:33]&[6]

  //********************************************************************************

  // Sleep mode signals. ( or power saving mode )
  bit           LXRXPS      ;
  bit           LXTXPS      ;
  assign LXTXPS = LXRXPS;


  //********************************************************************************
  //                                __________________________                      
  //                                |REQUEST PACKET FUNCTIONS|                      
  //                                ??????????????????????????                      
  //********************************************************************************

// tail -> fill from or into flit tail functions


  task fill_tail__from_request_flit(input bit[63:0] flit_tail);
        // CRC , RTC , SLID , SEQ , FRP , RRP
        RRP =flit_tail[7 :0 ];
        FRP =flit_tail[15:8 ];
        SEQ =flit_tail[18:16];
        SLID=flit_tail[26:24];
        RTC =flit_tail[31:27];
        CRC =flit_tail[63:32];
  endtask 

  function automatic fill_request_flit_with_tail(ref bit[63:0] flit_tail);
        flit_tail =0; // to fill the gaps
        flit_tail[7 :0 ]=RRP ;
        flit_tail[15:8 ]=FRP ;
        flit_tail[18:16]=SEQ ;
        flit_tail[26:24]=SLID;
        flit_tail[31:27]=RTC ;
        flit_tail[63:32]=CRC ;
  endfunction 

// header -> fill from or into flit header functions

task fill_header_from_request_flit(input bit[63:0] flit_header);
        // cmd , LNG , DLN , TAG , addr , CUB
        cmd   = flit_header[ 5:0 ];
        LNG   = flit_header[10:7 ];
        DLN   = flit_header[14:11];
        TAG   = flit_header[23:15];
        addr  = flit_header[57:24];
        CUB   = flit_header[63:61];
  endtask 

  function automatic fill_request_flit_with_header(ref bit[63:0] flit_header);
        flit_header = 0; // to fill the gaps
        flit_header[ 5:0 ] = cmd ;
        flit_header[10:7 ] = LNG ;
        flit_header[14:11] = DLN ;
        flit_header[23:15] = TAG ;
        flit_header[57:24] = addr;
        flit_header[63:61] = CUB ;
        //return flit_header;
  endfunction



// all those functions can be used directly using this function.

  task  extract_request_packet_header_and_tail();
                bit[63:0] temp;
		{flit_tail ,temp}   = packet[LNG-1];
 		{temp ,flit_header} = packet[0];
                fill_tail__from_request_flit(flit_tail);
                fill_header_from_flit(flit_header);
  endtask:extract_request_packet_header_and_tail



  //********************************************************************************
  //                                ___________________________                     
  //                                |RESPONCE PACKET FUNCTIONS|                     
  //                                ???????????????????????????                     
  //********************************************************************************

// tail -> fill from or into flit tail functions

  task fill_tail__from_responce_flit(input bit[63:0] flit_tail);
        // CRC , RTC , ERRSTAT , DINV , SEQ , FRP , RRP
        RRP    =flit_tail[7 :0 ];
        FRP    =flit_tail[15:8 ];
        SEQ    =flit_tail[18:16];
        DINV   =flit_tail[   19];
        ERRSTAT=flit_tail[26:20];
        RTC    =flit_tail[31:27];
        CRC    =flit_tail[63:32];
  endtask 

  function automatic fill_responce_flit_with_tail(ref bit[63:0] flit_tail);
        flit_tail =0; // to fill the gaps
        flit_tail[7 :0 ]=RRP    ;
        flit_tail[15:8 ]=FRP    ;
        flit_tail[18:16]=SEQ    ;
        flit_tail[   19]=DINV   ;
        flit_tail[26:20]=ERRSTAT;
        flit_tail[31:27]=RTC    ;
        flit_tail[63:32]=CRC    ;
  endfunction 


// header -> fill from or into flit header functions

task fill_header_from_responce_flit(input bit[63:0] flit_header);
        // cmd , LNG , DLN , TAG , TGA , SLID
        cmd   = flit_header[ 5:0 ];
        LNG   = flit_header[10:7 ];
        DLN   = flit_header[14:11];
        TAG   = flit_header[23:15];
        TGA   = flit_header[32:24];
        SLID  = flit_header[41:39];
  endtask 

  function automatic fill_responce_flit_with_header(ref bit[63:0] flit_header);
        flit_header = 0; // to fill the gaps
        flit_header[ 5:0 ] = cmd ;
        flit_header[10:7 ] = LNG ;
        flit_header[14:11] = DLN ;
        flit_header[23:15] = TAG ;
        flit_header[32:24] = TGA ;
        flit_header[41:39] = SLID;
        //return flit_header;
  endfunction



// all those functions can be used directly using this function.

  task  extract_responce_packet_header_and_tail();
                bit[63:0] temp;
		{flit_tail ,temp}   = packet[LNG-1];
 		{temp ,flit_header} = packet[0];
                fill_tail__from_responce_flit(flit_tail);
                fill_header_from_responce_flit(flit_header);
  endtask:extract_responce_packet_header_and_tail




  //********************************************************************************
  //                                ___________________                             
  //                                |GENERAL FUNCTIONS|                             
  //                                ???????????????????                             
  //********************************************************************************


// function to check on CMD is it found in the commands in the specs or not
// if the function returned 1 that means the LNG and CMD are correct.
// if the function returned 0 that means the LNG and CMD are not correct.
// this function also indicates LNG of the responce packet based on the CMD.
  function bit check_LNG_and_cmd();
    case (cmd) 
        // Write operations.
        6'b001000: if(LNG != 2)  begin $display("fatal error LNG != 2 while cmd == WR16 "); return 0;  end else LNG_response = 1; //WR16   = 6?b0001000,   //16-byte WRITE request
        6'b001001: if(LNG != 3)  begin $display("fatal error LNG != 3 while cmd == WR32 "); return 0;  end else LNG_response = 1;  //WR32  = 6?b0001001,
        6'b001010: if(LNG != 4)  begin $display("fatal error LNG != 4 while cmd == WR48 "); return 0;  end else LNG_response = 1;  //WR48  = 6?b0001010,
        6'b001011: if(LNG != 5)  begin $display("fatal error LNG != 4 while cmd == WR64 "); return 0;  end else LNG_response = 1;  //WR64  = 6?b0001011,
        6'b001100: if(LNG != 6)  begin $display("fatal error LNG != 5 while cmd == WR80 "); return 0;  end else LNG_response = 1;  //WR80  = 6?b0001100,
        6'b001101: if(LNG != 7)  begin $display("fatal error LNG != 5 while cmd == WR96 "); return 0;  end else LNG_response = 1;  //WR96  = 6?b0001101,
        6'b001110: if(LNG != 8)  begin $display("fatal error LNG != 5 while cmd == WR112"); return 0;  end else LNG_response = 1;  //WR112 = 6?b0001110,
        6'b001111: if(LNG != 9)  begin $display("fatal error LNG != 5 while cmd == WR128"); return 0;  end else LNG_response = 1;  //WR128 = 6?b0001111,
        6'b010000: if(LNG != 2)  begin $display("fatal error LNG != 1 while cmd == MD_WR"); return 0;  end else LNG_response = 1;  //MD_WR = 6?b0010000  //MODE WRITE request

        // Posted Write Request
        6?b011000: if(LNG != 2)  begin $display("fatal error LNG != 2 while cmd == P_WR16  "); return 0;  end else LNG_response = 0;  //P_WR16  = 6?b0011000,   //16-byte POSTED WRITErequest
        6?b011001: if(LNG != 3)  begin $display("fatal error LNG != 3 while cmd == P_WR32  "); return 0;  end else LNG_response = 0;  //P_WR32  = 6?b0011001,
        6?b011010: if(LNG != 4)  begin $display("fatal error LNG != 4 while cmd == P_WR48  "); return 0;  end else LNG_response = 0;  //P_WR48  = 6?b0011010,
        6?b011011: if(LNG != 5)  begin $display("fatal error LNG != 4 while cmd == P_WR64  "); return 0;  end else LNG_response = 0;  //P_WR64  = 6?b0011011,
        6?b011100: if(LNG != 6)  begin $display("fatal error LNG != 5 while cmd == P_WR80  "); return 0;  end else LNG_response = 0;  //P_WR80  = 6?b0011100,
        6?b011101: if(LNG != 7)  begin $display("fatal error LNG != 5 while cmd == P_WR96  "); return 0;  end else LNG_response = 0;  //P_WR96  = 6?b0011101,
        6?b011110: if(LNG != 8)  begin $display("fatal error LNG != 5 while cmd == P_WR112 "); return 0;  end else LNG_response = 0;  //P_WR112 = 6?b0011110,
        6?b011111: if(LNG != 9)  begin $display("fatal error LNG != 5 while cmd == P_WR128 "); return 0;  end else LNG_response = 0;  //P_WR128 = 6?b0011111,

        //READ Requests
        6?b110000: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == RD16 "); return 0;  end else LNG_response = 2 ;  //RD16  = 6?b0110000,   //16-byte READ request
        6?b110001: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == RD32 "); return 0;  end else LNG_response = 3 ;  //RD32  = 6?b0110001,
        6?b110010: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == RD48 "); return 0;  end else LNG_response = 4 ;  //RD48  = 6?b0110010,
        6?b110011: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == RD64 "); return 0;  end else LNG_response = 5 ;  //RD64  = 6?b0110011,
        6?b110100: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == RD80 "); return 0;  end else LNG_response = 6 ;  //RD80  = 6?b0110100,
        6?b110101: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == RD96 "); return 0;  end else LNG_response = 7 ;  //RD96  = 6?b0110101,
        6?b110110: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == RD112"); return 0;  end else LNG_response = 8 ;  //RD112 = 6?b0110110,
        6?b110111: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == RD128"); return 0;  end else LNG_response = 9 ;  //RD128 = 6?b0110111,
        6?b101000: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == MD_RD"); return 0;  end else LNG_response = 2 ;  //MD_RD = 6?b0101000,  //MODE READ request

        //ARITHMETIC ATOMICS
        6?b010010:  if(LNG != 2) begin $display("fatal error LNG != 2 while cmd == Dual_ADD8  "); return 0;  end else begin LNG_response = 1 ; $display("cmd == Dual_ADD8  "); end//Dual_ADD8   = 6?b0010010,   //Dual 8-byte signed add immediate
        6?b010011:  if(LNG != 2) begin $display("fatal error LNG != 2 while cmd == ADD16      "); return 0;  end else begin LNG_response = 1 ; $display("cmd == ADD16      "); end//ADD16       = 6?b0010011,   //Single 16-byte signed add immediate
        6?b100010:  if(LNG != 2) begin $display("fatal error LNG != 2 while cmd == P_2ADD8    "); return 0;  end else begin LNG_response = 0 ; $display("cmd == P_2ADD8    "); end//P_2ADD8     = 6?b0100010,   //Posted dual 8-byte signed add immediate
        6?b100011:  if(LNG != 2) begin $display("fatal error LNG != 2 while cmd == P_ADD16    "); return 0;  end else begin LNG_response = 0 ; $display("cmd == P_ADD16    "); end//P_ADD16     = 6?b0100011,   //Posted single 16-byte signed add immediate
        6?b1010011: if(LNG != 2) begin $display("fatal error LNG != 2 while cmd == ADDS16R    "); return 0;  end else begin LNG_response = 2 ; $display("cmd == ADDS16R    "); end//ADDS16R     = 6?b1010011,   //Single 16-byte signed add immediate and return
        6?b1010000: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == INC8       "); return 0;  end else begin LNG_response = 1 ; $display("cmd == INC8       "); end//INC8        = 6?b1010000,   //8-byte increment
        6?b1010100: if(LNG != 1) begin $display("fatal error LNG != 1 while cmd == P_INC8     "); return 0;  end else begin LNG_response = 0 ; $display("cmd == P_INC8     "); end//P_INC8      = 6?b1010100,   //Posted 8-byte increment

        //BITWISE ATOMICS
        6?b010001: if(LNG != 2) begin $display("fatal error LNG != 2 while cmd == BWR   "); return 0;  end else begin LNG_response = 1 ; $display("cmd == BWR     "); end//BWR    = 6?b0010001, //8-byte bit write 
        6?b100001: if(LNG != 2) begin $display("fatal error LNG != 2 while cmd == P_BWR "); return 0;  end else begin LNG_response = 0 ; $display("cmd == P_BWR   "); end//P_BWR  = 6?b0100001, //Posted 8-byte bit write 

 
         default: begin $display("FATAL ERROR, cmd is not found in list of commands. "); return 0; end
    endcase

       return 1;
  endfunction

// function to check on CMD is it found in the commands in the specs or not
// if the function returned 1 that means the LNG and CMD are correct.
// if the function returned 0 that means the LNG and CMD are not correct.
// this function also indicates LNG of the responce packet based on the CMD.
  function automatic bit set_LNG_from_cmd(input bit [6:0] received_cmd , ref bit [ 4:0 ]  LNG );
    case (received_cmd) 
        // Write operations.
        6?b001000: begin LNG =2 ; LNG_response = 1; end  //WR16  = 6?b001000,   //16-byte WRITE request
        6?b001001: begin LNG =3 ; LNG_response = 1; end  //WR32  = 6?b001001,
        6?b001010: begin LNG =4 ; LNG_response = 1; end  //WR48  = 6?b001010,
        6?b001011: begin LNG =5 ; LNG_response = 1; end  //WR64  = 6?b001011,
        6?b001100: begin LNG =6 ; LNG_response = 1; end  //WR80  = 6?b001100,
        6?b001101: begin LNG =7 ; LNG_response = 1; end  //WR96  = 6?b001101,
        6?b001110: begin LNG =8 ; LNG_response = 1; end  //WR112 = 6?b001110,
        6?b001111: begin LNG =9 ; LNG_response = 1; end  //WR128 = 6?b001111,
        6?b010000: begin LNG =2 ; LNG_response = 1; end  //MD_WR = 6?b010000  //MODE WRITE request

        // Posted Write Request
        6?b011000: begin LNG =2 ; LNG_response = 0; end  //P_WR16  = 6?b011000,   //16-byte POSTED WRITErequest
        6?b011001: begin LNG =3 ; LNG_response = 0; end  //P_WR32  = 6?b011001,
        6?b011010: begin LNG =4 ; LNG_response = 0; end  //P_WR48  = 6?b011010,
        6?b011011: begin LNG =5 ; LNG_response = 0; end  //P_WR64  = 6?b011011,
        6?b011100: begin LNG =6 ; LNG_response = 0; end  //P_WR80  = 6?b011100,
        6?b011101: begin LNG =7 ; LNG_response = 0; end  //P_WR96  = 6?b011101,
        6?b011110: begin LNG =8 ; LNG_response = 0; end  //P_WR112 = 6?b011110,
        6?b011111: begin LNG =9 ; LNG_response = 0; end  //P_WR128 = 6?b011111,

        //READ Requests
        6?b110000: begin LNG =1; LNG_response = 2 ; end  //RD16  = 6?b110000,   //16-byte READ request
        6?b110001: begin LNG =1; LNG_response = 3 ; end  //RD32  = 6?b110001,
        6?b110010: begin LNG =1; LNG_response = 4 ; end  //RD48  = 6?b110010,
        6?b110011: begin LNG =1; LNG_response = 5 ; end  //RD64  = 6?b110011,
        6?b110100: begin LNG =1; LNG_response = 6 ; end  //RD80  = 6?b110100,
        6?b110101: begin LNG =1; LNG_response = 7 ; end  //RD96  = 6?b110101,
        6?b110110: begin LNG =1; LNG_response = 8 ; end  //RD112 = 6?b110110,
        6?b110111: begin LNG =1; LNG_response = 9 ; end  //RD128 = 6?b110111,
        6?b101000: begin LNG =1; LNG_response = 2 ; end  //MD_RD = 6?b101000,  //MODE READ request

        //ARITHMETIC ATOMICS
        6?b010010: begin LNG =2; LNG_response = 1; end //Dual_ADD8   = 6?b010010,   //Dual 8-byte signed add immediate
        6?b010011: begin LNG =2; LNG_response = 1; end //ADD16       = 6?b010011,   //Single 16-byte signed add immediate
        6?b100010: begin LNG =2; LNG_response = 0; end //P_2ADD8     = 6?b100010,   //Posted dual 8-byte signed add immediate
        6?b100011: begin LNG =2; LNG_response = 9; end //P_ADD16     = 6?b100011,   //Posted single 16-byte signed add immediate


        //BITWISE ATOMICS
        6?b010001: begin LNG =2; LNG_response = 1; end //BWR    = 6?b010001, //8-byte bit write 
        6?b100001: begin LNG =2; LNG_response = 0; end //P_BWR  = 6?b100001, //Posted 8-byte bit write 

 
         default: begin LNG =0; LNG_response = 0;  $display("FATAL ERROR, cmd is not found in list of commands. "); return 0; end
    endcase


       return 1;
  endfunction


endclass: RA_seq_item




  //********************************************************************************
  //                                ___________________                             
  //                                |      NOTES      |                             
  //                                ???????????????????                             
  //********************************************************************************


/*

typedef enum bit [6:0]{
    
    // Write Request
    
    WR16  = 7'b0001000,   //16-byte WRITE request
    WR32  = 7'b0001001,
    WR48  = 7'b0001010,
    WR64  = 7'b0001011,
    WR80  = 7'b0001100,
    WR96  = 7'b0001101,
    WR112 = 7'b0001110,
    WR128 = 7'b0001111,
    WR256 = 7'b1001111,
    MD_WR = 7'b0010000,  //MODE WRITE request


    // Posted Write Request
    P_WR16  = 7'b0011000,   //16-byte POSTED WRITErequest
    P_WR32  = 7'b0011001,
    P_WR48  = 7'b0011010,
    P_WR64  = 7'b0011011,
    P_WR80  = 7'b0011100,
    P_WR96  = 7'b0011101,
    P_WR112 = 7'b0011110,
    P_WR128 = 7'b0011111,
    P_WR256 = 7'b1011111,

    //READ Requests
    RD16  = 7'b0110000,   //16-byte READ request
    RD32  = 7'b0110001,
    RD48  = 7'b0110010,
    RD64  = 7'b0110011,
    RD80  = 7'b0110100,
    RD96  = 7'b0110101,
    RD112 = 7'b0110110,
    RD128 = 7'b0110111,
    RD256 = 7'b1110111,
    MD_RD = 7'b0101000,  //MODE READ request

    //ARITHMETIC ATOMICS
    Dual_ADD8   = 7'b0010010,   //Dual 8-byte signed add immediate
    ADD16       = 7'b0010011,   //Single 16-byte signed add immediate
    P_2ADD8     = 7'b0100010,   //Posted dual 8-byte signed add immediate
    P_ADD16     = 7'b0100011,   //Posted single 16-byte signed add immediate
    Dual_ADDS8R = 7'b1010010,   //Dual 8-byte signed add immediate and return
    ADDS16R     = 7'b1010011,   //Single 16-byte signed add immediate and return
    INC8        = 7'b1010000,   //8-byte increment
    P_INC8      = 7'b1010100,   //Posted 8-byte increment

    //BOOLEAN ATOMICS
    XOR16 = 7'b1000000,
    OR16 = 7'b1000001,
    NOR16 = 7'b1000010,
    AND16 = 7'b1000011,
    NAND16 = 7'b1000100,

    //COMPARISON ATOMICS
    CASGT8 = 7'b1100000, //8-byte compare and swap if greater than
    CASGT16 = 7'b1100010, //16-byte compare and swap if greater than
    CASLT8 = 7'b1100001, //8-byte compare and swap if less than
    CASLT16 = 7'b1100011, //16-byte compare and swap less than
    CASEQ8 = 7'b1100100,  //8-byte compare and swap if equal
    CASZERO16 = 7'b1100101, //16-byte compare and swap if zero
    EQ8 = 7'b1101001,  //8-byte equal 
    EQ16 = 7'b1101000, //16-byte equal 

    //BITWISE ATOMICS
    BWR = 7'b0010001, //8-byte bit write 
    P_BWR = 7'b0100001, //Posted 8-byte bit write 
    BWR8R = 7'b1010001, //8-byte bit write with return
    SWAP16 = 7'b1101010 //16-byte swap or ex change
 
             } REQ_Command;


*/



