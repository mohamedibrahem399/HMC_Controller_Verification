class HMC_Mem_Agent extends uvm_agent;
    `uvm_component_utils(HMC_Mem_Agent)

    HMC_Mem_Sequencer hmc_mem_sqr;
    HMC_Mem_Driver    hmc_mem_drv;
    HMC_Mem_Monitor   hmc_mem_mon;
    HMC_Mem_Storage   hmc_mem_stg;

    function new(string name= "HMC_Mem_Agent", uvm_component parent);
        super.new(name, parent);
        `uvm_info("AGNT","new constructor", UVM_HIGH)
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AGNT","build_phase", UVM_HIGH)
        
        hmc_mem_sqr = HMC_Mem_Sequencer::type_id::create("hmc_mem_sqr",this);
        hmc_mem_drv = HMC_Mem_Driver::type_id::create("hmc_mem_drv",this);
        hmc_mem_mon = HMC_Mem_Monitor::type_id::create("hmc_mem_mon",this);
        hmc_mem_stg = HMC_Mem_Storage::type_id::create("hmc_mem_stg",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("AGNT","connect_phase", UVM_HIGH)
    
        hmc_mem_mon.Monitor_to_mem_port.connect(hmc_mem_stg.mon2stg_imp);
        hmc_mem_stg.stg2sqr_port.connect(hmc_mem_sqr.stg2sqr_export);
        hmc_mem_drv.seq_item_port.connect(hmc_mem_sqr.seq_item_export);
    endfunction: connect_phase
    
endclass: HMC_Mem_Agent