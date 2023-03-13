class RF_Sequence extends uvm_sequence;
    `uvm_object_utils(RF_Sequence)

    RF_Sequence_Item item;

    function new(string name= "RF_Sequence");
        super.new(name);
        `uvm_info("BASE_SEQ", "Inside Constructor!", UVM_HIGH)
    endfunction

    task body();
        `uvm_info("BASE_SEQ", "Inside body task!", UVM_HIGH)
        item = RF_Sequence_Item::type_id::create("item");
        start_item(item);
        assert(item.randomize());
        finish_item(item);
    endtask: body
endclass: RF_Sequence


class RF_Write_Sequence extends RF_Sequence;
    `uvm_object_utils(RF_Write_Sequence)

    RF_Sequence_Item item_w;

    function new(string name= "RF_Write_Sequence");
        super.new(name);
        `uvm_info("WRITE_SEQ", "Inside Constructor!", UVM_HIGH)
    endfunction

    task body();
        `uvm_info("WRITE_SEQ", "Inside body task!", UVM_HIGH)
        item_w = RF_Sequence_Item::type_id::create("item_w");
        start_item(item_w);
        assert(item_w.randomize()with{rf_write_en==1; rf_read_en==0; rf_address==2;});
        finish_item(item_w);
    endtask: body
endclass: RF_Write_Sequence

class RF_Read_Sequence extends RF_Sequence;
    `uvm_object_utils(RF_Read_Sequence)

    RF_Sequence_Item item_r;

    function new(string name= "RF_Read_Sequence");
        super.new(name);
        `uvm_info("READ_SEQ", "Inside Constructor!", UVM_HIGH)
    endfunction

    task body();
        `uvm_info("READ_SEQ", "Inside body task!", UVM_HIGH)
        item_r = RF_Sequence_Item::type_id::create("item_r");
        start_item(item_r);
        assert(item_r.randomize()with{rf_write_en==0; rf_read_en==1;});
        finish_item(item_r);
    endtask: body
endclass: RF_Read_Sequence