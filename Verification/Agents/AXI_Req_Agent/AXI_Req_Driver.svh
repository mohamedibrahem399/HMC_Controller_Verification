class AXI_Req_Driver extends uvm_driver#(AXI_Req_Sequence_item);
 `uvm_component_utils(AXI_Req_Driver)
 
	parameter FPW=2;
	
	virtual AXI_Req_IF     axi_req_vif;
	AXI_Req_Sequence_item  axi_req_item;
	
	
	extern function new (string name="AXI_Req_Driver", uvm_component parent = null);
	extern  function void build_phase (uvm_phase phase);
	extern  task run_phase (uvm_phase phase);
	extern  task drive_item(AXI_Req_Sequence_item  axi_req_item);
	extern  task CREATE_PACKET_TDATA_TUSER();
	
	
 endclass: AXI_Req_Driver

	
	//*************************constructor****************************//
	function AXI_Req_Driver::new(string name="AXI_Req_Driver", uvm_component parent = null);
		super.new(name,parent);
	endfunction: new 


	//************************* build phase***************************//
	function void AXI_Req_Driver::build_phase (uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual AXI_Req_IF)::get(this,"*","axi_req_vif",axi_req_vif))
			`uvm_fatal("AXI_Req_Driver ","failed to access axi_req_vif from database");
			
		`uvm_info("AXI_Req_Driver"," build phase ",UVM_HIGH)	
		
	endfunction: build_phase


	//**************************run phase*****************************//
	task AXI_Req_Driver::run_phase (uvm_phase phase);
		super.run_phase(phase);
		
		`uvm_info("AXI_Req_Driver"," run phase ",UVM_HIGH)
		forever begin 
			axi_req_item=AXI_Req_Sequence_item::type_id::create("axi_req_item");
			seq_item_port.get_next_item(axi_req_item);
			
			    drive_item(axi_req_item);
			
			seq_item_port.item_done();
		end
	endtask: run_phase


	//************************drive_item*****************************//
	task AXI_Req_Driver::drive_item(AXI_Req_Sequence_item axi_req_item);
		@(posedge axi_req_vif.clk);
		axi_req_item.print();
		if(!axi_req_vif.rst) begin //reset is active low
			axi_req_vif.TVALID<=0;
		    axi_req_vif.TDATA<=0;
			axi_req_vif.TUSER<=0; 
		@(posedge axi_req_vif.clk);
		end
		else begin 
			@(posedge axi_req_vif.clk);
			//axi_req_vif.TVALID<=1;  
			if(axi_req_vif.TREADY)begin 
				CREATE_PACKET_TDATA_TUSER();
				@(posedge axi_req_vif.clk);
				axi_req_vif.TVALID<=0; 
			end 
		end
	endtask:drive_item
    
	
	//*************************************CREATE_PACKET_TDATA_TUSER*************************//
	task AXI_Req_Driver::CREATE_PACKET_TDATA_TUSER();
    
		bit[63:0] header;
		bit RES1=0;
		bit[2:0] RES2=0;
		bit[63:0] tail;
		bit[4:0] RES3=0;
		bit[127:0] flit;
		//bit[63:0] data[$];
		bit[127:0] flits[$];
		
		bit[127:0] Tdata_queue[$:2];//FPW=2;
		bit[FPW*128-1:0] Tdata;
		bit[FPW*16-1:0] TUSER;
		bit tuser_hdr[$];
		bit tuser_valid[$];
		bit tuser_tail[$];
		bit t_hdr[$:2];//FPW=2
		bit t_valid[$:2];//FPW=2
		bit t_tail[$:2];//FPW=2
		bit[FPW-1:0]TUSR_TAIL;
		bit[FPW-1:0] TUSR_HDR;
		bit[FPW-1:0] TUSR_VALID;
		int cycle=0;
		int i=1;
		int j=0;
		bit TVALID=1;
		int max_cycle;
		//the header of the packet
		header={axi_req_item.CUB,RES2,axi_req_item.ADRS,axi_req_item.TAG,axi_req_item.DLN,axi_req_item.LNG,RES1,axi_req_item.CMD};
	    //the tail of the packet
		tail={axi_req_item.CRC,axi_req_item.RTC,axi_req_item.SLID,RES3,axi_req_item.SEQ,axi_req_item.FRP,axi_req_item.RRP};
		tail={64'b0};//tail of request pkt must be all zeros.
		
		/* if(axi_req_item.LNG>=3) begin
		for(int i=0;i<(axi_req_item.LNG*2)-2;i++)begin 
		   data[i]=$random;
			end
		 end
		 else if(axi_req_item.LNG==2) begin
		for(int i=0;i<axi_req_item.LNG;i++)begin 
		   data[i]=$random;
		end
		 end*/
		
		//flits.delete();
		case(axi_req_item.LNG)
			1:begin//  LNG = 1 means that the packet contains no data FLITs 
				flit={tail,header};
				flits.push_back(flit);
				tuser_hdr.push_back(1);
				tuser_valid.push_back(1);
				tuser_tail.push_back(1);
				
			 end
			2:begin 
				flit={axi_req_item.data[0],header};
				flits.push_back(flit); 
				tuser_hdr.push_back(1);
				tuser_valid.push_back(1);
				tuser_tail.push_back(0);
				flit={tail,axi_req_item.data[1]};
				flits.push_back(flit); 
				tuser_hdr.push_back(0);
				tuser_valid.push_back(1);
				tuser_tail.push_back(1);
				
			  end
			3:begin
				flit={axi_req_item.data[0],header};
				flits.push_back(flit); 
				tuser_hdr.push_back(1);
				tuser_valid.push_back(1);
				tuser_tail.push_back(0);
				flit={axi_req_item.data[2],axi_req_item.data[1]};
				flits.push_back(flit);
				tuser_valid.push_back(1);
				tuser_hdr.push_back(0);
				tuser_tail.push_back(0);
				flit={tail,axi_req_item.data[3]};
				flits.push_back(flit);
				tuser_valid.push_back(1);
				tuser_tail.push_back(1);
				tuser_hdr.push_back(0);
			end
			default: begin 
				flit={axi_req_item.data[0],header};
				flits.push_back(flit); 
				tuser_hdr.push_back(1);
				tuser_valid.push_back(1);
				tuser_tail.push_back(0);
	
			  	while(i<=(axi_req_item.LNG-2)*2) begin
					flit={axi_req_item.data[i],axi_req_item.data[i++]};
					flits.push_back(flit);
					tuser_valid.push_back(1);
					tuser_hdr.push_back(0);
					tuser_tail.push_back(0);
					i++;
			  	end
				flit={tail,axi_req_item.data[(axi_req_item.LNG-2)*2+1]};
				flits.push_back(flit);
				tuser_valid.push_back(1);
				tuser_tail.push_back(1);
				tuser_hdr.push_back(0);
			end
		endcase
			$display("tuser_hdr = %p",tuser_hdr);
			$display("tuser_tail = %p",tuser_tail);
			$display("	tuser_valid= %p",	tuser_valid);
			if(FPW==2) begin
			if(axi_req_item.LNG==1) 
			 max_cycle=1;
			else if(axi_req_item.LNG==2) 
			 max_cycle=1; 
			else if(axi_req_item.LNG==3) 
			 max_cycle=2; 
			else if(axi_req_item.LNG==4) 
			 max_cycle=2; 
			else if(axi_req_item.LNG==5) 
			 max_cycle=3; 
			else if(axi_req_item.LNG==6) 
			 max_cycle=3; 
			else if(axi_req_item.LNG==7) 
			 max_cycle=4; 
			else if(axi_req_item.LNG==8) 
			 max_cycle=4; 
			else if(axi_req_item.LNG==9) 
			 max_cycle=5; 
			end
			while(flits.size()!=0 && cycle<max_cycle) begin 
		       j=0;
		       while(j<FPW) begin
			   
				  if(flits.size()==0) begin
				    break;
				  end
				  else begin
				    Tdata_queue.push_back(flits.pop_front());
					t_hdr.push_back(tuser_hdr.pop_front());
				    t_tail.push_back(tuser_tail.pop_front());
				    t_valid.push_back(tuser_valid.pop_front());
				    j++;
				end
				end
				for(int j=0;j<FPW;j++) begin
	
				if(FPW==2) begin
					Tdata={Tdata_queue[j],Tdata_queue[j-1]};
					TUSR_TAIL= {t_tail[j],t_tail[j-1]};
					TUSR_HDR={t_hdr[j],t_hdr[j-1]};
					TUSR_VALID={t_valid[j],t_valid[j-1]};
					TUSER={TUSR_TAIL,TUSR_HDR,TUSR_VALID};
				end
			    else if(FPW==4) begin
					Tdata={Tdata_queue[j],Tdata_queue[j-1],Tdata_queue[j-2],Tdata_queue[j-3]};
					TUSR_TAIL= {t_tail[j],t_tail[j-1],t_tail[j-2],t_tail[j-3]};
					TUSR_HDR={t_hdr[j],t_hdr[j-1],t_hdr[j-2],t_hdr[j-3]};
					TUSR_VALID={t_valid[j],t_valid[j-1],t_valid[j-2],t_valid[j-3]};
					TUSER={TUSR_TAIL,TUSR_HDR,TUSR_VALID};
		   		end
				else if(FPW==6) begin
					Tdata={128'b0,128'b0,Tdata_queue[j],Tdata_queue[j-1],Tdata_queue[j-2],Tdata_queue[j-3],Tdata_queue[j-4],Tdata_queue[j-5]};
					TUSR_TAIL= {t_tail[j],t_tail[j-1],t_tail[j-2],t_tail[j-3],t_tail[j-4],t_tail[j-5]};
					TUSR_HDR={t_hdr[j],t_hdr[j-1],t_hdr[j-2],t_hdr[j-3],t_hdr[j-4],t_hdr[j-5]};
					TUSR_VALID={t_valid[j],t_valid[j-1],t_valid[j-2],t_valid[j-3],t_valid[j-4],t_valid[j-5]};
					TUSER={TUSR_TAIL,TUSR_HDR,TUSR_VALID};
				end
		  		else if(FPW==8) begin
					Tdata={Tdata_queue[j],Tdata_queue[j-1],Tdata_queue[j-2],Tdata_queue[j-3],Tdata_queue[j-4],Tdata_queue[j-5],Tdata_queue[j-6],Tdata_queue[j-7]};
					TUSR_TAIL= {t_tail[j],t_tail[j-1],t_tail[j-2],t_tail[j-3],t_tail[j-4],t_tail[j-5],t_tail[j-6],t_tail[j-7]};
					TUSR_HDR={t_hdr[j],t_hdr[j-1],t_hdr[j-2],t_hdr[j-3],t_hdr[j-4],t_hdr[j-5],t_hdr[j-6],t_hdr[j-7]};
					TUSR_VALID={t_valid[j],t_valid[j-1],t_valid[j-2],t_valid[j-3],t_valid[j-4],t_valid[j-5],t_valid[j-6],t_valid[j-7]};
					TUSER={TUSR_TAIL,TUSR_HDR,TUSR_VALID};
		  		end
				if(flits.size()==0)begin
				    tuser_hdr.push_back(0);
				    tuser_valid.push_back(0);
				    tuser_tail.push_back(0);
				end
		    end
		   
			$display("t_hdr = %p",t_hdr);
			$display("t_tail = %p",t_tail);
			$display("t_valid = %p",t_valid);
			$display("tuser =%b",TUSER);
			$display("header=%h",header);
			$display("Tdata=%h",Tdata);
			$display("tail=%h",tail);
			@(posedge axi_req_vif.clk);
			axi_req_vif.TDATA<=Tdata;
			axi_req_vif.TUSER<=TUSER;
		     axi_req_vif.TVALID<=TVALID;
			$display("TVALID = %b",axi_req_vif.TVALID);
		
		    flits.push_back(0);
			tuser_hdr.push_back(0);
			tuser_tail.push_back(0);
			tuser_valid.push_back(0);
		    $display("cycle=%d",cycle);
		    cycle++;
		   	Tdata_queue.delete();
			t_hdr.delete();
			t_tail.delete();
			t_valid.delete();
		end
		

		
		   			
		 
		
	endtask :CREATE_PACKET_TDATA_TUSER
