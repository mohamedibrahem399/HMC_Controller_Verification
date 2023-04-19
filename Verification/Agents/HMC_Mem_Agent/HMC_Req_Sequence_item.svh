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

endclass: HMC_Req_Sequence_item
