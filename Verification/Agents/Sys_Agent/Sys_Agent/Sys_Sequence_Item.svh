class Sys_Sequence_Item extends uvm_sequence_item;
    rand bit clk_user;
    rand bit clk_hmc;
    rand bit res_n_user;
    rand bit res_n_hmc;

    `uvm_object_utils_begin(Sys_Sequence_Item)
        `uvm_field_int(clk_user, UVM_ALL_ON)
        `uvm_field_int(clk_hmc, UVM_ALL_ON)
        `uvm_field_int(res_n_user, UVM_ALL_ON)
        `uvm_field_int(res_n_hmc, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new (string name = "Sys_Sequence_Item");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction :new

endclass: Sys_Sequence_Item
