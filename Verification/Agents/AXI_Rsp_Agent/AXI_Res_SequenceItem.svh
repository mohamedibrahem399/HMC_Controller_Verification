class AXI_Res_SequenceItem extends uvm_sequence_item;
   
   `uvm_object_utils(AXI_Res_SequenceItem)
   rand bit TREADY;
   
   constraint RX_TREADY{
        TREADY dist {0:=20, 1:=80};}
//////////////////////////////constructor/////////////////////////
    function new(string name="AXI_Res_Sequence_Item");
       super.new(name);
    endfunction: new
	
 endclass: AXI_Res_SequenceItem
