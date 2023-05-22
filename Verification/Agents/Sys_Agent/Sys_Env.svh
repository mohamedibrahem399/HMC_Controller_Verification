 class Sys_Env#(parameter DWIDTH=256,parameter NUM_LANES=16)extends uvm_env;
        `uvm_component_param_utils(Sys_Env#(DWIDTH,NUM_LANES))
	
    virtual Sys_IF  Sys_VIF; 
    Sys_Agent#(DWIDTH,NUM_LANES)  sys_agent;
	
	extern function new (string name="Sys_Env", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
      
endclass:Sys_Env

 //////////////////////////////constructor/////////////////////////
 function Sys_Env::new(string name="Sys_Env", uvm_component parent = null);
    super.new(name,parent);
   
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void Sys_Env::build_phase (uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual Sys_IF)::get(this,"","Sys_VIF",Sys_VIF))
		`uvm_fatal("Sys_Env ","failed to access Sys_VIF from database");		

   sys_agent=Sys_Agent#(DWIDTH,NUM_LANES)::type_id::create("sys_agent",this);

	
	`uvm_info("sys_Env"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void Sys_Env::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
  // sys_agent.monitor.Sys_Mon_Port.connect(scoreboard.aport);
   
	`uvm_info("Sys_Env"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase
 
 
 
