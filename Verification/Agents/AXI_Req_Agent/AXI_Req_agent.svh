 class AXI_Req_agent extends uvm_agent;
    'uvm_component_utils(AXI_Req_agent)
	
    uvm_analysis_port#(Req_Packet) aport;
	
	my_sequencer sequencer;
	AXI_Req_Driver driver;
	axireq_moniter monitor;
	AXI_Req_Config con;
	
	extern function new (string name="AXI_Req_agent", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	
 endclass: AXI_Req_agent

 //////////////////////////////constructor/////////////////////////
 function AXI_Req_agent::new(string name="AXI_Req_agent", uvm_component parent = null);
    super.new(name,parent);
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void AXI_Req_agent::build_phase (uvm_phase phase);
	super.build_phase(phase);
		
	aport=new("aport",this);
		
	 if(!uvm_config_db#(AXI_Req_Config)::get(this,"","con",con)) 
		'uvm_fatal("AXI_Req_Config ","failed to access AXI_Req_Config from database");
		
	if(con.is_active == UVM_ACTIVE) begin
		sequencer=my_sequencer::type_id::create("sequencer",this);
		driver=AXI_Req_Driver::type_id::create("driver",this);
	end
		
	monitor=axireq_moniter::type_id::create("monitor",this);
	con=AXI_Req_Config::type_id::create("con",this);
	'uvm_info("AXI_Req_agent"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void AXI_Req_agent::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
		
	if(con.is_active == UVM_ACTIVE)
		driver.seq_item_port.connect(sequencer.seq_item_export);
		
	monitor.aport.connect(aport);
	'uvm_info("AXI_Req_agent"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase
