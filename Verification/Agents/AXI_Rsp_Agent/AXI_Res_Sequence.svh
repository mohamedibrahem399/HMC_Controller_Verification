class AXI_Res_Sequence extends uvm_sequence#(AXI_Res_SequenceItem);
    `uvm_object_utils(AXI_Res_Sequence)
     function new (string name = "AXI_Res_Sequence");
         super.new(name);
     endfunction: new
	task body;
	   AXI_Res_SequenceItem  res_seq_item;
	   res_seq_item=AXI_Res_SequenceItem::type_id::create("res_seq_item",this);
	   start_item(res_seq_item);
	   assert(res_seq_item.randomize());
	   finish_item(res_seq_item);
	endtask: body
endclass: AXI_Res_Sequence
