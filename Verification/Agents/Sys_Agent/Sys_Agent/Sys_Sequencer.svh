class Sys_Sequencer extends uvm_sequencer #(Sys_Sequence_Item);
    `uvm_component_utils (Sys_Sequencer)

    //Constructor
    function new(string name = "Sys_Sequencer", uvm_component parent);
        super.new(name, parent);
      `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new
    
endclass :Sys_Sequencer
