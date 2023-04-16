`include "HMC_Mem_Types.svh"
   
class HMC_Rsp_Sequence_item extends uvm_sequence_item;
    //response packet header
    rand  bit [21:0] RES1;    // Reserved               [63:42]
    rand  bit [2 :0] SLID;    // Source Link ID         [41:39]
    rand  bit [5 :0] RES2;    // Reserved               [38:33] 
    rand  bit [8 :0] RTN_TAG; // Return tag (optional)  [32:24]
    randc bit [8 :0] TAG;     // Tag number             [23:15]
    rand  bit [3 :0] DLN;     // Duplicate length       [14:11]
    rand  bit [3 :0] LNG;     // Packet length in FLITS [10:7]
    rand  bit        RES3;    // Reserved               [6]
    rand  CMD_Rsp_t  CMD;     // Packet command         [5:0]   

    //response pascket data
    rand bit[63:0] data[$];

    //response packet tail
    rand bit [31:0] CRC;     // Cyclic redundancy check [63:32]
    rand bit [4 :0] RTC;     // Return token counts     [31:27]
    rand bit [6 :0] ERRSTAT; // Error status            [26:20]
    rand bit        DINV;    // Data Invalid            [19]
    rand bit [2 :0] SEQ;     // Sequence number         [18:16] 
    rand bit [7 :0] FRP;     // Forward retry pointer   [15:8]
    rand bit [7 :0] RRP;     // Return retry pointer    [7:0]

    `uvm_object_utils_begin(HMC_Rsp_Sequence_item)
        //response packet header
        `uvm_field_int(RES1,      UVM_ALL_ON)
        `uvm_field_int(SLID,      UVM_ALL_ON)
        `uvm_field_int(RES2,      UVM_ALL_ON)
        `uvm_field_int(RTN_TAG,   UVM_ALL_ON)
        `uvm_field_int(TAG,       UVM_ALL_ON)
        `uvm_field_int(DLN,       UVM_ALL_ON)
        `uvm_field_int(LNG,       UVM_ALL_ON)
        `uvm_field_int(RES3,      UVM_ALL_ON)
        `uvm_field_enum(CMD_Rsp_t,CMD,UVM_ALL_ON)
        //response pascket data
        `uvm_field_queue_int(data, UVM_ALL_ON)
        //response packet tail
        `uvm_field_int(CRC,       UVM_ALL_ON)
        `uvm_field_int(RTC,       UVM_ALL_ON)
        `uvm_field_int(ERRSTAT,   UVM_ALL_ON)
        `uvm_field_int(DINV,      UVM_ALL_ON)
        `uvm_field_int(SEQ,       UVM_ALL_ON)
        `uvm_field_int(FRP,       UVM_ALL_ON)
        `uvm_field_int(RRP,       UVM_ALL_ON)
    `uvm_object_utils_end

     function new(string name = "HMC_Rsp_Sequence_item");
        super.new(name);
     endfunction: new
       
    // constraints
    constraint c_reserved        {RES1 ==0; RES2 ==0; RES3 ==0;}
    constraint c_source_link_ID  {SLID ==0;}
    constraint c_return_tag      {RTN_TAG ==0; LNG inside {[1:9]};}
    constraint c_match_length    {LNG == DLN; LNG inside {[1:9]};}
    constraint c_commands        {LNG == 1 <-> CMD inside{WR_RS, MD_WR_RS, ERROR};
                                  LNG == 2 <-> CMD inside{RD_RS, MD_RD_RS};
                                  LNG == 3 <-> CMD inside{RD_RS}; 
                                  LNG == 4 <-> CMD inside{RD_RS};
                                  LNG == 5 <-> CMD inside{RD_RS};
                                  LNG == 6 <-> CMD inside{RD_RS};
                                  LNG == 7 <-> CMD inside{RD_RS};
                                  LNG == 8 <-> CMD inside{RD_RS};
                                  LNG == 9 <-> CMD inside{RD_RS};}
    constraint c_data{  if(LNG <= 2)
                            data.size == (LNG-1)*2;
                        else 
                            data.size == (LNG-2)*2 + 2;}

endclass: HMC_Rsp_Sequence_item
