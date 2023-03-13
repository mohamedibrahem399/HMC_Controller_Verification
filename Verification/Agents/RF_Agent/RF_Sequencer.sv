class RF_Sequencer extends uvm_sequencer #(RF_Sequence_Item);
    `uvm_component_utils(RF_Sequencer)

    function new(string name = "RF_Sequencer", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SEQR_CLASS", "Inside Constructor!", UVM_HIGH)
      endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SEQR_CLASS", "Build Phase!", UVM_HIGH)
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SEQR_CLASS", "Connect Phase!", UVM_HIGH)
    endfunction: connect_phase

endclass: RF_Sequencer