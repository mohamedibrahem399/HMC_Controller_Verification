class HMC_Mem_Sequencer extends uvm_sequencer #(HMC_Rsp_Sequence_item);
    `uvm_component_utils(HMC_Mem_Sequencer)

    uvm_analysis_export#(HMC_Rsp_Sequence_item ) stg2sqr_export;     
    uvm_tlm_analysis_fifo #(HMC_Rsp_Sequence_item) HMC_Mem_Analysis_TLM_FIFO;

    function new(string name = "HMC_Mem_Sequencer", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SQR_CLASS", "Inside Constructor!", UVM_HIGH)

        stg2sqr_export = new("stg2sqr_export", this);
        HMC_Mem_Analysis_TLM_FIFO = new("HMC_Mem_Analysis_TLM_FIFO", this);
    endfunction: new

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SQR_CLASS", "Connet Phase!", UVM_HIGH)

        stg2sqr_export.connect(HMC_Mem_Analysis_TLM_FIFO.analysis_export);
    endfunction: connect_phase

endclass: HMC_Mem_Sequencer