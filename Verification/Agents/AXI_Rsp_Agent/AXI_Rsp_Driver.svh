class AXI_Rsp_Driver extends uvm_driver#(AXI_Rsp_Sequence_Item);
	`uvm_component_utils(AXI_Rsp_Driver)
	
	parameter FPW = 2;
	virtual AXI_Rsp_IF     axi_rsp_vif;
	AXI_Rsp_Sequence_Item  axi_rsp_item;
  
       extern function new (string name="AXI_Rsp_Driver", uvm_component parent = null);
	extern  function void build_phase (uvm_phase phase);
	extern  task run_phase (uvm_phase phase);
	extern  task drive_item(AXI_Rsp_Sequence_Item  axi_rsp_item);
	
	
 endclass: AXI_Rsp_Driver
//Constructor
function AXI_Rsp_Driver:: new (string name="AXI_Rsp_Driver", uvm_component parent = null);
	super.new(name,parent);
endfunction: new 
    
 //Build Phase
function void AXI_Rsp_Driver::build_phase (uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual AXI_Rsp_IF)::get(this,"*","axi_rsp_vif",axi_rsp_vif))
	        `uvm_fatal("AXI_Rsp_Driver ","failed to access AXI_Rsp_VIF from database");
		`uvm_info("AXI_Rsp_Driver"," build phase ",UVM_NONE)
		
endfunction: build_phase
	
//Run Phase
task AXI_Rsp_Driver::run_phase (uvm_phase phase);
	super.run_phase(phase);
	`uvm_info("AXI_Rsp_Driver"," run phase ",UVM_NONE)
   
	forever begin	
		axi_rsp_item = AXI_Rsp_Sequence_Item::type_id::create("axi_rsp_item");
		seq_item_port.get_next_item(axi_rsp_item);
		drive_item(axi_rsp_item);
		seq_item_port.item_done();
	end
	
 endtask: run_phase
 
task AXI_Rsp_Driver::drive_item(AXI_Rsp_Sequence_Item axi_rsp_item);
	//@(posedge axi_rsp_vif.clk);
	if(!axi_rsp_vif.rst) begin 
		axi_rsp_vif.TREADY=0;
		$display("if rst=0 ==> TREADY= %b",axi_rsp_vif.TREADY);
	
	end
	else begin 
        	if(axi_rsp_vif.TVALID)begin 
			axi_rsp_vif.TREADY = axi_rsp_item.TREADY;
			$display("if TVALID=1 ==> TREADY= %b",axi_rsp_vif.TREADY);
		end 
		else begin 
		         axi_rsp_vif.TREADY=1;
			 $display("if TVALID=0 ==> TREADY= %b",axi_rsp_vif.TREADY);
		end
		end
endtask:drive_item

