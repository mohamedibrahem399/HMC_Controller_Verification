class HMC_Mem_Agent extends uvm_agent;
    `uvm_component_utils(HMC_Mem_Agent)

    HMC_Mem_Sequencer sqr;
    HMC_Mem_Driver    drv;
    HMC_Mem_Monitor   mon;
    HMC_Mem_Storage   stg;
    // Constructor
    function new(string name= "HMC_Mem_Agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info("AGNT","new constructor", UVM_HIGH)
    endfunction: new

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AGNT","build_phase", UVM_HIGH)
        
        sqr = HMC_Mem_Sequencer::type_id::create("sqr",this);
        drv = HMC_Mem_Driver::type_id::create("drv",this);
        mon = HMC_Mem_Driver::type_id::create("mon",this);
        stg = HMC_Mem_Storage::type_id::create("stg",this);
    endfunction: build_phase

    // Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("AGNT","connect_phase", UVM_HIGH)
    
        mon.HMC_Mem_Analysis_Monitor_Storage_Port.connect(stg.HMC_Mem_Analysis_Monitor_Storage_Imp);
        stg.HMC_Mem_Analysis_Storage_Sequencer_Port.connect(sqr.HMC_Mem_Analysis_Storage_Sequencer_Export);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction: connect_phase
    
endclass: HMC_Mem_Agent
