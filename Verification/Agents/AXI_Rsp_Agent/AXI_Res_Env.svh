 class AXI_Rsp_Env#(parameter FPW = 4) extends uvm_env;
    `uvm_component_param_utils(AXI_Rsp_Env#(FPW))
	
	virtual AXI_Rsp_IF Rsp_VIF;
	AXI_Rsp_Agent Rsp_agent;
	AXI_Rsp_Scoreboard scoreboard;
	
    extern function new (string name="AXI_Rsp_Env", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	
	
endclass:AXI_Rsp_Env

 //////////////////////////////constructor/////////////////////////
 function AXI_Rsp_Env::new(string name="AXI_Rsp_Env", uvm_component parent = null);
    super.new(name,parent);
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void AXI_Rsp_Env::build_phase (uvm_phase phase);
	super.build_phase(phase);
	
   if(!uvm_config_db#(virtual AXI_Rsp_IF)::get(this,"","AXI_Rsp_VIF",Rsp_VIF))
     `uvm_fatal("AXI_Res_Env ","failed to access AXI_Rsp_VIF from database");		

	Rsp_agent=AXI_Rsp_Agent#(FPW)::type_id::create("Res_agent",this);
	scoreboard=AXI_Rsp_Scoreboard::type_id::create("scoreboard",this);
	
   `uvm_info("AXI_Rsp_Env"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void AXI_Rsp_Env::connect_phase (uvm_phase phase);
	super.connect_phase(phase);

   Rsp_agent.monitor.Rsp_Mon_Port.connect(scoreboard.Rsp_aport);
	
   `uvm_info("AXI_Rsp_Env"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase
