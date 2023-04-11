class RF_Env#(parameter HMC_RF_WWIDTH= 64, HMC_RF_RWIDTH= 64, HMC_RF_AWIDTH= 4) extends uvm_env;
    `uvm_component_param_utils(RF_Env#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_RWIDTH))
    RF_Agent agnt;
    RF_Scoreboard scb;
    
        
    function new(string name = "RF_Env", uvm_component parent);
        super.new(name, parent);
        `uvm_info("ENV_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new
  

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV_CLASS", "Build Phase!", UVM_HIGH)
    
    agnt = RF_Agent#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_AWIDTH)::type_id::create("agnt", this);
    scb = RF_Scoreboard::type_id::create("scb", this);
  endfunction: build_phase
  
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV_CLASS", "Connect Phase!", UVM_HIGH)
    
    agnt.mon.monitor_port.connect(scb.scoreboard_port);
  endfunction: connect_phase
  
endclass: RF_Env