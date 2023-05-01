class AXI_Req_Agent#(FPW=4) extends uvm_agent;
     `uvm_component_param_utils(AXI_Req_Agent#(FPW))
  
	
	AXI_Sequencer sequencer;
	AXI_Req_Driver#(FPW)	driver;
	AXI_Req_Monitor#(FPW) monitor;
	//AXI_Req_Config con;
	
	extern function new (string name="AXI_Req_Agent", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	
 endclass: AXI_Req_Agent

 //////////////////////////////constructor/////////////////////////
 function AXI_Req_Agent::new(string name="AXI_Req_Agent", uvm_component parent = null);
    super.new(name,parent);
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void AXI_Req_Agent::build_phase (uvm_phase phase);
	super.build_phase(phase);
		
	
	// if(!uvm_config_db#(AXI_Req_Config)::get(this,"","con",con)) 
		//'uvm_fatal("AXI_Req_Config ","failed to access AXI_Req_Config from database");
		
	if(get_is_active() == UVM_ACTIVE) begin
		sequencer=AXI_Sequencer::type_id::create("sequencer",this);
		driver=AXI_Req_Driver#(FPW)::type_id::create("driver",this);
	end
		
	monitor=AXI_Req_Monitor#(FPW)::type_id::create("monitor",this);
	//con=AXI_Req_Config::type_id::create("con",this);
	`uvm_info("AXI_Req_Agent"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void AXI_Req_Agent::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
		
	if(get_is_active() == UVM_ACTIVE)
		driver.seq_item_port.connect(sequencer.seq_item_export);
		
   
   
	`uvm_info("AXI_Req_Agent"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase




