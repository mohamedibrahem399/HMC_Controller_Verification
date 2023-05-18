class RF_Env extends uvm_env;
    `uvm_component_param_utils(RF_Env)

    RF_Agent  agnt;

    function new(string name = "RF_Env", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)
        
        agnt = RF_Agent::type_id::create("agnt", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connect Phase!", UVM_NONE)
        
    endfunction: connect_phase
endclass: RF_Env
