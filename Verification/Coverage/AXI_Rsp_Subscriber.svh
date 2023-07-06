

 class AXI_Rsp_Subscriber extends uvm_subscriber#(AXI_Rsp_Sequence_Item);	
    `uvm_component_utils(AXI_Rsp_Subscriber)
	
	
	uvm_analysis_imp #(AXI_Rsp_Sequence_Item,AXI_Rsp_Subscriber) axi_rsp_imp;
    AXI_Rsp_Sequence_Item    AXI_Seq_Item;
	
	AXI_Rsp_Sequence_Item  rsp_item_q[$];
	
	
	covergroup hmc_rsp_pkt_Cov;
	 Flow_CMD_CP: coverpoint AXI_Seq_Item.CMD{
	    bins Null = {NULL};  
		bins Retry_pointer_return = {PRET };
		bins Token_return = {TRET};
		bins Init_retry = {IRTRY};
		}
		
	Response_CMD_CP: coverpoint AXI_Seq_Item.CMD{
		bins  READ_response = {RD_RS};
		bins WRITE_response= {WR_RS};
		bins ERROR_response= {ERROR};
		bins  MODE_READ_response = {MD_RD_RS};
		bins MODE_WRITE_response= {MD_WR_RS};
		}
		
	PACKET_LENGTH: 	coverpoint AXI_Seq_Item.LNG{	
	    bins pkt_LNG[] = {[4'b0001:4'b1001]};//  Length of packet in FLITs
		illegal_bins zero_lng = {0};
		}
	Duplicate_LENGTH: 	coverpoint AXI_Seq_Item.DLN{	
	    bins pkt_LNG[] = {[4'b0001:4'b1001]};//  Duplicate of packet length field.
		illegal_bins zero_lng = {0};
		}
		
	endgroup //hmc_rsp_pkt_Cov
		
  function new(string name="AXI_Rsp_Subscriber", uvm_component parent = null);
       super.new(name,parent);
	   hmc_rsp_pkt_Cov=new();
	   
	   
  endfunction: new 

//build phase
function void build_phase(uvm_phase phase);
	    super.build_phase(phase);
		axi_rsp_imp=new("axi_rsp_imp",this);
	    `uvm_info("AXI_Rsp_Subscriber"," build phase ",UVM_HIGH)
 endfunction:build_phase

//write function
    function void write (AXI_Rsp_Sequence_Item t);
       AXI_Seq_Item=t;
        //hmc_rsp_pkt_Cov.sample() 
        rsp_item_q.push_back(AXI_Seq_Item);
    endfunction:write

//run phase
task run_phase (uvm_phase phase);
        super.run_phase(phase);    
       `uvm_info("AXI_Rsp_Subscriber"," run phase ",UVM_NONE)
        forever begin
	      AXI_Seq_Item = AXI_Rsp_Sequence_Item::type_id::create("axi_rsp_item",this);
          wait(rsp_item_q.size!=0);
	     	AXI_Seq_Item  = rsp_item_q.pop_front();
		
	    hmc_rsp_pkt_Cov.sample();
    end 
endtask: run_phase
 
	
 endclass:AXI_Rsp_Subscriber
	
	

    

