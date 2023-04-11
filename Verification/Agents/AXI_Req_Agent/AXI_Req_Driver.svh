 class AXI_Req_Driver#(parameter FPW=4) extends uvm_driver#(Req_Packet);
   'uvm_component_utils(AXI_Req_Driver)
   
	virtual AXI_Req_IF VIF;
	AXI_Req_Sequence_Item  req_seq_item;
	extern function new (string name="AXI_Req_Driver", uvm_component parent = null);
	extern  function void build_phase (uvm_phase phase);
	extern  task run_phase (uvm_phase phase);
	extern  task drive_item();
	extern  task create_packet_TDATA_TUSER();
 endclass: AXI_Req_Driver

 ////////////////////////////constructor/////////////////////////
 function AXI_Req_Driver::new(string name="AXI_Req_Driver", uvm_component parent = null);
	super.new(name,parent);
 endfunction: new 
	
 ////////////////////////////build phase///////////////////////
 function void AXI_Req_Driver::build_phase (uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual AXI_Req_IF)::get(this,"","VIF",VIF))
	    'uvm_fatal("AXI_Req_Driver ","failed to access AXI_Req_IF from database");
		
	'uvm_info("AXI_Req_Driver"," build phase ",UVM_HIGH)
		
 endfunction: build_phase
	
 /////////////////////////run phase////////////////////////
 task AXI_Req_Driver::run_phase (uvm_phase phase);
	super.run_phase(phase);
	'uvm_info("AXI_Req_Driver"," run phase ",UVM_HIGH)
    forever begin 
	    req_seq_item=AXI_Req_Sequence_Item::type_id::create("req_seq_item");
	    seq_item_port.get_next_item(req_seq_item);
	        drive_item();
	    seq_item_port.item_done();
	end
 endtask: run_phase
	
 ///////////////////////drive_item///////////////////////
 task AXI_Req_Driver:: drive_item();
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
		//VIF.TVALID<=1;  
		if(VIF.TREADY)begin 
		    create_packet_TDATA_TUSER();
		    @(posedge VIF.clk);
		end 
	end
 endtask:drive_item
 
 task AXI_Req_Driver::create_packet_TDATA_TUSER();
    
    bit[63:0] header;
    bit RES1=0;
    bit[2:0] RES2=0;
    bit[63:0] tail;
    bit[4:0] RES3=0;
    bit[127:0] flit;
    bit[63:0] data[$];
    bit[127:0] flits[$];
	
    bit[127:0] TDATA_queue[$:3];//FPW=4;
    bit[FPW*128-1:0] TDATA;
    bit[FPW*16-1:0] TUSER;
    bit tuser_hdr[$];
    bit tuser_valid[$];
    bit tuser_tail[$];
    bit t_hdr[$:3];//FPW=4
    bit t_valid[$:3];//FPW=4
    bit t_tail[$:3];//FPW=4
    bit[FPW-1:0]TUSR_TAIL;
    bit[FPW-1:0] TUSR_HDR;
    bit[FPW-1:0] TUSR_VALID;
    int cycle=0;
    int i=0;
	
    //the header of the packet
    header={req_pkt.CUB,RES2,req_pkt.ADRS,req_pkt.TAG,req_pkt.DLN,req_pkt.LNG,RES1,req_pkt.CMD};
   //the tail of the packet
    tail={req_pkt.CRC,req_pkt.RTC,req_pkt.SLID,RES3,req_pkt.SEQ,req_pkt.FRP,req_pkt.RRP};
    tail={64'b0};
	
     if(req_pkt.LNG>=3) begin
	for(int i=0;i<(req_pkt.LNG*2)-2;i++)begin 
	    data[i]=$random;
        end
     end
     else if(req_pkt.LNG==2) begin
	for(int i=0;i<req_pkt.LNG;i++)begin 
	   data[i]=$random;
	end
     end
	
    flits.delete();
	
	case(req_pkt.LNG)
	    1:begin//  LNG = 1 means that the packet contains no data FLITs 
	          flit={header,tail};
		  flits.push_back(flit);
		  tuser_hdr.push_back(1);
		  tuser_valid.push_back(1);
		  tuser_tail.push_back(1);
		 end
	    2:begin 
		  flit={header,data[0]};
		  flits.push_back(flit); 
		  tuser_hdr.push_back(1);
		  tuser_valid.push_back(1);
		  flit={data[1],tail};
		  flits.push_back(flit); 
		  tuser_valid.push_back(1);
		  tuser_tail.push_back(1);
		  end
	    3:begin
		  flit={header,data[0]};
		  flits.push_back(flit); 
		  tuser_hdr.push_back(1);
		  tuser_valid.push_back(1);
		  flit={data[1],data[2]};
		  flits.push_back(flit);
		  tuser_valid.push_back(1);
		  flit={data[3],tail};
		  flits.push_back(flit);
		  tuser_valid.push_back(1);
		  tuser_tail.push_back(1);
                 end
        default: begin 
		  flit={header,data[0]};
		  flits.push_back(flit); 
		  tuser_hdr.push_back(1);
		  tuser_valid.push_back(1);

		  for(int i=1;i<req_pkt.LNG;i++) begin
		    flit={data[i],data[i++]};
           	    flits.push_back(flit);
		    tuser_valid.push_back(1);
			
		  end
		  flit={data[req_pkt.LNG+1],tail};
		  flits.push_back(flit);
		  tuser_valid.push_back(1);
		  tuser_tail.push_back(1);
		end
	endcase
	
	while(flits.size()!=0 && cycle<FPW) begin 
	   for(int j=0;j<FPW;j++) begin
	      if(flits.size()==0)begin
	            tuser_hdr.push_back(0);
		    tuser_valid.push_back(0);
		    tuser_tail.push_back(0);
	      end
	      TDATA_queue.push_back(flits.pop_front());
	     //$display(" TDATA_queue[%0d]=%b",j, TDATA_queue[j]);
	     t_hdr.push_back(tuser_hdr.pop_front());
	     t_tail.push_back(tuser_tail.pop_front());
	     t_valid.push_back(tuser_valid.pop_front());
	    if(FPW==2) begin
	       TDATA={TDATA_queue[j],TDATA_queue[j-1]};
	       TUSR_TAIL= {t_tail[j],t_tail[j-1]};
	       TUSR_HDR={t_hdr[j],t_hdr[j-1]};
	       TUSR_VALID={t_valid[j],t_valid[j-1]};
               TUSER={TUSR_TAIL,TUSR_HDR,TUSR_VALID};
	    end
           else if(FPW==4) begin
	       TDATA={TDATA_queue[j],TDATA_queue[j-1],TDATA_queue[j-2],TDATA_queue[j-3]};
	       TUSR_TAIL= {t_tail[j],t_tail[j-1],t_tail[j-2],t_tail[j-3]};
	       TUSR_HDR={t_hdr[j],t_hdr[j-1],t_hdr[j-2],t_hdr[j-3]};
	       TUSR_VALID={t_valid[j],t_valid[j-1],t_valid[j-2],t_valid[j-3]};
               TUSER={TUSR_TAIL,TUSR_HDR,TUSR_VALID};
	   end
	  else if(FPW==6) begin
	      TDATA={128'b0,128'b0,TDATA_queue[j],TDATA_queue[j-1],TDATA_queue[j-2],TDATA_queue[j-3],TDATA_queue[j-4],TDATA_queue[j-5]};
	      TUSR_TAIL= {t_tail[j],t_tail[j-1],t_tail[j-2],t_tail[j-3],t_tail[j-4],t_tail[j-5]};
	      TUSR_HDR={t_hdr[j],t_hdr[j-1],t_hdr[j-2],t_hdr[j-3],t_hdr[j-4],t_hdr[j-5]};
	      TUSR_VALID={t_valid[j],t_valid[j-1],t_valid[j-2],t_valid[j-3],t_valid[j-4],t_valid[j-5]};
              TUSER={TUSR_TAIL,TUSR_HDR,TUSR_VALID};
	   end
	  else if(FPW==8) begin
	      TDATA={TDATA_queue[j],TDATA_queue[j-1],TDATA_queue[j-2],TDATA_queue[j-3],TDATA_queue[j-4],TDATA_queue[j-5],TDATA_queue[j-6],TDATA_queue[j-7]};
	      TUSR_TAIL= {t_tail[j],t_tail[j-1],t_tail[j-2],t_tail[j-3],t_tail[j-4],t_tail[j-5],t_tail[j-6],t_tail[j-7]};
	      TUSR_HDR={t_hdr[j],t_hdr[j-1],t_hdr[j-2],t_hdr[j-3],t_hdr[j-4],t_hdr[j-5],t_hdr[j-6],t_hdr[j-7]};
	      TUSR_VALID={t_valid[j],t_valid[j-1],t_valid[j-2],t_valid[j-3],t_valid[j-4],t_valid[j-5],t_valid[j-6],t_valid[j-7]};
              TUSER={TUSR_TAIL,TUSR_HDR,TUSR_VALID};
	   end
		  //$display("TDATA=%b",TDATA);
		 //TUSER={t_tail,t_hdr,t_valid};
	   end
        $display("t_hdr = %p",t_hdr);
        $display("t_tail = %p",t_tail);
        $display("t_valid = %p",t_valid);
        $display("tuser =%b",TUSER);
	$display("TDATA=%b",TDATA);
	    VIF.TDATA<=TDATA;
	    VIF.TUSER<=TUSER;
	    VIF.TVALID<=1;
		
	   while(i<FPW)begin 
	      TDATA_queue.pop_front();
	      t_hdr.pop_front();
              t_tail.pop_front();
              t_valid.pop_front();
	      i++;
	   end
	   $display("cycle=%d",cycle);
	   cycle++;
	end
	
	
 endtask :create_packet_TDATA_TUSER

	
	
		   
	
	
	
		
		
    	
	
