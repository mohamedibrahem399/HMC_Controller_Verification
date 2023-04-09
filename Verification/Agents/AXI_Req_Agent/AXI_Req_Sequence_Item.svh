`include "CMD_DATA_TYPES_SVH.svh"

class AXI_Req_Sequence_Item extends uvm_sequence_item;
  
  //Packet Header
  rand bit Req_Command  CMD;   //Command
	rand bit [3:0]  LNG;   //Packet length
	rand bit [3:0] DLN;
	randc bit [8:0] TAG;  
  rand bit [33:0] ADRS;  
  rand bit [2:0]  CUB;   //Cube ID
  
  //Packet tail fields
  bit [7:0]  RRP;          //Return retry pointer
  bit [7:0]  FRP;          //Forward retry pointer
  bit [2:0]  SEQ;          //Sequence number
  //bit        poisb;        //Poison bit
  bit [2:0]  SLID;         //Source Link ID
  bit [4:0]  RTC;          //Return token coun
  bit [31:0] CRC;          //Cyclic redundancy check
  
  //Do all operation of do_copy(),do_compare(),do_print()
 
  `uvm_object_utils_begin(AXI_Req_Sequence_Item)
    `uvm_field_enum(REQ_Command, CMD, UVM_DEFAULT)
    `uvm_field_int(LNG, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(DLN, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(TAG, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(ADRS, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(CUB, UVM_DEFAULT  | UVM_DEC)
    
    `uvm_field_int(RRP, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(FRP, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(SEQ, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(SLID, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(RTC, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(CRC, UVM_DEFAULT  | UVM_DEC)
	`uvm_object_utils_end

	
  
  // Packet Length Constraint
  constraint Packet_Len{
    LNG inside {[1:9]};
    DLN == LNG;
    
    LNG == 1 <-> CMD inside{[RD16 : RD128], MD_RD};
    LNG == 2 <-> CMD inside{[P_BWR : P_ADD16], P_WR16, [MD_WR : ADD16], WR16};
    LNG == 3 <-> CMD inside{WR32,P_WR32};
    LNG == 4 <-> CMD inside{WR48,P_WR48};
    LNG == 5 <-> CMD inside{WR64,P_WR64};
    LNG == 6 <-> CMD inside{WR80,P_WR80};
    LNG == 7 <-> CMD inside{WR96,P_WR96};
    LNG == 8 <-> CMD inside{WR112,P_WR112};
    LNG == 9 <-> CMD inside{WR128,P_WR128};
  }
  
function new(string name = "AXI_Req_Sequence_Item");
		super.new(name);
	endfunction

     

endclass
