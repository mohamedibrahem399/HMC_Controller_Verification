class AXI_Req_Env extends uvm_env;
    `uvm_component_utils(AXI_Req_Env)
	
	AXI_Req_Agent        axi_req_agnt;
        AXI_Req_Scoreboard   axi_req_scb;
	AXI_Req_Subscriber  axi_req_cov;
	
	extern function new (string name="AXI_Req_Env", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	
 endclass:AXI_Req_Env
 
 //////////////////////////////constructor/////////////////////////
function AXI_Req_Env::new(string name="AXI_Req_Env", uvm_component parent=null);
	super.new(name,parent);
		
endfunction: new 

//////////////////////////////build phase/////////////////////////
function void AXI_Req_Env::build_phase (uvm_phase phase);
	super.build_phase(phase);
		
	axi_req_agnt=AXI_Req_Agent::type_id::create("axi_req_agnt",this);
	axi_req_scb=AXI_Req_Scoreboard::type_id::create("axi_req_scb",this);
	axi_req_cov=AXI_Req_Subscriber::type_id::create("axi_req_cov",this);
		
	`uvm_info("AXI_Req_Env"," build phase ",UVM_HIGH)
			
endfunction: build_phase
	
////////////////////////////connect phase/////////////////////////
function void AXI_Req_Env::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
		
	   axi_req_agnt.axi_req_mon.axi_req_port.connect(axi_req_scb.axi_req_imp);
	   axi_req_agnt.axi_req_mon.axi_req_port.connect(axi_req_cov.axi_req_imp);
	   `uvm_info("AXI_Req_Env"," connect phase ",UVM_HIGH)
			
endfunction: connect_phase

