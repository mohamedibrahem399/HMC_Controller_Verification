
class AXI_Rsp_Sequence extends uvm_sequence;
  `uvm_object_utils(AXI_Rsp_Sequence)
   AXI_Rsp_Sequence_Item  rsp_seq_item;
  function new (string name = "AXI_Rsp_Sequence");
         super.new(name);
     endfunction: new
	 
	task body;

      rsp_seq_item=AXI_Rsp_Sequence_Item::type_id::create("rsp_seq_item",this);
      start_item(rsp_seq_item);
      assert(rsp_seq_item.randomize());
      finish_item(rsp_seq_item);
      
	endtask: body
	
endclass: AXI_Rsp_Sequence
