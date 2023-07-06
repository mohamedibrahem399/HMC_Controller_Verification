class AXI_Rsp_Agent extends uvm_agent;
    `uvm_component_utils(AXI_Rsp_Agent)
  
	AXI_Rsp_Sequencer   axi_rsp_sqr;
	AXI_Rsp_Driver   	axi_rsp_drv;
	AXI_Rsp_Monitor     axi_rsp_mon;
    
	
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

	`uvm_info("AXI_Rsp_Agent"," build phase ",UVM_HIGH)

	axi_rsp_sqr = AXI_Rsp_Sequencer::type_id::create("axi_rsp_sqr",this);
	axi_rsp_drv = AXI_Rsp_Driver::type_id::create("axi_rsp_drv",this);
	axi_rsp_mon = AXI_Rsp_Monitor::type_id::create("axi_rsp_mon",this);
			
endfunction: build_phase

 ////////////////////////////connect phase///////////////////////// 
function void AXI_Rsp_Agent::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
		
	`uvm_info("AXI_Rsp_Agent"," connect phase ",UVM_HIGH)	
		
	axi_rsp_drv.seq_item_port.connect(axi_rsp_sqr.seq_item_export);	
			
endfunction: connect_phase

