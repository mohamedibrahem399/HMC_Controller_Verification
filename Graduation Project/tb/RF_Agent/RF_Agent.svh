class RF_Agent extends uvm_agent;
    `uvm_component_utils(RF_Agent)

    RF_Sequencer  rf_sqr;
    RF_Driver     rf_drv;
    RF_Monitor    rf_mon;

    //Constructor
    function new(string name = "RF_Agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    //Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)
  
        if(get_is_active()) begin
          rf_sqr = RF_Sequencer::type_id::create("rf_sqr", this);
          rf_drv = RF_Driver::type_id::create("rf_drv", this);
        end
        rf_mon = RF_Monitor::type_id::create("rf_mon", this);  
    endfunction: build_phase

    //Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connect Phase!", UVM_NONE)
        
        if(get_is_active()) begin
          rf_drv.seq_item_port.connect(rf_sqr.seq_item_export);
        end
    endfunction: connect_phase
endclass: RF_Agent
