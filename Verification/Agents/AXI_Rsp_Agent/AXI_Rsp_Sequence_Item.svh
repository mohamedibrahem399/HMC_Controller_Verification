class AXI_Rsp_Sequence_Item extends uvm_sequence_item;
   
   rand bit TREADY;
	
     `uvm_object_utils_begin(AXI_Rsp_Sequence_Item)
	   `uvm_field_int(TREADY, UVM_DEFAULT  | UVM_DEC)
     `uvm_object_utils_end
	
   constraint RX_TREADY{
        TREADY dist {0:=20, 1:=80};}
	
//////////////////////////////constructor/////////////////////////
  function new(string name = "AXI_Rsp_Sequence_Item");
		super.new(name);
  endfunction
	
 
  
endclass: AXI_Rsp_Sequence_Item
