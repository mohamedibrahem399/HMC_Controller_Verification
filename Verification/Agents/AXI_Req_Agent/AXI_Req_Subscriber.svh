
 class AXI_Req_Subscriber extends uvm_subscriber#(AXI_Req_Sequence_item);	
    `uvm_component_utils(AXI_Req_Subscriber)
	
	
  	uvm_analysis_imp #(AXI_Req_Sequence_item,AXI_Req_Subscriber) axi_req_imp;
    AXI_Req_Sequence_item    AXI_Seq_Item;
	
	AXI_Req_Sequence_item  req_item_q[$];
	
	
	covergroup hmc_req_pkt_Cov;
	WRITE_CMD_CP: coverpoint AXI_Seq_Item.CMD{
	
	  bins write16 = {WR16};  
		bins write32 = {WR32};
		bins write48 = {WR48};
		bins write64 = {WR64};
		bins write80 = {WR80};
		bins write96 = {WR96};
		bins write112 = {WR112};
		bins write128 = {WR128};
		}
	ATOMIC_CMD_CP: coverpoint AXI_Seq_Item.CMD{
		bins  add8 = {TWO_ADD8};
		bins add16 = {ADD16};
		}
	POSTED_WRITE_CMD_CP: coverpoint AXI_Seq_Item.CMD{
		bins posted_write16 = {P_WR16};
		bins posted_write32 = {P_WR32};
		bins posted_write48 = {P_WR48};
		bins posted_write64 = {P_WR64};
		bins posted_write80 = {P_WR80};
		bins posted_write96 = {P_WR96};
		bins posted_write112 = {P_WR112};
		bins posted_write128 = {P_WR128};
		}
	POSTED_ATOMIC_CMD_CP: coverpoint AXI_Seq_Item.CMD{	
		bins posted_add8 = {P_TWO_ADD8};
		bins posted_add16 = {P_ADD16};
		}
	READ_CMD_CP: coverpoint AXI_Seq_Item.CMD{	
		bins read16 = {RD16};
		bins read32 = {RD32};
		bins read48 = {RD48};
		bins read64 = {RD64};
		bins read80 = {RD80};
		bins read96 = {RD96};
		bins read112 = {RD112};
		bins read128 = {RD128};
		
		bins mode_read = {MD_RD};
		}
	PACKET_LENGTH: 	coverpoint AXI_Seq_Item.LNG{	
	    bins pkt_LNG[] = {[4'b0001:4'b1001]};//  Length of packet in FLITs
		illegal_bins zero_lng = {0};
		}
	Duplicate_LENGTH: 	coverpoint AXI_Seq_Item.DLN{	
	    bins pkt_LNG[] = {[4'b0001:4'b1001]};//  Duplicate of packet length field.
		illegal_bins zero_lng = {0};
		}
		
	endgroup:hmc_req_pkt_Cov
	
  covergroup CMD_transitions;
	   write_read_write:coverpoint AXI_Seq_Item.CMD{
	      bins wrw16=(WR16 => RD16 => WR16);
		    bins wrw32=(WR32 => RD32 => WR32);
		    bins wrw48=(WR48 => RD48 => WR48);
		    bins wrw64=(WR64 => RD64 => WR64);
        bins wrw80=(WR80 => RD80 => WR80);
		    bins wrw96=(WR96 => RD96 => WR96);
        bins wrw112=(WR112 => RD112 => WR112);
		    bins wrw128=(WR128 => RD128 => WR128);		
	   }
	   read_write_read:coverpoint AXI_Seq_Item.CMD{
	      bins rwr16=(RD16 => WR16 => RD16);
		    bins rwr32=(RD32 => WR32 => RD32);
		    bins rwr48=(RD48 => WR48 => RD48);
		    bins rwr64=(RD64 => WR64 => RD64);
        bins rwr80=(RD80 => WR80 => RD80);
		    bins rwr96=(RD96 => WR96 => RD96);
        bins rwr112=(RD112 => WR112 => RD112);
		    bins rwr128=(RD128 => WR128 => RD128);			
	   } 
	   posted_write_read_write:coverpoint AXI_Seq_Item.CMD{
	      bins pwrw16=(P_WR16 => RD16 => WR16);
		    bins pwrw32=(P_WR32 => RD32 => WR32);
		    bins pwrw48=(P_WR48 => RD48 => WR48);
		    bins pwrw64=(P_WR64 => RD64 => WR64);
        bins pwrw80=(P_WR80 => RD80 => WR80);
		    bins pwrw96=(P_WR96 => RD96 => WR96);
        bins pwrw112=(P_WR112 => RD112 => WR112);
		    bins pwrw128=(P_WR128 => RD128 => WR128);			
	   }
		postedwrite_read_postedwrite:coverpoint AXI_Seq_Item.CMD{
	      bins pwrw16=(P_WR16 => RD16 => P_WR16);
		    bins pwrw32=(P_WR32 => RD32 => P_WR32);
		    bins pwrw48=(P_WR48 => RD48 => P_WR48);
		    bins pwrw64=(P_WR64 => RD64 => P_WR64);
        bins pwrw80=(P_WR80 => RD80 => P_WR80);
		    bins pwrw96=(P_WR96 => RD96 => P_WR96);
        bins pwrw112=(P_WR112 => RD112 => P_WR112);
		    bins pwrw128=(P_WR128 => RD128 => P_WR128);			
	   }	   
	   
	endgroup:  CMD_transitions

	covergroup CMD_Consecutive;
	   write_write_write:coverpoint AXI_Seq_Item.CMD{
	      bins www16=(WR16 => WR16 => WR16);
		    bins www32=(WR32 => WR32 => WR32);
		    bins www48=(WR48 => WR48 => WR48);
		    bins www64=(WR64 => WR64 => WR64);
        bins www80=(WR80 => WR80 => WR80);
		    bins www96=(WR96 => WR96 => WR96);
        bins www112=(WR112 => WR112 => WR112);
		    bins www128=(WR128 => WR128 => WR128);			
	   }
	   read_read_read:coverpoint AXI_Seq_Item.CMD{
	      bins rrr16=(RD16 => RD16 => RD16);
		    bins rrr32=(RD32 => RD32 => RD32);
		    bins rrr48=(RD48 => RD48 => RD48);
		    bins rrr64=(RD64 => RD64 => RD64);
        bins rrr80=(RD80 => RD80 => RD80);
		    bins rrr96=(RD96 => RD96 => RD96);
        bins rrr112=(RD112 => RD112 => RD112);
		    bins rrr128=(RD128 => RD128 => RD128);			
	   }   
		postedwrite_postedwrite_postedwrite:coverpoint AXI_Seq_Item.CMD{
	      bins pwrw16=(P_WR16 => P_WR16 => P_WR16);
		    bins pwrw32=(P_WR32 => P_WR32 => P_WR32);
		    bins pwrw48=(P_WR48 => P_WR48 => P_WR48);
		    bins pwrw64=(P_WR64 => P_WR64 => P_WR64);
        bins pwrw80=(P_WR80 => P_WR80 => P_WR80);
		    bins pwrw96=(P_WR96 => P_WR96 => P_WR96);
        bins pwrw112=(P_WR112 => P_WR112 => P_WR112);
		    bins pwrw128=(P_WR128 => P_WR128 => P_WR128);			
	   }
	endgroup:  CMD_Consecutive
	
		
	function new(string name="AXI_Req_Subscriber", uvm_component parent = null);
       super.new(name,parent);
	   hmc_req_pkt_Cov=new();
	   CMD_transitions=new();
	   CMD_Consecutive=new();
	   
    endfunction: new 

    //build phase
	function void build_phase(uvm_phase phase);
	    super.build_phase(phase);
		axi_req_imp=new("axi_req_imp",this);
	    `uvm_info("AXI_Req_Subscriber"," build phase ",UVM_HIGH)
	endfunction:build_phase

	//write function
	function void write (AXI_Req_Sequence_item t);
        
    endfunction:write
		//write function
	function void write_axi_req (AXI_Req_Sequence_item item);
	     AXI_Seq_Item=item;
        //hmc_req_pkt_Cov.sample() 
        req_item_q.push_back(AXI_Seq_Item);
	    
  endfunction:write_axi_req
	//run phase
	task run_phase (uvm_phase phase);
        super.run_phase(phase);    
       `uvm_info("AXI_Req_Subscriber"," run phase ",UVM_HIGH)
        forever begin
	      AXI_Seq_Item = AXI_Req_Sequence_item::type_id::create("axi_req_item",this);
          wait(req_item_q.size!=0);
	     	AXI_Seq_Item  = req_item_q.pop_front();
		
	    hmc_req_pkt_Cov.sample();
    end 
 endtask: run_phase
 
	
 endclass:AXI_Req_Subscriber


    
