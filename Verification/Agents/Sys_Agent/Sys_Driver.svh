class Sys_Driver#(parameter DWIDTH=256,parameter NUM_LANES=16 ) extends uvm_driver#(Sys_Sequence_Item);
  
  `uvm_component_param_utils(Sys_Driver#(DWIDTH,NUM_LANES))
  
	virtual Sys_IF VIF;
	Sys_Sequence_Item seq_item;
	
    extern function new (string name="Sys_Driver", uvm_component parent = null);
	extern  function void build_phase (uvm_phase phase);
	extern  task drive_item();
	extern  task run_phase (uvm_phase phase);
	
	
 endclass: Sys_Driver
 ////////////////////////////constructor/////////////////////
 function Sys_Driver::new(string name="Sys_Driver", uvm_component parent = null);
	super.new(name,parent);
 endfunction: new 
 /////////////////////////build phase///////////////////////
 function void Sys_Driver::build_phase (uvm_phase phase);
	super.build_phase(phase);
   if(!uvm_config_db#(virtual Sys_IF)::get(this,"","VIF",VIF))
      `uvm_fatal("Sys_Driver ","failed to access Sys_VIF from database");
		
   `uvm_info("Sys_Driver"," build phase ",UVM_HIGH)
 endfunction: build_phase
	
 /////////////////////////run phase////////////////////////
 task Sys_Driver::run_phase (uvm_phase phase);
	super.run_phase(phase);
   `uvm_info("Sys_Driver"," run phase ",UVM_HIGH)
    forever begin 
      seq_item=Sys_Sequence_Item::type_id::create("seq_item");
      seq_item_port.get_next_item(seq_item);
	        drive_item();
	  seq_item_port.item_done();
	end
 endtask: run_phase
  ///////////////////////drive_item///////////////////////
 task Sys_Driver:: drive_item();
    
	
    seq_item.clk_user<=1;
    seq_item.clk_hmc<=1;
    seq_item.res_n_user<=0;
    seq_item.res_n_hmc<=0;
	VIF.clk_user<=seq_item.clk_user;
    VIF.clk_hmc<=seq_item.clk_hmc;
    VIF.res_n_user<=seq_item.res_n_user;
    VIF.res_n_hmc<=seq_item.res_n_hmc;
	#10ns;
	 VIF.res_n_user<=1;
     VIF.res_n_hmc<=1;
	forever begin
	    if(DWIDTH==256) begin
		    if(NUM_LANES==8) begin
		      #3.2ns ;
			  VIF.clk_user <= ~VIF.clk_user;
              #1.6ns;
			  VIF.clk_hmc <= ~VIF.clk_hmc;
			  
		    end
		    else if(NUM_LANES==16)begin 
		      #1.6ns ;
			  VIF.clk_user <= ~VIF.clk_user;
              #0.8ns;
			  VIF.clk_hmc <= ~VIF.clk_hmc;  
			  
		    end
		end
		else if(DWIDTH==512) begin
		    if(NUM_LANES==8) begin
		     #6.4ns ;
			 VIF.clk_user <= ~VIF.clk_user;
             #3.2ns;
			  VIF.clk_hmc <= ~VIF.clk_hmc;
			  
		    end
		    else if(NUM_LANES==16)begin 
		     #3.2ns ;
			 VIF.clk_user <= ~VIF.clk_user;
             #1.6ns;
			  VIF.clk_hmc <= ~VIF.clk_hmc;  
		    end
		end
		else if(DWIDTH==768) begin
			if(NUM_LANES==8) begin
		     #6.4ns ;
			 VIF.clk_user <=  ~VIF.clk_user;
             #3.2ns;
			 VIF.clk_hmc <= ~VIF.clk_hmc;    
		    end
		    else if(NUM_LANES==16)begin 
		     #4.8ns ;
			 VIF.clk_user <= ~VIF.clk_user;
             #2.4ns;
			 VIF.clk_hmc <= ~VIF.clk_hmc;    
		    end	
		end
		else if(DWIDTH==1024) begin
			if(NUM_LANES==8) begin
		     #3.2ns ;
			 VIF.clk_user <= ~VIF.clk_user;
             #1.6ns;
			 VIF.clk_hmc <= ~VIF.clk_hmc;    
		    end
		    else if(NUM_LANES==16)begin 
		     #6.4ns ;
			 VIF.clk_user <= ~VIF.clk_user;
             #3.2ns;
			 VIF.clk_hmc <= ~VIF.clk_hmc;  
		    end	
		end
	end
	
	
	
   
 endtask:drive_item
 
 
 
 
 
 
