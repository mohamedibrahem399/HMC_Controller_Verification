class Sys_Sequence extends uvm_sequence;
  `uvm_object_utils(Sys_Sequence)
   Sys_Sequence_Item  seq_item;
	
  function new (string name = "Sys_Sequence");
         super.new(name);
     endfunction: new
	 
	task body;

      seq_item=Sys_Sequence_Item::type_id::create("seq_item",this);
      start_item(seq_item);
	  
       seq_item.clk_user=1;
       seq_item.clk_hmc=1;
       seq_item.res_n_user=0;
       seq_item.res_n_hmc=0;
	   
      finish_item(seq_item);
      
	endtask: body
	
endclass: Sys_Sequence
