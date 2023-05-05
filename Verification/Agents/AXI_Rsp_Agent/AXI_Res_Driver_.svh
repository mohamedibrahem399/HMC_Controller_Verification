class AXI_Rsp_Driver#(parameter FPW = 4) extends uvm_driver#(AXI_Rsp_Sequence_Item);
  `uvm_component_param_utils(AXI_Rsp_Driver#(FPW))
   
	virtual AXI_Rsp_IF#(FPW) VIF;
	AXI_Rsp_Sequence_Item rsp_seq_item;
	
    extern function new (string name="AXI_Rsp_Driver", uvm_component parent = null);
	extern  function void build_phase (uvm_phase phase);
	extern  task run_phase (uvm_phase phase);
	extern  task drive_item();
	
 endclass: AXI_Rsp_Driver

 ////////////////////////////constructor/////////////////////////
 function AXI_Rsp_Driver::new(string name="AXI_Rsp_Driver", uvm_component parent = null);
	super.new(name,parent);
 endfunction: new 
	
 ////////////////////////////build phase///////////////////////
 function void AXI_Rsp_Driver::build_phase (uvm_phase phase);
	super.build_phase(phase);
   if(!uvm_config_db#(virtual AXI_Rsp_IF)::get(this,"","AXI_Rsp_VIF",VIF))
      `uvm_fatal("AXI_Rsp_Driver ","failed to access AXI_Rsp_VIF from database");
		
   `uvm_info("AXI_Rsp_Driver"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 /////////////////////////run phase////////////////////////
 task AXI_Rsp_Driver::run_phase (uvm_phase phase);
	super.run_phase(phase);
   `uvm_info("AXI_Rsp_Driver"," run phase ",UVM_HIGH)
   
    forever begin 
      rsp_seq_item=AXI_Rsp_Sequence_Item::type_id::create("rsp_seq_item");
      seq_item_port.get_next_item(rsp_seq_item);
	        drive_item();
	  seq_item_port.item_done();
	end
	
 endtask: run_phase
  ///////////////////////drive_item///////////////////////
 task AXI_Rsp_Driver:: drive_item();
 
	@(posedge VIF.clk);
	if(!VIF.rst) begin 
        VIF.TREADY<=0;
		@(posedge VIF.clk);
	    
	    end
	else begin 
		if(VIF.TVALID)begin 
		    VIF.TREADY<=rsp_seq_item.TREADY;
		end 
		else begin 
		   @(posedge VIF.clk);
		   VIF.TREADY<=1;
		   
		end
	end
	
 endtask:drive_item
