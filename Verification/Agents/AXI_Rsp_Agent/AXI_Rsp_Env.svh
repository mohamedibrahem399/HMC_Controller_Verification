 class AXI_Rsp_Env extends uvm_env;
  `uvm_component_param_utils(AXI_Rsp_Env)
	
	AXI_Rsp_Agent       axi_rsp_agnt;
	AXI_Rsp_Scoreboard  axi_rsp_scb;
	AXI_Rsp_Subscriber  axi_rsp_cov;
	
    extern function new (string name="AXI_Rsp_Env", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	
 endclass:AXI_Rsp_Env
	
	//////////////////////////////constructor/////////////////////////
	function AXI_Rsp_Env::new(string name="AXI_Rsp_Env", uvm_component parent=null);
		super.new(name,parent);
		
	endfunction: new 
 
  //////////////////////////////build phase/////////////////////////
	function void AXI_Rsp_Env::build_phase (uvm_phase phase);
		super.build_phase(phase);
		
		axi_rsp_agnt=AXI_Rsp_Agent::type_id::create("axi_rsp_agnt",this);
		axi_rsp_scb=AXI_Rsp_Scoreboard::type_id::create("axi_rsp_scb",this);
		axi_rsp_cov=AXI_Rsp_Subscriber::type_id::create("axi_rsp_cov",this);
		
		`uvm_info("AXI_Rsp_Env"," build phase ",UVM_HIGH)
			
	endfunction: build_phase
	
	////////////////////////////connect phase/////////////////////////
	function void AXI_Rsp_Env::connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		
	   axi_rsp_agnt.axi_rsp_mon.Rsp_Mon_Port.connect(axi_rsp_scb.Rsp_aport);
	   axi_rsp_agnt.axi_rsp_mon.Rsp_Mon_Port.connect(axi_rsp_cov.axi_rsp_imp);
		
	    `uvm_info("AXI_Rsp_Env"," connect phase ",UVM_HIGH)
			
	endfunction: connect_phase

 
