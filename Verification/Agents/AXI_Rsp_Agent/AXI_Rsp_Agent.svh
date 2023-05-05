class AXI_Rsp_Agent#(parameter FPW = 4) extends uvm_agent;
    `uvm_component_param_utils(AXI_Rsp_Agent#(FPW))
	

	
	AXI_Rsp_Sequencer sequencer;
	AXI_Rsp_Driver#(FPW) driver;
	AXI_Rsp_Monitor#(FPW) monitor;
	
	extern function new (string name="AXI_Rsp_Agent", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	
 endclass: AXI_Rsp_Agent

 //////////////////////////////constructor/////////////////////////
 function AXI_Rsp_Agent::new(string name="AXI_Rsp_Agent", uvm_component parent = null);
    super.new(name,parent);
	
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void AXI_Rsp_Agent::build_phase (uvm_phase phase);
	super.build_phase(phase);
		
 
	sequencer=AXI_Rsp_Sequencer::type_id::create("sequencer",this);
	driver=AXI_Rsp_Driver#(FPW)::type_id::create("driver",this);
	monitor=AXI_Rsp_Monitor#(FPW)::type_id::create("monitor",this);
	
	`uvm_info("AXI_Rsp_Agent"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void AXI_Rsp_Agent::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	
	driver.seq_item_port.connect(sequencer.seq_item_export);
	
	`uvm_info("AXI_Rsp_Agent"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase
