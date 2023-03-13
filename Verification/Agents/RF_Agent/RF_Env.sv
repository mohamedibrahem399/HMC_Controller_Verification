
class RF_Env extends uvm_env;
    `uvm_component_utils(RF_Env)
    
    RF_Agent agnt;
    RF_Scoreboard scb;
    
        
    function new(string name = "RF_Env", uvm_component parent);
        super.new(name, parent);
        `uvm_info("ENV_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new
  

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV_CLASS", "Build Phase!", UVM_HIGH)
    
    agnt = RF_Agent::type_id::create("agnt", this);
    scb = RF_Scoreboard::type_id::create("scb", this);
    
  endfunction: build_phase
  
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV_CLASS", "Connect Phase!", UVM_HIGH)
    
    agnt.mon.monitor_port.connect(scb.scoreboard_port);
  endfunction: connect_phase
  
endclass: RF_Env