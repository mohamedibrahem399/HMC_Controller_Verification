 class AXI_Res_Agent extends uvm_agent;
    'uvm_component_utils(AXI_Res_Agent)
	
    uvm_analysis_port#(AXI_Res_SequenceItem) res_aport;
	
	AXI_Res_Sequencer sequencer;
	AXI_Res_Driver driver;
	AXI_Res_Monitor monitor;
	
	extern function new (string name="AXI_Res_Agent", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	
 endclass: AXI_Req_agent

 //////////////////////////////constructor/////////////////////////
 function AXI_Res_Agent::new(string name="AXI_Res_Agent", uvm_component parent = null);
    super.new(name,parent);
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void AXI_Res_Agent::build_phase (uvm_phase phase);
	super.build_phase(phase);
		
	res_aport=new("res_aport",this);
	sequencer=AXI_Res_Sequencer::type_id::create("sequencer",this);
	driver=AXI_Res_Driver::type_id::create("driver",this);
	monitor=AXI_Res_Monitor::type_id::create("monitor",this);
	
	'uvm_info("AXI_Res_Agent"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void AXI_Res_Agent::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	driver.seq_item_port.connect(sequencer.seq_item_export);
	monitor.res_aport.connect(res_aport);
	'uvm_info("AXI_Res_Agent"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase
