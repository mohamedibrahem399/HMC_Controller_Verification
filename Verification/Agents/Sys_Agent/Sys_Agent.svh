class Sys_Agent#(parameter DWIDTH=256,parameter NUM_LANES=16 )extends uvm_agent;
    
	`uvm_component_param_utils(Sys_Agent#(DWIDTH,NUM_LANES))
  
	Sys_Sequencer sequencer;
	Sys_Driver#(DWIDTH,NUM_LANES) driver;
	Sys_Monitor monitor;
	
	extern function new (string name="Sys_Agent", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
  
 endclass: Sys_Agent

 //////////////////////////////constructor/////////////////////////
 function Sys_Agent::new(string name="Sys_Agent", uvm_component parent = null);
    super.new(name,parent);
	
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void Sys_Agent::build_phase (uvm_phase phase);
	super.build_phase(phase);
	
	sequencer=Sys_Sequencer::type_id::create("sequencer",this);
	driver=Sys_Driver#(DWIDTH,NUM_LANES)::type_id::create("driver",this);
	monitor=Sys_Monitor::type_id::create("monitor",this);
	
	`uvm_info("Sys_Agent"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void Sys_Agent::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	
	driver.seq_item_port.connect(sequencer.seq_item_export);
	
	`uvm_info("Sys_Agent"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase
 
 
