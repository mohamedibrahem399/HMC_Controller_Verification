 class AXI_Req_Driver extends uvm_driver#(Req_Packet);
   'uvm_component_utils(AXI_Req_Driver)
   
	virtual AX_REQ_IF VIF;
	Req_Packet req_pkt;
	extern function new (string name="AXI_Req_Driver", uvm_component parent = null);
	extern virtual function void build_phase (uvm_phase phase);
	extern virtual task run_phase (uvm_phase phase);
	extern virtual task drive_item();
	
 endclass: AXI_Req_Driver

 ////////////////////////////constructor/////////////////////////
 function AXI_Req_Driver::new(string name="AXI_Req_Driver", uvm_component parent = null);
	super.new(name,parent);
 endfunction: new 
	
 ////////////////////////////build phase///////////////////////
 virtual function void AXI_Req_Driver::build_phase (uvm_phase phase);
	super.build_phase(phase);
	req_pkt=Req_Packet::type_id::create("req_pkt");
	if(!uvm_config_db#(virtual AX_REQ_IF)::get(this,"","VIF",VIF))
	    'uvm_fatal("AXI_Req_Driver ","failed to access AXI_Req_VIF from database");
		
	'uvm_info("AXI_Req_Driver"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 /////////////////////////run phase////////////////////////
 virtual task AXI_Req_Driver::run_phase (uvm_phase phase);
	super.run_phase(phase);
	'uvm_info("AXI_Req_Driver"," run phase ",UVM_HIGH)
    forever begin 
	    seq_item_port.get_next_item(req_pkt);
	        drive_item();
	    seq_item_port.item_done();
     end
 endtask: run_phase
	
 ///////////////////////drive_item///////////////////////
 virtual task AXI_Req_Driver:: drive_item();
	@(posedge VIF.clk);
	if(!VIF.rst) begin //reset is active low
            VIF.TVALID<=0;
	    VIF.TDATA<=0;
	    VIF.TUSER<=0; 
	    @(posedge VIF.clk);
	    VIF.TVALID<=1;
	end
	else begin 
	    @(posedge VIF.clk);
		VIF.TVALID<=1;  
		if(VIF.TREADY)begin 
		    VIF.TDATA<=req_pkt.TDATA;
		    VIF.TUSER<=req_pkt.TUSER;
		    @(posedge VIF.clk)
		   'uvm_info("AXI_Req_Driver",$sformatf("TDATA=%0d TUSER=%0d",req_pkt.TDATA,req_pkt.TUSER),UVM_HIGH);
		end 
	end
 endtask:drive_item
	
		
		
    	
	
