`include "HMC_Mem_Types.svh"

class HMC_Req_Sequence_item extends uvm_sequence_item;
    //request packet header
    rand  bit [2:0]  CUB;   //Cube ID                [63:61]
    rand  bit [2:0]  RES1;  // Reserved              [60:58] 
    rand  bit [33:0] ADRS;  // Address               [57:24]
    randc bit [8:0]  TAG;   // Tag                   [23:15] 
    rand  bit [3:0]  DLN;   // Duplicate length      [14:11]
    rand  bit [3:0]  LNG;   // Packet length         [10:7]
    rand  bit        RES2;  // Reserved              [6]
    rand  CMD_Req_t  CMD;   // Command               [5:0]
    
    //request packet data
    rand bit[63:0] data[$];
    
    //request packet tail
    rand bit [31:0] CRC;   //Cyclic redundancy check [63:32]
    rand bit [4:0]  RTC;   //Return token count      [31:27]      
    rand bit [2:0]  SLID;  //Source Link ID          [26:24] 
    rand bit [4:0]  RES3;  // Reserved               [23:19] 
    rand bit [2:0]  SEQ;   //Sequence number         [18:16]
    rand bit [7:0]  FRP;   //Forward retry pointer   [15:8]
    rand bit [7:0]  RRP;   //Return retry pointer    [7:0]
     
    
    `uvm_object_utils_begin(HMC_Req_Sequence_item )
        //request packet header
        `uvm_field_int(CUB,      UVM_ALL_ON)
        `uvm_field_int(RES1,     UVM_ALL_ON)
        `uvm_field_int(ADRS,     UVM_ALL_ON)
        `uvm_field_int(TAG,      UVM_ALL_ON)
        `uvm_field_int(DLN,      UVM_ALL_ON)
        `uvm_field_int(LNG,      UVM_ALL_ON)
        `uvm_field_int(RES2,     UVM_ALL_ON)
        `uvm_field_enum(CMD_Req_t, CMD, UVM_ALL_ON)
        //request packet data
        `uvm_field_queue_int(data, UVM_ALL_ON)
        //request packet tail
        `uvm_field_int(CRC,      UVM_ALL_ON)
        `uvm_field_int(RTC,      UVM_ALL_ON)
        `uvm_field_int(SLID,     UVM_ALL_ON)
        `uvm_field_int(RES3,     UVM_ALL_ON)
        `uvm_field_int(SEQ,      UVM_ALL_ON)
        `uvm_field_int(FRP,      UVM_ALL_ON)
        `uvm_field_int(RRP,      UVM_ALL_ON)
	`uvm_object_utils_end

    function new(string name = "HMC_Req_Sequence_item");
        super.new(name);
    endfunction: new

    // constraints
    constraint c_reserved        {RES1==0; RES2 ==0; RES3 ==0;}
    constraint c_match_length    {LNG == DLN;  LNG inside {[1:9]};}
    constraint c_commands        {LNG == 1 <-> CMD inside{[RD16 : RD128]};
                                  LNG == 2 <-> CMD inside{WR16, TWO_ADD8 , ADD16, P_WR16, [P_TWO_ADD8 : P_ADD16]};
                                  LNG == 3 <-> CMD inside{WR32, P_WR32}; 
                                  LNG == 4 <-> CMD inside{WR48, P_WR48};
                                  LNG == 5 <-> CMD inside{WR64, P_WR64};
                                  LNG == 6 <-> CMD inside{WR80, P_WR80};
                                  LNG == 7 <-> CMD inside{WR96, P_WR96};
                                  LNG == 8 <-> CMD inside{WR112, P_WR112};
                                  LNG == 9 <-> CMD inside{WR128, P_WR128};}
    constraint c_source_link_ID  {SLID ==0;}
    
    constraint c_data{  if(LNG <= 2)
                            data.size == (LNG-1)*2;
                        else 
                            data.size == (LNG-2)*2 + 2;}

    // signals for making full packet..
    bit [127 :0]  packet[]    ;
    bit [63  :0]  flit_tail   ;
    bit [63  :0]  flit_header ;
    // sleep mode signals..
    bit           LXRXPS      ;
    bit           LXTXPS      ;
    assign LXTXPS = LXRXPS;
    
    // all those functions can be used directly using this function.

    task  extract_request_packet_header_and_tail();
                    bit[63:0] temp;
                    {flit_tail ,temp}   = packet[LNG-1];
                    {temp ,flit_header} = packet[0];
                    fill_tail__from_request_flit(flit_tail);
                    fill_header_from_request_flit(flit_header);
    endtask:extract_request_packet_header_and_tail

    task fill_tail__from_request_flit(input bit[63:0] flit_tail);
            // CRC , RTC , SLID , SEQ , FRP , RRP
            RRP =flit_tail[7 :0 ];
            FRP =flit_tail[15:8 ];
            SEQ =flit_tail[18:16];
            SLID=flit_tail[26:24];
            RTC =flit_tail[31:27];
            CRC =flit_tail[63:32];
    endtask : fill_tail__from_request_flit

    // header -> fill from or into flit header functions

    task fill_header_from_request_flit(input bit[63:0] flit_header);
            // CMD , LNG , DLN , TAG , ADRS , CUB
            // CMD   = flit_header[ 5:0 ];
            LNG   = flit_header[10:7 ];
            DLN   = flit_header[14:11];
            TAG   = flit_header[23:15];
            ADRS  = flit_header[57:24];
            CUB   = flit_header[63:61];
    endtask : fill_header_from_request_flit

    // function to set LNG based on the coming CMD.

    function automatic bit set_LNG_from_CMD(input bit [6:0] received_CMD , ref bit [ 4:0 ]  LNG );
        case (received_CMD) 
            // Write operations.
            6'b001000: LNG =2 ;  //WR16  = 6?b001000,   //16-byte WRITE request
            6'b001001: LNG =3 ;  //WR32  = 6?b001001,
            6'b001010: LNG =4 ;  //WR48  = 6?b001010,
            6'b001011: LNG =5 ;  //WR64  = 6?b001011,
            6'b001100: LNG =6 ;  //WR80  = 6?b001100,
            6'b001101: LNG =7 ;  //WR96  = 6?b001101,
            6'b001110: LNG =8 ;  //WR112 = 6?b001110,
            6'b001111: LNG =9 ;  //WR128 = 6?b001111,
            6'b010000: LNG =2 ;  //MD_WR = 6?b010000  //MODE WRITE request

            // Posted Write Request
            6'b011000: LNG =2 ;  //P_WR16  = 6?b011000,   //16-byte POSTED WRITErequest
            6'b011001: LNG =3 ;  //P_WR32  = 6?b011001,
            6'b011010: LNG =4 ;  //P_WR48  = 6?b011010,
            6'b011011: LNG =5 ;  //P_WR64  = 6?b011011,
            6'b011100: LNG =6 ;  //P_WR80  = 6?b011100,
            6'b011101: LNG =7 ;  //P_WR96  = 6?b011101,
            6'b011110: LNG =8 ;  //P_WR112 = 6?b011110,
            6'b011111: LNG =9 ;  //P_WR128 = 6?b011111,

            //READ Requests
            6'b110000: LNG =1;   //RD16  = 6?b110000,   //16-byte READ request
            6'b110001: LNG =1;   //RD32  = 6?b110001,
            6'b110010: LNG =1;   //RD48  = 6?b110010,
            6'b110011: LNG =1;   //RD64  = 6?b110011,
            6'b110100: LNG =1;   //RD80  = 6?b110100,
            6'b110101: LNG =1;   //RD96  = 6?b110101,
            6'b110110: LNG =1;   //RD112 = 6?b110110,
            6'b110111: LNG =1;   //RD128 = 6?b110111,
            6'b101000: LNG =1;   //MD_RD = 6?b101000,  //MODE READ request

            //ARITHMETIC ATOMICS
            6'b010010: LNG =2;  //Dual_ADD8   = 6?b010010,   //Dual 8-byte signed add immediate
            6'b010011: LNG =2;  //ADD16       = 6?b010011,   //Single 16-byte signed add immediate
            6'b100010: LNG =2;  //P_2ADD8     = 6?b100010,   //Posted dual 8-byte signed add immediate
            6'b100011: LNG =2;  //P_ADD16     = 6?b100011,   //Posted single 16-byte signed add immediate

            //BITWISE ATOMICS
            6'b010001: LNG =2;  //BWR    = 6?b010001, //8-byte bit write 
            6'b100001: LNG =2;  //P_BWR  = 6?b100001, //Posted 8-byte bit write 

            default: begin LNG =0;  $display("FATAL ERROR, CMD is not found in list of commands. "); return 0; end
        endcase
        return 1;
    endfunction:set_LNG_from_CMD

endclass: HMC_Req_Sequence_item