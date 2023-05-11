`include "CMD_DATA_TYPES_RES_SVH.svh"
class AXI_Rsp_Sequence_Item extends uvm_sequence_item;
  
  //Packet Header
  rand Rsp_Command  CMD;   //Command
  rand bit [3:0]  LNG;         //Packet length
  bit [3:0]  DLN;         //Duplicate of packet length field
  randc bit [8:0] TAG;  
  
  //Packet tail fields
  bit [7:0]  RRP;          //Return retry pointer
  bit [7:0]  FRP;          //Forward retry pointer
  bit [2:0]  SEQ;          //Sequence number
  bit        DINV;         //Data invalid
  bit [6:0]  ERRSTAT;       //Error status
  bit [4:0]  RTC;          //Return token coun
  bit [31:0] CRC;          //Cyclic redundancy check	
  //Data
  rand bit[63:0] data[$];	
   rand bit TREADY;
  
   //Do all operation of do_copy(),do_compare(),do_print()
  `uvm_object_utils_begin(AXI_Rsp_Sequence_Item)
    `uvm_field_int(TREADY, UVM_DEFAULT  | UVM_DEC)
  `uvm_field_enum(Rsp_Command, CMD, UVM_DEFAULT)
    `uvm_field_int(LNG, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(TAG, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(DLN, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(RRP, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(FRP, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(SEQ, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(DINV, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(ERRSTAT, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(RTC, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_int(CRC, UVM_DEFAULT  | UVM_DEC)
    `uvm_field_queue_int(data, UVM_DEFAULT  | UVM_DEC)
    `uvm_object_utils_end
  
  function new(string name = "AXI_Rsp_Sequence_Item");
		super.new(name);
	endfunction
	
  constraint RX_TREADY{
        TREADY dist {0:=20, 1:=80};}
  
endclass: AXI_Rsp_Sequence_Item
