
class AXI_Rsp_Sequence extends uvm_sequence;
  `uvm_object_utils(AXI_Rsp_Sequence)
 
   AXI_Rsp_Sequence_Item  axi_rsp_item;
   
  function new (string name = "AXI_Rsp_Sequence");
    super.new(name);
  endfunction: new
  
  task body();
	axi_rsp_item = AXI_Rsp_Sequence_Item::type_id::create("axi_rsp_item");
	start_item(axi_rsp_item);
	assert(axi_rsp_item.randomize());
	finish_item(axi_rsp_item);  
  endtask: body
	
endclass: AXI_Rsp_Sequence

