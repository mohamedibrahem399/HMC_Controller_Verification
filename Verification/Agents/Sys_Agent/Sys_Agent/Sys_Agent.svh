class Sys_Agent extends uvm_agent;
    `uvm_component_utils (Sys_Agent)

    Sys_Sequencer  sys_sqr;
    Sys_Driver     sys_drv;
    Sys_Monitor    sys_mon;

    // Constructor
    function new (string name = "Sys_Agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    // Build Phase
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase", UVM_NONE)

        sys_sqr = Sys_Sequencer::type_id::create("sys_sqr", this);
        sys_drv = Sys_Driver::type_id::create("sys_drv", this);
        sys_mon = Sys_Monitor::type_id::create("sys_mon", this);
    endfunction: build_phase

    // Connect Phase
    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connect Phase", UVM_NONE)

        sys_drv.seq_item_port.connect(sys_sqr.seq_item_export);
    endfunction :connect_phase
endclass: Sys_Agent
