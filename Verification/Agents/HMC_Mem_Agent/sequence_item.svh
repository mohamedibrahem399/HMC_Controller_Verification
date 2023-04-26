/* sequence item
       request packets  -> done.
       responce packets -> working on it.
       sequences -> working on it.
       NULL packet  -> .......
       TRET packets -> .......
       sleep mode packets -> .........
       link retry packets -> .........


*/
`include "HMC_Mem_Types.svh"

class RA_seq_item extends uvm_sequence_item;
  `uvm_component_utils(RA_seq_item) 

  bit [127 :0]  packet[]    ;
  bit [63  :0]  flit_tail   ;
  bit [63  :0]  flit_header ;
  bit [ 3:0 ]  LNG_response ;    //= flit[10:7 ];

  function new(string name = "RA_seq_item");
      super.new(name);
  endfunction: new


  //********************************************************************************
  //                                _________________                               
  //                                |from the specs.|                               
  //                                ?????????????????                               
  //********************************************************************************

// seq item separated... and then
  // header part

  //packet header fields in request packet.
  // location for                         request packet         responce packet
  rand  CMD_Req_t    CMD;  //= flit          [ 5:0 ]               [ 5:0 ]
  rand  bit [ 3:0 ]  LNG;  //= flit          [10:7 ]               [10:7 ] // named before LEN
  rand  bit [ 3:0 ]  DLN;  //= flit          [14:11]               [14:11] 
  rand  bit [ 8:0 ]  TAG;  //= flit          [23:15]               [23:15]
  rand  bit [ 8:0 ]  TGA;  //= flit          not_found             [32:24]
  rand  bit [ 2:0 ] SLID_response;  //= flit not_found             [41:39] 
  rand  bit [33:0 ] ADRS;  //= flit          [57:24]               not_found
  rand  bit [ 2:0 ]  CUB;  //= flit          [63:61]               not_found
  // not used                                [60:58]&[6]           [63:42]&[38:33]&[6]

  //********************************************************************************


  //packet tail fields
  // location for                       request packet    responce packet
  rand  bit [7 :0]  RRP;        //=flit   [7 :0 ]           [7 :0 ]
  rand  bit [7 :0]  FRP;        //=flit   [15:8 ]           [15:8 ]
  rand  bit [2 :0]  SEQ;        //=flit   [18:16]           [18:16]
  rand  bit         DINV;       //=flit   not_found         [   19]
  rand  bit [2 :0] SLID_request;//=flit   [26:24]           not_found
  rand  bit [6 :0]  ERRSTAT;    //=flit   not_found         [26:20]
  rand  bit [4 :0]  RTC;        //=flit   [31:27]           [31:27] 
  rand  bit [31:0]  CRC;        //=flit   [63:32]           [63:32]
  // not used                             [23:19]           not_found

  //********************************************************************************

  // request packet header reserved bits:
  rand  bit [2:0]  RES1_request;  // Reserved              [60:58]
  rand  bit        RES2_reqest;   // Reserved              [6]
  // request packet tail reserved bits:
  rand  bit [4:0]  RES3_request;  // Reserved               [23:19] 

    //request packet data
    rand bit[63:0] data[$];

 //********************************************************************************

  // responce packet header reserved bits:
  rand  bit [21:0] RES1_response;    // Reserved               [63:42]
  rand  bit [5 :0] RES2_response;    // Reserved               [38:33]
  rand  bit        RES3_response;    // Reserved               [6]
  // responce packet tail reserved bits: ( there isn't any reserved bits here )

 //********************************************************************************
  // Sleep mode signals. ( or power saving mode )
  rand  bit           LXRXPS      ;
  rand  bit           LXTXPS      ;
  assign LXTXPS = LXRXPS;


  //********************************************************************************

    `uvm_object_utils_begin(HMC_Req_Sequence_item )
        //request packet header
        `uvm_field_int(CUB,      UVM_ALL_ON)
        `uvm_field_int(RES1_request,     UVM_ALL_ON)
        `uvm_field_int(ADRS,     UVM_ALL_ON)
        `uvm_field_int(TAG,      UVM_ALL_ON)
        `uvm_field_int(DLN,      UVM_ALL_ON)
        `uvm_field_int(LNG,      UVM_ALL_ON)
        `uvm_field_int(RES2_request,     UVM_ALL_ON)
        `uvm_field_enum(CMD_Req_t, CMD, UVM_ALL_ON)
        //request packet data
        `uvm_field_queue_int(data, UVM_ALL_ON)

        //request packet tail
        `uvm_field_int(CRC,      UVM_ALL_ON)
        `uvm_field_int(RTC,      UVM_ALL_ON)
        `uvm_field_int(SLID_request,     UVM_ALL_ON)
        `uvm_field_int(RES3_request,     UVM_ALL_ON)
        `uvm_field_int(SEQ,      UVM_ALL_ON)
        `uvm_field_int(FRP,      UVM_ALL_ON)
        `uvm_field_int(RRP,      UVM_ALL_ON)


        //response packet header
        `uvm_field_int(RES1_response,      UVM_ALL_ON)
        `uvm_field_int(SLID_response,      UVM_ALL_ON)
        `uvm_field_int(RES2_response,      UVM_ALL_ON)
        `uvm_field_int(TGA,   UVM_ALL_ON)
        `uvm_field_int(RES3_response,      UVM_ALL_ON)

        //response packet tail
        `uvm_field_int(ERRSTAT,   UVM_ALL_ON)
        `uvm_field_int(DINV,      UVM_ALL_ON)

	`uvm_object_utils_end

  //********************************************************************************

    // request constraints.
    constraint c_reserved_request    {RES1_request==0; RES2_request ==0; RES3_request ==0;}
    constraint c_match_length    {LNG == DLN;  LNG inside {[1:9]};}
    constraint c_commands        {LNG == 1 <-> CMD inside{[RD16 : RD128], MD_RD};
                                  LNG == 2 <-> CMD inside{WR16, [MD_WR : ADD16], P_WR16, [P_BWR : P_ADD16]};
                                  LNG == 3 <-> CMD inside{WR32, P_WR32}; 
                                  LNG == 4 <-> CMD inside{WR48, P_WR48};
                                  LNG == 5 <-> CMD inside{WR64, P_WR64};
                                  LNG == 6 <-> CMD inside{WR80, P_WR80};
                                  LNG == 7 <-> CMD inside{WR96, P_WR96};
                                  LNG == 8 <-> CMD inside{WR112, P_WR112};
                                  LNG == 9 <-> CMD inside{WR128, P_WR128};}
    constraint c_source_link_ID_request  {SLID_request ==0;}

   // responce constraints.
    constraint c_reserved_response   {RES1_response ==0; RES2_response ==0; RES3_response ==0;}
    constraint c_source_link_ID_response  {SLID_response ==0;}
    constraint c_return_tag      {TGA ==0; LNG inside {[1:9]};}
    constraint c_commands_ response   {LNG == 1 <-> CMD inside{WR_RS, MD_WR_RS, ERROR};
                                       LNG == 2 <-> CMD inside{RD_RS, MD_RD_RS};
                                       LNG == 3 <-> CMD inside{RD_RS}; 
                                       LNG == 4 <-> CMD inside{RD_RS};
                                       LNG == 5 <-> CMD inside{RD_RS};
                                       LNG == 6 <-> CMD inside{RD_RS};
                                       LNG == 7 <-> CMD inside{RD_RS};
                                       LNG == 8 <-> CMD inside{RD_RS};
                                       LNG == 9 <-> CMD inside{RD_RS};}
    
    // data constraints
    constraint c_data{  if(LNG <= 2)
                            data.size == (LNG-1)*2;
                        else 
                            data.size == (LNG-2)*2 + 2;}

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
        // CMD , LNG , DLN , TAG , ADRS , CUB
        //CMD   = flit_header[ 5:0 ];
        LNG   = flit_header[10:7 ];
        DLN   = flit_header[14:11];
        TAG   = flit_header[23:15];
        ADRS  = flit_header[57:24];
        CUB   = flit_header[63:61];
  endtask 

  function automatic fill_request_flit_with_header(ref bit[63:0] flit_header);
        flit_header = 0; // to fill the gaps
        //flit_header[ 5:0 ] = CMD ;
        flit_header[10:7 ] = LNG ;
        flit_header[14:11] = DLN ;
        flit_header[23:15] = TAG ;
        flit_header[57:24] = ADRS;
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
        // CMD , LNG , DLN , TAG , TGA , SLID
        //CMD   = flit_header[ 5:0 ];
        LNG   = flit_header[10:7 ];
        DLN   = flit_header[14:11];
        TAG   = flit_header[23:15];
        TGA   = flit_header[32:24];
        SLID  = flit_header[41:39];
  endtask 

  function automatic fill_responce_flit_with_header(ref bit[63:0] flit_header);
        flit_header = 0; // to fill the gaps
        //flit_header[ 5:0 ] = CMD ;
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
  function bit check_LNG_and_CMD();
    case (CMD) 
        // Write operations.
        6'b001000: if(LNG != 2)  begin $display("fatal error LNG != 2 while CMD == WR16 "); return 0;  end else LNG_response = 1; //WR16   = 6?b0001000,   //16-byte WRITE request
        6'b001001: if(LNG != 3)  begin $display("fatal error LNG != 3 while CMD == WR32 "); return 0;  end else LNG_response = 1;  //WR32  = 6?b0001001,
        6'b001010: if(LNG != 4)  begin $display("fatal error LNG != 4 while CMD == WR48 "); return 0;  end else LNG_response = 1;  //WR48  = 6?b0001010,
        6'b001011: if(LNG != 5)  begin $display("fatal error LNG != 4 while CMD == WR64 "); return 0;  end else LNG_response = 1;  //WR64  = 6?b0001011,
        6'b001100: if(LNG != 6)  begin $display("fatal error LNG != 5 while CMD == WR80 "); return 0;  end else LNG_response = 1;  //WR80  = 6?b0001100,
        6'b001101: if(LNG != 7)  begin $display("fatal error LNG != 5 while CMD == WR96 "); return 0;  end else LNG_response = 1;  //WR96  = 6?b0001101,
        6'b001110: if(LNG != 8)  begin $display("fatal error LNG != 5 while CMD == WR112"); return 0;  end else LNG_response = 1;  //WR112 = 6?b0001110,
        6'b001111: if(LNG != 9)  begin $display("fatal error LNG != 5 while CMD == WR128"); return 0;  end else LNG_response = 1;  //WR128 = 6?b0001111,
        6'b010000: if(LNG != 2)  begin $display("fatal error LNG != 1 while CMD == MD_WR"); return 0;  end else LNG_response = 1;  //MD_WR = 6?b0010000  //MODE WRITE request

        // Posted Write Request
        6'b011000: if(LNG != 2)  begin $display("fatal error LNG != 2 while CMD == P_WR16  "); return 0;  end else LNG_response = 0;  //P_WR16  = 6?b0011000,   //16-byte POSTED WRITErequest
        6'b011001: if(LNG != 3)  begin $display("fatal error LNG != 3 while CMD == P_WR32  "); return 0;  end else LNG_response = 0;  //P_WR32  = 6?b0011001,
        6'b011010: if(LNG != 4)  begin $display("fatal error LNG != 4 while CMD == P_WR48  "); return 0;  end else LNG_response = 0;  //P_WR48  = 6?b0011010,
        6'b011011: if(LNG != 5)  begin $display("fatal error LNG != 4 while CMD == P_WR64  "); return 0;  end else LNG_response = 0;  //P_WR64  = 6?b0011011,
        6'b011100: if(LNG != 6)  begin $display("fatal error LNG != 5 while CMD == P_WR80  "); return 0;  end else LNG_response = 0;  //P_WR80  = 6?b0011100,
        6'b011101: if(LNG != 7)  begin $display("fatal error LNG != 5 while CMD == P_WR96  "); return 0;  end else LNG_response = 0;  //P_WR96  = 6?b0011101,
        6'b011110: if(LNG != 8)  begin $display("fatal error LNG != 5 while CMD == P_WR112 "); return 0;  end else LNG_response = 0;  //P_WR112 = 6?b0011110,
        6'b011111: if(LNG != 9)  begin $display("fatal error LNG != 5 while CMD == P_WR128 "); return 0;  end else LNG_response = 0;  //P_WR128 = 6?b0011111,

        //READ Requests
        6'b110000: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == RD16 "); return 0;  end else LNG_response = 2 ;  //RD16  = 6?b0110000,   //16-byte READ request
        6'b110001: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == RD32 "); return 0;  end else LNG_response = 3 ;  //RD32  = 6?b0110001,
        6'b110010: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == RD48 "); return 0;  end else LNG_response = 4 ;  //RD48  = 6?b0110010,
        6'b110011: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == RD64 "); return 0;  end else LNG_response = 5 ;  //RD64  = 6?b0110011,
        6'b110100: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == RD80 "); return 0;  end else LNG_response = 6 ;  //RD80  = 6?b0110100,
        6'b110101: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == RD96 "); return 0;  end else LNG_response = 7 ;  //RD96  = 6?b0110101,
        6'b110110: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == RD112"); return 0;  end else LNG_response = 8 ;  //RD112 = 6?b0110110,
        6'b110111: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == RD128"); return 0;  end else LNG_response = 9 ;  //RD128 = 6?b0110111,
        6'b101000: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == MD_RD"); return 0;  end else LNG_response = 2 ;  //MD_RD = 6?b0101000,  //MODE READ request

        //ARITHMETIC ATOMICS
        6'b010010:  if(LNG != 2) begin $display("fatal error LNG != 2 while CMD == Dual_ADD8  "); return 0;  end else begin LNG_response = 1 ; $display("CMD == Dual_ADD8  "); end//Dual_ADD8   = 6?b0010010,   //Dual 8-byte signed add immediate
        6'b010011:  if(LNG != 2) begin $display("fatal error LNG != 2 while CMD == ADD16      "); return 0;  end else begin LNG_response = 1 ; $display("CMD == ADD16      "); end//ADD16       = 6?b0010011,   //Single 16-byte signed add immediate
        6'b100010:  if(LNG != 2) begin $display("fatal error LNG != 2 while CMD == P_2ADD8    "); return 0;  end else begin LNG_response = 0 ; $display("CMD == P_2ADD8    "); end//P_2ADD8     = 6?b0100010,   //Posted dual 8-byte signed add immediate
        6'b100011:  if(LNG != 2) begin $display("fatal error LNG != 2 while CMD == P_ADD16    "); return 0;  end else begin LNG_response = 0 ; $display("CMD == P_ADD16    "); end//P_ADD16     = 6?b0100011,   //Posted single 16-byte signed add immediate
        6'b1010011: if(LNG != 2) begin $display("fatal error LNG != 2 while CMD == ADDS16R    "); return 0;  end else begin LNG_response = 2 ; $display("CMD == ADDS16R    "); end//ADDS16R     = 6?b1010011,   //Single 16-byte signed add immediate and return
        6'b1010000: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == INC8       "); return 0;  end else begin LNG_response = 1 ; $display("CMD == INC8       "); end//INC8        = 6?b1010000,   //8-byte increment
        6'b1010100: if(LNG != 1) begin $display("fatal error LNG != 1 while CMD == P_INC8     "); return 0;  end else begin LNG_response = 0 ; $display("CMD == P_INC8     "); end//P_INC8      = 6?b1010100,   //Posted 8-byte increment

        //BITWISE ATOMICS
        6'b010001: if(LNG != 2) begin $display("fatal error LNG != 2 while CMD == BWR   "); return 0;  end else begin LNG_response = 1 ; $display("CMD == BWR     "); end//BWR    = 6?b0010001, //8-byte bit write 
        6'b100001: if(LNG != 2) begin $display("fatal error LNG != 2 while CMD == P_BWR "); return 0;  end else begin LNG_response = 0 ; $display("CMD == P_BWR   "); end//P_BWR  = 6?b0100001, //Posted 8-byte bit write 

 
         default: begin $display("FATAL ERROR, CMD is not found in list of commands. "); return 0; end
    endcase

       return 1;
  endfunction

// function to set LNG based on the coming CMD.

  function automatic bit set_LNG_from_CMD(input bit [6:0] received_CMD , ref bit [ 4:0 ]  LNG );
    case (received_CMD) 
        // Write operations.
        6'b001000: begin LNG =2 ; LNG_response = 1; end  //WR16  = 6?b001000,   //16-byte WRITE request
        6'b001001: begin LNG =3 ; LNG_response = 1; end  //WR32  = 6?b001001,
        6'b001010: begin LNG =4 ; LNG_response = 1; end  //WR48  = 6?b001010,
        6'b001011: begin LNG =5 ; LNG_response = 1; end  //WR64  = 6?b001011,
        6'b001100: begin LNG =6 ; LNG_response = 1; end  //WR80  = 6?b001100,
        6'b001101: begin LNG =7 ; LNG_response = 1; end  //WR96  = 6?b001101,
        6'b001110: begin LNG =8 ; LNG_response = 1; end  //WR112 = 6?b001110,
        6'b001111: begin LNG =9 ; LNG_response = 1; end  //WR128 = 6?b001111,
        6'b010000: begin LNG =2 ; LNG_response = 1; end  //MD_WR = 6?b010000  //MODE WRITE request

        // Posted Write Request
        6'b011000: begin LNG =2 ; LNG_response = 0; end  //P_WR16  = 6?b011000,   //16-byte POSTED WRITErequest
        6'b011001: begin LNG =3 ; LNG_response = 0; end  //P_WR32  = 6?b011001,
        6'b011010: begin LNG =4 ; LNG_response = 0; end  //P_WR48  = 6?b011010,
        6'b011011: begin LNG =5 ; LNG_response = 0; end  //P_WR64  = 6?b011011,
        6'b011100: begin LNG =6 ; LNG_response = 0; end  //P_WR80  = 6?b011100,
        6'b011101: begin LNG =7 ; LNG_response = 0; end  //P_WR96  = 6?b011101,
        6'b011110: begin LNG =8 ; LNG_response = 0; end  //P_WR112 = 6?b011110,
        6'b011111: begin LNG =9 ; LNG_response = 0; end  //P_WR128 = 6?b011111,

        //READ Requests
        6'b110000: begin LNG =1; LNG_response = 2 ; end  //RD16  = 6?b110000,   //16-byte READ request
        6'b110001: begin LNG =1; LNG_response = 3 ; end  //RD32  = 6?b110001,
        6'b110010: begin LNG =1; LNG_response = 4 ; end  //RD48  = 6?b110010,
        6'b110011: begin LNG =1; LNG_response = 5 ; end  //RD64  = 6?b110011,
        6'b110100: begin LNG =1; LNG_response = 6 ; end  //RD80  = 6?b110100,
        6'b110101: begin LNG =1; LNG_response = 7 ; end  //RD96  = 6?b110101,
        6'b110110: begin LNG =1; LNG_response = 8 ; end  //RD112 = 6?b110110,
        6'b110111: begin LNG =1; LNG_response = 9 ; end  //RD128 = 6?b110111,
        6'b101000: begin LNG =1; LNG_response = 2 ; end  //MD_RD = 6?b101000,  //MODE READ request

        //ARITHMETIC ATOMICS
        6'b010010: begin LNG =2; LNG_response = 1; end //Dual_ADD8   = 6?b010010,   //Dual 8-byte signed add immediate
        6'b010011: begin LNG =2; LNG_response = 1; end //ADD16       = 6?b010011,   //Single 16-byte signed add immediate
        6'b100010: begin LNG =2; LNG_response = 0; end //P_2ADD8     = 6?b100010,   //Posted dual 8-byte signed add immediate
        6'b100011: begin LNG =2; LNG_response = 9; end //P_ADD16     = 6?b100011,   //Posted single 16-byte signed add immediate


        //BITWISE ATOMICS
        6'b010001: begin LNG =2; LNG_response = 1; end //BWR    = 6?b010001, //8-byte bit write 
        6'b100001: begin LNG =2; LNG_response = 0; end //P_BWR  = 6?b100001, //Posted 8-byte bit write 

 
         default: begin LNG =0; LNG_response = 0;  $display("FATAL ERROR, CMD is not found in list of commands. "); return 0; end
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


