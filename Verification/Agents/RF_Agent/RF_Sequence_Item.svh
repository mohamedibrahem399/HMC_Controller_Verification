class RF_Sequence_Item extends uvm_sequence_item;
    rand bit [63:0] rf_write_data;
    rand bit [3:0] rf_address;
    rand bit rf_write_en;
    rand bit rf_read_en;

    bit [63:0]rf_read_data;
    bit rf_invalid_address;
    bit rf_access_complete;

    `uvm_object_utils_begin(RF_Sequence_Item)
        `uvm_field_int(rf_write_data, UVM_ALL_ON)
        `uvm_field_int(rf_address   , UVM_ALL_ON)
        `uvm_field_int(rf_write_en  , UVM_ALL_ON)
        `uvm_field_int(rf_read_en   , UVM_ALL_ON)
        
        `uvm_field_int(rf_read_data   , UVM_ALL_ON)
        `uvm_field_int(rf_invalid_address   , UVM_ALL_ON)
        `uvm_field_int(rf_access_complete   , UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name= "RF_Sequence_Item");
        super.new(name);
        `uvm_info(get_type_name(), $sformatf("%m"), UVM_NONE)
    endfunction: new

endclass: RF_Sequence_Item
