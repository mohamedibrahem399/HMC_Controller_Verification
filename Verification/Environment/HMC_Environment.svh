class HMC_Environment extends uvm_env;
    `uvm_component_utils(HMC_Environment)

    Sys_Agent       sys_agnt;
    AXI_Req_Agent   axi_req_agnt;
    HMC_Mem_Agent   hmc_mem_agnt;
    AXI_Rsp_Agent   axi_rsp_agnt;
    RF_Agent        rf_agnt;
    
    HMC_Scoreboard      hmc_scb;
    AXI_Req_Scoreboard  axi_req_scb;
    AXI_Rsp_Scoreboard  axi_rsp_scb;
    HMC_Mem_Scoreboard  hmc_mem_scb;
    AXI_Req_Coverage    axi_req_cov;
    AXI_Rsp_Coverage    axi_rsp_cov;

    function new (string name = "HMC_Environment", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction :new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_HIGH)

        sys_agnt     = Sys_Agent::type_id::create("sys_agnt", this);
        axi_req_agnt = AXI_Req_Agent::type_id::create("axi_req_agnt", this);
        hmc_mem_agnt = HMC_Mem_Agent::type_id::create("hmc_mem_agnt", this);
        axi_rsp_agnt = AXI_Rsp_Agent::type_id::create("axi_rsp_agnt", this);
        rf_agnt      = RF_Agent::type_id::create("rf_agnt", this);
        hmc_scb      = HMC_Scoreboard::type_id::create("hmc_scb", this);
        axi_req_scb  = AXI_Req_Scoreboard::type_id::create("axi_req_scb", this);
        axi_rsp_scb  = AXI_Rsp_Scoreboard::type_id::create("axi_rsp_scb", this);
        hmc_mem_scb  = HMC_Mem_Scoreboard::type_id::create("hmc_mem_scb", this);
        axi_req_cov  = AXI_Req_Coverage::type_id::create("axi_req_cov", this);
        axi_rsp_cov  = AXI_Rsp_Coverage::type_id::create("axi_rsp_cov", this);

    endfunction :build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(),"connect_phase", UVM_HIGH)
        
        axi_req_agnt.axi_req_mon.axi_req_port.connect(axi_req_scb.axi_req_s_imp);
        axi_req_agnt.axi_req_mon.axi_req_port.connect(axi_req_cov.axi_req_c_imp);
        axi_rsp_agnt.axi_rsp_mon.axi_rsp_port.connect(axi_rsp_scb.axi_rsp_s_imp);
        axi_rsp_agnt.axi_rsp_mon.axi_rsp_port.connect(axi_rsp_cov.axi_rsp_c_imp);
        hmc_mem_agnt.hmc_req_mon.hmc_req_port.connect(hmc_req_scb.hmc_req_s_imp);
        hmc_mem_agnt.hmc_rsp_stg.hmc_rsp_port.connect(hmc_req_scb.hmc_rsp_s_imp);

        axi_req_agnt.axi_req_mon.axi_req_port.connect(hmc_scb.AXI_Req_Imp);
        hmc_mem_agnt.hmc_req_mon.hmc_req_port.connect(hmc_scb.Hmc_Req_Imp);

        axi_rsp_agnt.axi_rsp_mon.axi_rsp_port.connect(hmc_scb.AXI_Rsp_Imp);
        hmc_mem_agnt.hmc_rsp_stg.hmc_rsp_port.connect(hmc_scb.Hmc_Rsp_Imp);
    endfunction: connect_phase
    
endclass :HMC_Environment
