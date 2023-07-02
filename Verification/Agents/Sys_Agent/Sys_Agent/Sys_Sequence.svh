class Sys_Sequence extends uvm_sequence;
    `uvm_object_utils(Sys_Sequence)

    Sys_Sequence_Item sys_item;

    // Constructor
    function new (string name = "Sys_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    // Body method
    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        sys_item = Sys_Sequence_Item::type_id::create("sys_item");
        start_item(sys_item);
        assert(sys_item.randomize());
        finish_item(sys_item);
    endtask :body
endclass :Sys_Sequence
