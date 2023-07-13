class Open_HMC_Env extends uvm_env;
    `uvm_component_utils(Open_HMC_Env)

    Sys_Agent      sys_agnt;
    RF_Agent       rf_agnt;
    AXI_Req_Agent  axi_req_agnt;
    HMC_Mem_Agent  hmc_mem_agnt;
    AXI_Rsp_Agent  axi_rsp_agnt;

    function new(string name = "Open_HMC_Env", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)
        
        sys_agnt      = Sys_Agent::type_id::create("sys_agnt", this);
        rf_agnt       = RF_Agent::type_id::create("rf_agnt", this);
        axi_req_agnt  = AXI_Req_Agent::type_id::create("axi_req_agnt", this);
        hmc_mem_agnt  = HMC_Mem_Agent::type_id::create("hmc_mem_agnt", this);
        axi_rsp_agnt  = AXI_Rsp_Agent::type_id::create("axi_rsp_agnt", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connect Phase!", UVM_NONE)
        
    endfunction: connect_phase
endclass :Open_HMC_Env