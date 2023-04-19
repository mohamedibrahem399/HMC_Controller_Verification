class HMC_Mem_Sequencer extends uvm_sequencer #(HMC_Rsp_Sequence_item);
    `uvm_component_utils(HMC_Mem_Sequencer)

    // TLM analysis port from storage to sequencer
    uvm_analysis_export#(HMC_Rsp_Sequence_item ) HMC_Mem_Analysis_Storage_Sequencer_Export;     
    uvm_tlm_analysis_fifo #(HMC_Rsp_Sequence_item) HMC_Mem_Analysis_TLM_FIFO;

    // Constructor
    function new(string name = "HMC_Mem_Sequencer", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SQR_CLASS", "Inside Constructor!", UVM_HIGH)

        HMC_Mem_Analysis_Storage_Sequencer_Export = new("HMC_Mem_Analysis_Storage_Sequencer_Export", this);
        HMC_Mem_Analysis_TLM_FIFO = new("HMC_Mem_Analysis_TLM_FIFO", this);
    endfunction: new

    // Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SQR_CLASS", "Connet Phase!", UVM_HIGH)

        HMC_Mem_Analysis_Storage_Sequencer_Export.connect(HMC_Mem_Analysis_TLM_FIFO.analysis_export);
    endfunction: connect_phase

endclass: HMC_Mem_Sequencer
