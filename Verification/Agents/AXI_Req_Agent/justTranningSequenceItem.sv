typedef enum bit[1:0] { FIXED, INCR, WRAP } flit_addr_TYPE;
class pkt_hdr_tail;
rand bit [6:0]  CMD;   //Command
  rand bit [4:0]  LEN;   //Packet length
  rand bit [10:0] TAG;  
  rand bit [33:0] ADRS;  
  rand bit [2:0]  CUB;   //Cube ID
  
  //packet tail fields
 rand  bit [8:0]  RRP;          //Return retry pointer
   rand bit [8:0]  FRP;          //Forward retry pointer
   rand bit [2:0]  SEQ;          //Sequence number
  rand bit        poisb;        //Poison bit
  rand bit [2:0]  SLID;         //Source Link ID
   rand bit [2:0]  RTC;          //Return token count
   rand bit [31:0] CRC; 
endclass : pkt_hdr_tail
class transaction#(FPW=4) extends uvm_sequence_item;
`uvm_object_param_utils(transaction#(FPW));
 pkt_hdr_tail pKTHT;
PKTHT=new();
rand flit_addr_TYPE f_type;
   
//-----------
/*
rand bit [FPW*128-1:0] Tdata[][];//contain all parts related to data like hdr,tail ,data
rand bit [3*FPW-1:0] Tuser[];
rand bit [FPW-1:0]Valid_flit=Tuser[FPW-1:0];
rand bit [(2*FPW)-1:FPW]hdr_flit=Tuser[(2*FPW)-1:FPW];
rand bit [(3*FPW)-1:2*FPW]tail_flit=Tuser[(3*FPW)-1:2*FPW];
rand flit_addr_TYPE f_type;
//-------------------------------------------------
//constraints ----------------- 
constraint validity {Valid_flit < FPW;}
constraint hdr {hdr_flit < FPW;}
constraint tail {tail_flit < FPW;}
//poison bit 

*/
//-----------constructor-------- 
 function new(string name = "");
        super.new(name);
    endfunction: new
//------------docopy function --------------
function void do_copy(uvm_object rhs);// function imp outside class 
transaction copied_transaction_h;
 if(rhs == null) 
        `uvm_fatal("TRANSACTION", "Tried to copy from a null pointer")
if(!$cast(copied_transaction_h,rhs))
        `uvm_fatal("TRANSACTION", "Tried to copy wrong type.")
 super.do_copy(rhs); // copy all parent class data
PKTHT.CMD=copied_transaction_h.PKTHT.CMD;
PKTHT.LEN=copied_transaction_h.PKTHT.LEN;
PKTHT.TAG=copied_transaction_h.PKTHT.TAG;
PKTHT.ADRS=copied_transaction_h.PKTHT.ADRS;
PKTHT.CUB=copied_transaction_h.PKTHT.CUB;
PKTHT.RRP=copied_transaction_h.PKTHT.RRP;
PKTHT.SLID=copied_transaction_h.PKTHT.SLID;
PKTHT.RTC=copied_transaction_h.PKTHT.RTC;
PKTHT.CRC=copied_transaction_h.PKTHT.CRC;
f_type =copied_transaction_h.f_type; 

endfunction : do_copy
//---------------- clone------------
function transaction clone_me();
tranaction clone();
uvm_object tmp;
tmp=this.clone();
$cast(clone,tmp);
return clone;
endfunction : clone_me


//--------do_compare----------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      transaction compared_transaction_h;
      bit   same;
      
      if (rhs==null) `uvm_fatal("RANDOM TRANSACTION", 
                                "Tried to do comparison to a null pointer");
      
      if (!$cast(compared_transaction_h,rhs))
        same = 0;
      else
        same = super.do_compare(rhs, comparer) ;
	do_compare &= (
               (compared_transaction_h.PKTHT.CMD == PKTHT.CMD) &&
                (compared_transaction_h.PKTHT.LEN == PKTHT.LEN) &&
               (compared_transaction_h.PKTHT.TAG == PKTHT.TAG)&&
	        (compared_transaction_h.PKTHT.ADRS == PKTHT.ADRS) &&
               (compared_transaction_h.PKTHT.CUB == PKTHT.CUB) &&
               (compared_transaction_h.PKTHT.RRP == PKTHT.RRP)&&
		(compared_transaction_h.PKTHT.SLID == PKTHT.SLID)&&
		(compared_transaction_h.PKTHT.RTC == PKTHT.RTC)&&
                (compared_transaction_h.f_type==f_type)&&
		(compared_transaction_h.PKTHT.CRC == PKTHT.CRC));        
      return same;
   endfunction : do_compare
//----------convert2string---------
function string convert2string();
      string s;
	s = super.convert2string();
	 s = {s,$sformatf("CUB             :   %0d\n", PKTHT.CUB)};
	 s={s,$sformatf("LEN           : %0d\n",PKTHT. LEN)};
	 s={s,$sformatf("Addr           : 0x%0h\n", PKTHT.ADRS)};
	 s={s,$sformatf("RRP          : %0d\n",PKTHT.RRP)};
 	s={s,$sformatf("FRP           : 0x%0h\n",PKTHT.FRP)};
	 s={s,$sformatf("Tdata           : 0x%0h\n", Tdata)};
	 s={s,$sformatf("tuser           : 0x%0h\n", tuser)};
	s={s,$sformatf("flit Type     :   %s\n", f_type.name())};
      return s;
   endfunction : convert2string
function transaction clone_me();
      transaction clone;
      uvm_object tmp;
      tmp = this.clone();
      $cast(clone, tmp);
      return clone;
   endfunction : clone_me
endclass : transaction

