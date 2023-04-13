class AXI_Scoreboard extends uvm_scoreboard;
   'uvm_component_utils(AXI_Req_Scoreboard)
   
   uvm_analysis_imp#(AXI_Req_Sequence_Item,AXI_Scoreboard) req_aport;
   uvm_analysis_imp#(AXI_Res_SequenceItem,AXI_Scoreboard) res_aport;
   AXI_Req_Sequence_Item  req_seq_item;

  extern function new (string name="AXI_Scoreboard", uvm_component parent = null);
	extern function void build_phase (uvm_phase phase);
	extern function void connect_phase (uvm_phase phase);
	extern function void run_phase (uvm_phase phase);
endclass:AXI_Scoreboard

 //////////////////////////////constructor/////////////////////////
 function AXI_Scoreboard::new(string name="AXI_Scoreboard", uvm_component parent = null);
    super.new(name,parent);
 endfunction: new 
	
 //////////////////////////////build phase/////////////////////////
 function void AXI_Scoreboard::build_phase (uvm_phase phase);
	super.build_phase(phase);
	req_seq_item=AXI_Req_Sequence_Item::type_id::create("req_seq_item",this);
	req_aport=new("req_aport",this);
	res_aport=new("res_aport",this);
	
	'uvm_info("AXI_Scoreboard"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 ////////////////////////////connect phase/////////////////////////
 function void AXI_Scoreboard::connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	'uvm_info("AXI_Scoreboard"," connect phase ",UVM_HIGH)
		
 endfunction: connect_phase
  /////////////////////////run phase////////////////////////
 task AXI_Scoreboard::run_phase (uvm_phase phase);
	  super.run_phase(phase);
 	  'uvm_info("AXI_Scoreboard"," run phase ",UVM_HIGH)
     forever begin 
	   //
     end
 endtask: run_phase
	
