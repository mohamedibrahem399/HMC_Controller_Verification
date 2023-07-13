class HMC_Mem_Init_Sequence extends uvm_sequence;
    `uvm_object_utils(HMC_Mem_Init_Sequence)

    HMC_Rsp_Sequence_item hmc_item;

    // Constructor
    function new (string name = "HMC_Mem_Init_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    // Body method
    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        hmc_item = HMC_Rsp_Sequence_item::type_id::create("hmc_item");
        start_item(hmc_item);
        assert(hmc_item.randomize());
        finish_item(hmc_item);
    endtask :body
endclass :HMC_Mem_Init_Sequence