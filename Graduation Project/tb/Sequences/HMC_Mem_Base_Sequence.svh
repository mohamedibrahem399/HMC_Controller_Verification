class HMC_Mem_Base_Sequence extends uvm_sequence;
    `uvm_object_utils(HMC_Mem_Base_Sequence)

    `uvm_declare_p_sequencer(HMC_Mem_Sequencer)

    HMC_Rsp_Sequence_item Rsp_item;
    HMC_Rsp_Sequence_item item;

    function new(string name = "HMC_Mem_Base_Sequence");
        super.new(name);
        `uvm_info("Base_SEQ", "Inside Constructor!", UVM_HIGH)
    endfunction: new

    task body();
        `uvm_info("Base_SEQ","body", UVM_HIGH)
        Rsp_item = HMC_Rsp_Sequence_item::type_id::create("Rsp_item");

        p_sequencer.HMC_Mem_Analysis_TLM_FIFO.get(item);

        start_item(Rsp_item);
        Rsp_item = item;
        finish_item(Rsp_item);

    endtask: body
endclass: HMC_Mem_Base_Sequence