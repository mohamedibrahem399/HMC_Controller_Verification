class RF_Sequencer extends uvm_sequencer #(RF_Sequence_Item);
    `uvm_component_utils(RF_Sequencer)

    //Constructor
    function new(string name = "RF_Sequencer", uvm_component parent);
        super.new(name, parent);
      `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
      endfunction: new

    //Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)
    endfunction: build_phase

    //Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connect Phase!", UVM_NONE)
    endfunction: connect_phase
endclass: RF_Sequencer
