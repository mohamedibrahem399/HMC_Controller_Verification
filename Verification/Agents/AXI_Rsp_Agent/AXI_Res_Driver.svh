class AXI_Res_Driver#(parameter FPW=4) extends uvm_driver#(AXI_Res_Sequence_Item);
   'uvm_component_utils(AXI_Res_Driver)
   
	virtual AXI_Res_IF VIF;
	AXI_Res_Sequence_Item res_seq_item;
	extern function new (string name="AXI_Res_Driver", uvm_component parent = null);
	extern  function void build_phase (uvm_phase phase);
	extern  task run_phase (uvm_phase phase);
	extern  task drive_item();
	constraint TREADY{
        VIF.TREADY dist {0:=20, 1:=80};}
 endclass: AXI_Response_Driver

 ////////////////////////////constructor/////////////////////////
 function AXI_Res_Driver::new(string name="AXI_Res_Driver", uvm_component parent = null);
	super.new(name,parent);
 endfunction: new 
	
 ////////////////////////////build phase///////////////////////
 function void AXI_Res_Driver::build_phase (uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual AXI_Res_IF)::get(this,"","VIF",VIF))
	    'uvm_fatal("AXI_Res_Driver ","failed to access AXI_Res_IF from database");
		
	'uvm_info("AXI_Res_Driver"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 /////////////////////////run phase////////////////////////
 task AXI_Res_Driver::run_phase (uvm_phase phase);
	super.run_phase(phase);
	'uvm_info("AXI_Res_Driver"," run phase ",UVM_HIGH)
    forever begin 
	    res_seq_item=AXI_Res_Sequence_Item::type_id::create("res_seq_item");
	    seq_item_port.get_next_item(res_seq_item);
	        drive_item();
	    seq_item_port.item_done();
	end
 endtask: run_phase
  ///////////////////////drive_item///////////////////////
 task AXI_Res_Driver:: drive_item();
	@(posedge VIF.clk);
	if(!VIF.rst) begin 
        VIF.TREADY<=0;
		@(posedge VIF.clk);
	    
	    end
	else begin 
		if(VIF.TVALID)begin 
		    VIF.TREADY.randomize();
		end 
		else begin 
		   @(posedge VIF.clk);
		   VIF.TREADY<=1;
		   
		end
	end
 endtask:drive_item
