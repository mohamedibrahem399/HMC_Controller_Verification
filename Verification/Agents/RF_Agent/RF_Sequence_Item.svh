class RF_Sequence_Item #(parameter HMC_RF_WWIDTH= 64, HMC_RF_RWIDTH= 64, HMC_RF_AWIDTH= 4) extends uvm_sequence_item;
    rand bit [HMC_RF_WWIDTH-1:0] rf_write_data;
    rand bit [HMC_RF_AWIDTH-1:0] rf_address;
    rand bit rf_write_en;
    rand bit rf_read_en;

    bit [HMC_RF_RWIDTH-1:0]rf_read_data;
    bit rf_invalid_address;
    bit rf_access_complete;

    `uvm_object_utils_begin(RF_Sequence_Item)
        `uvm_field_int(rf_write_data, UVM_ALL_ON)
        `uvm_field_int(rf_address   , UVM_ALL_ON)
        `uvm_field_int(rf_write_en  , UVM_ALL_ON)
        `uvm_field_int(rf_read_en   , UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name= "RF_Sequence_Item");
        super.new(name);
    endfunction: new

endclass: RF_Sequence_Item