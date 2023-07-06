class AXI_Req_Agent extends uvm_agent;
    `uvm_component_utils(AXI_Req_Agent)
  
	AXI_Req_Sequencer   axi_req_sqr;
	AXI_Req_Driver   	axi_req_drv;
	AXI_Req_Monitor     axi_req_mon;
    
	
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

	`uvm_info("AXI_Req_Agent"," build phase ",UVM_HIGH)

	axi_req_sqr = AXI_Req_Sequencer::type_id::create("axi_req_sqr",this);
	axi_req_drv = AXI_Req_Driver::type_id::create("axi_req_drv",this);
	axi_req_mon = AXI_Req_Monitor::type_id::create("axi_req_mon",this);
			
endfunction: build_phase

    ////////////////////////////connect phase///////////////////////// 
	
function void AXI_Req_Agent::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
		
	`uvm_info("AXI_Req_Agent"," connect phase ",UVM_HIGH)	
		
	axi_req_drv.seq_item_port.connect(axi_req_sqr.seq_item_export);	
			
endfunction: connect_phase


		
