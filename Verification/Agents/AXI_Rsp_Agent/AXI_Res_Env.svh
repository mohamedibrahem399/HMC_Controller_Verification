class AXI_Res_Env extends uvm_env;
    'uvm_component_utils(AXI_Res_Env)
	
	virtual AXI_Res_IF Res_VIF;
	AXI_Res_Agent Res_agent;
	AXI_Scoreboard scoreboard;
	
	extern function new (string name="AXI_Res_Env", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
endclass:AXI_Res_Env

 //////////////////////////////constructor/////////////////////////
 function AXI_Res_Env::new(string name="AXI_Res_Env", uvm_component parent = null);
    super.new(name,parent);
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void AXI_Res_Env::build_phase (uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual AXI_Res_IF)::get(this,"","AXI_Res_VIF",Res_VIF))
		'uvm_fatal("AXI_Res_Env ","failed to access AXI_Res_VIF from database");		

	Res_agent=AXI_Res_Agent::type_id::create("Res_agent",this);
	scoreboard=AXI_Scoreboard::type_id::create("scoreboard",this);
	
	'uvm_info("AXI_Res_Env"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void AXI_Res_Env::connect_phase (uvm_phase phase);
	super.connect_phase(phase);

	 Res_agent.res_aport.connect(scoreboard.res_aport);
	
	'uvm_info("AXI_Res_Env"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase
	
	
