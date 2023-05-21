class Sys_Sequence_Item extends uvm_sequence_item;
    
	
	 bit clk_user;
	 bit res_n_user;
	
	 bit clk_hmc;
	 bit res_n_hmc;
	
	`uvm_object_utils_begin(Sys_Sequence_Item )
	    `uvm_field_int(clk_user, UVM_DEFAULT | UVM_DEC)
            `uvm_field_int(res_n_user, UVM_DEFAULT | UVM_DEC)
            `uvm_field_int(clk_hmc, UVM_DEFAULT  | UVM_DEC)
            `uvm_field_int(res_n_hmc, UVM_DEFAULT  | UVM_DEC)
        `uvm_object_utils_end
	
	
	function new(string name = "Sys_Sequence_Item");
		super.new(name);
	endfunction
	
	
endclass: Sys_Sequence_Item
