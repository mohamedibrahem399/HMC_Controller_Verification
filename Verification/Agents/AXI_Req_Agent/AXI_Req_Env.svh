class AXI_Req_Env extends uvm_env;
    'uvm_component_utils(AXI_Req_Env)
	
	virtual AXI_Req_IF Req_VIF;
	AXI_Req_Agent Req_agent;
	AXI_Scoreboard scoreboard;
	
	extern function new (string name="AXI_Req_Env", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
endclass:AXI_Req_Env

 //////////////////////////////constructor/////////////////////////
 function AXI_Req_Env::new(string name="AXI_Req_Env", uvm_component parent = null);
    super.new(name,parent);
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void AXI_Req_Env::build_phase (uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual AXI_Req_IF)::get(this,"","AXI_Req_VIF",Req_VIF))
		'uvm_fatal("AXI_Req_Env ","failed to access AXI_Req_VIF from database");		

	Req_agent=AXI_Req_Agent::type_id::create("Req_agent",this);
	scoreboard=AXI_Scoreboard::type_id::create("scoreboard",this);
	
	'uvm_info("AXI_Req_Env"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void AXI_Req_Env::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
  Req_agent.req_aport.connect(scoreboard.req_analysis_imp);
	'uvm_info("AXI_Req_Env"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase
	
	
