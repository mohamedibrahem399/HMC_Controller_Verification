`include "CMD_DATA_TYPES_SVH.svh"

class Req_Packet extends uvm_sequence_item;
  
  
  //Packet Header
  rand bit REQ_Command  CMD;   //Command
  rand bit [4:0]  LEN;   //Packet length
  randc bit [10:0] TAG;  
  rand bit [33:0] ADRS;  
  rand bit [2:0]  CUB;   //Cube ID
  
  //Packet tail fields
  bit [8:0]  RRP;          //Return retry pointer
  bit [8:0]  FRP;          //Forward retry pointer
  bit [2:0]  SEQ;          //Sequence number
  bit        poisb;        //Poison bit
  bit [2:0]  SLID;         //Source Link ID
  bit [2:0]  RTC;          //Return token coun
  bit [31:0] CRC;          //Cyclic redundancy check
  
  
  
  
  // Packet Length Constraint
  constraint Packet_Len{
    LEN inside {[1:9],17};
    
    LEN == 1 <-> CMD inside{[RD16:RD128],RD256,MD_RD,INC8,P_INC8};
    LEN == 2 <-> CMD inside{WR16,MD_WR,P_WR16,Dual_ADD8,ADD16,P_2ADD8,P_ADD16,Dual_ADDS8R,ADDS16R,
                            [XOR16:NAND16],[CASGT8:CASZERO16],[EQ16:SWAP16],BWR,P_BWR,BWR8R};
    LEN == 3 <-> CMD inside{WR32,P_WR32};
    LEN == 4 <-> CMD inside{WR48,P_WR48};
    LEN == 5 <-> CMD inside{WR64,P_WR64};
    LEN == 6 <-> CMD inside{WR80,P_WR80};
    LEN == 7 <-> CMD inside{WR96,P_WR96};
    LEN == 8 <-> CMD inside{WR112,P_WR112};
    LEN == 9 <-> CMD inside{WR128,P_WR128};
    LEN == 17 <-> CMD inside{WR256,P_WR256};
  }
  

  
   

endclass
