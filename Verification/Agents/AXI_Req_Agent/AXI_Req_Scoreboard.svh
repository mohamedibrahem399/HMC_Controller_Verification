class AXI_Req_Scoreboard extends uvm_scoreboard;   
`uvm_component_utils(AXI_Req_Scoreboard)

 AXI_Req_Sequence_item  item_q[$];   
 AXI_Req_Sequence_item  axi_req_item;
 
 uvm_analysis_imp #(AXI_Req_Sequence_item,AXI_Req_Scoreboard) axi_req_imp;
 
 
 extern function new (string name="AXI_Req_Scoreboard", uvm_component parent);
 extern function void build_phase (uvm_phase phase);
 extern function void connect_phase (uvm_phase phase); 
 extern function void write(AXI_Req_Sequence_item axi_req);
 extern task run_phase (uvm_phase phase);
 extern task Check_LNG();
 extern task Check_Tail();
 extern task Check_Header();
 
 endclass:AXI_Req_Scoreboard
 
 //////////////////////////////constructor/////////////////////////
 function AXI_Req_Scoreboard::new(string name="AXI_Req_Scoreboard", uvm_component parent );
 super.new(name,parent);
 endfunction: new  
 //////////////////////////////build phase///////////////////////// 
function void AXI_Req_Scoreboard::build_phase (uvm_phase phase);
 super.build_phase(phase); 
axi_req_imp=new("axi_req_imp",this); 
`uvm_info("AXI_Req_Scoreboard"," build phase ",UVM_HIGH)  

 endfunction: build_phase    
 //////////////////////////write Function///////////////
  function void AXI_Req_Scoreboard::write(AXI_Req_Sequence_item axi_req);
    
    item_q.push_back(axi_req);
  endfunction:write
 ////////////////////////////connect phase///////////////////////// 
function void AXI_Req_Scoreboard::connect_phase (uvm_phase phase);
 super.connect_phase(phase); 
 `uvm_info("AXI_Req_Scoreboard"," connect phase ",UVM_HIGH)
   endfunction: connect_phase
  /////////////////////////run phase//////////////////////// 
task AXI_Req_Scoreboard::run_phase (uvm_phase phase);
   super.run_phase(phase);    
`uvm_info("AXI_Req_Scoreboard"," run phase ",UVM_HIGH)
    forever begin
	axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item",this);
        wait(item_q.size!=0);
		axi_req_item  = item_q.pop_front();
		Check_LNG();
		Check_Tail();
        Check_Header();
	  
    end 
 endtask: run_phase
task AXI_Req_Scoreboard::Check_LNG();
 
    //axi_req_item  = item.pop_front();
	if(axi_req_item.CMD==RD16|| 
	   axi_req_item.CMD== RD32||
	   axi_req_item.CMD== RD48||
	   axi_req_item.CMD== RD64||
	   axi_req_item.CMD== RD80||
	   axi_req_item.CMD== RD96||
	   axi_req_item.CMD== RD112||
	   axi_req_item.CMD== RD128||
	   axi_req_item.CMD== MD_RD)begin
	    if(axi_req_item.LNG==1)begin
	     `uvm_info("Check_LNG",$sformatf("CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG),UVM_HIGH)
	    end
		else begin
		 `uvm_error("Check_LNG",$sformatf("FAILED:CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG))
		end	
	end
	else if(axi_req_item.CMD==WR16|| 
	   axi_req_item.CMD== TWO_ADD8||
	   axi_req_item.CMD== ADD16||
	   axi_req_item.CMD== P_WR16||
	   axi_req_item.CMD== P_TWO_ADD8||
	   axi_req_item.CMD== P_ADD16)begin
	    if(axi_req_item.LNG==2)begin
	     `uvm_info("Check_LNG",$sformatf("CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG),UVM_HIGH)
	    end
		else begin
		 `uvm_error("Check_LNG",$sformatf("FAILED:CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG))
		end	
	end
	else if(axi_req_item.CMD==WR32|| 
	   axi_req_item.CMD== P_WR32)begin
	    if(axi_req_item.LNG==3)begin
	      
	     `uvm_info("Check_LNG",$sformatf("CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG),UVM_HIGH)
	    end
		else begin
		 `uvm_error("Check_LNG",$sformatf("FAILED:CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG))
		end	
	end
	else if(axi_req_item.CMD==WR48|| 
	   axi_req_item.CMD== P_WR48)begin
	    if(axi_req_item.LNG==4)begin
	     `uvm_info("Check_LNG",$sformatf("CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG),UVM_HIGH)
	    end
		else begin
		 `uvm_error("Check_LNG",$sformatf("FAILED:CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG))
		end	
	end	
	else if(axi_req_item.CMD==WR64|| 
	   axi_req_item.CMD== P_WR64)begin
	    if(axi_req_item.LNG==5)begin
	     `uvm_info("Check_LNG",$sformatf("CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG),UVM_HIGH)
	    end
		else begin
		 `uvm_error("Check_LNG",$sformatf("FAILED:CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG))
		end	
	end	
	else if(axi_req_item.CMD==WR80|| 
	   axi_req_item.CMD== P_WR80)begin
	    if(axi_req_item.LNG==6)begin
	     `uvm_info("Check_LNG",$sformatf("CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG),UVM_HIGH)
	    end
		else begin
		 `uvm_error("Check_LNG",$sformatf("FAILED:CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG))
		end	
	end	
	else if(axi_req_item.CMD==WR96|| 
	   axi_req_item.CMD== P_WR96)begin
	    if(axi_req_item.LNG==7)begin
	     `uvm_info("Check_LNG",$sformatf("CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG),UVM_HIGH)
	    end
		else begin
		 `uvm_error("Check_LNG",$sformatf("FAILED:CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG))
		end	
	end	
	else if(axi_req_item.CMD==WR112|| 
	   axi_req_item.CMD== P_WR112)begin
	    if(axi_req_item.LNG==8)begin
	     `uvm_info("Check_LNG",$sformatf("CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG),UVM_HIGH)
	    end
		else begin
		 `uvm_error("Check_LNG",$sformatf("FAILED:CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG))
		end	
	end	
	else if(axi_req_item.CMD==WR128|| 
	   axi_req_item.CMD== P_WR128)begin
	    if(axi_req_item.LNG==9)begin
	     `uvm_info("Check_LNG",$sformatf("CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG),UVM_HIGH)
	    end
		else begin
		 `uvm_error("Check_LNG",$sformatf("FAILED:CMD=%b ,LNG=%b ",axi_req_item.CMD,axi_req_item.LNG))
		end	
	end		
 endtask:Check_LNG

task AXI_Req_Scoreboard::Check_Tail();
    if(axi_req_item.CRC==32'b0 &&
	   axi_req_item.RTC==5'b0 &&
	   axi_req_item.SLID==3'b0 &&
	   axi_req_item.SEQ==3'b0 &&
	   axi_req_item.FRP==8'b0 &&
	   axi_req_item.RRP==8'b0 )begin
	`uvm_info("Check_Tail",$sformatf("CRC=%b,RTC=%b,SLID=%b,SEQ=%b,FRP=%b,RRP=%b",axi_req_item.CRC,axi_req_item.RTC,axi_req_item.SLID,axi_req_item.SEQ,axi_req_item.FRP,axi_req_item.RRP),UVM_HIGH)
	end
	else begin
	`uvm_error("Check_Tail",$sformatf("FAILED:CRC=%b,RTC=%b,SLID=%b,SEQ=%b,FRP=%b,RRP=%b",axi_req_item.CRC,axi_req_item.RTC,axi_req_item.SLID,axi_req_item.SEQ,axi_req_item.FRP,axi_req_item.RRP))
	end
endtask:Check_Tail


task AXI_Req_Scoreboard::Check_Header();

   if(axi_req_item.LNG == axi_req_item.DLN) begin
       `uvm_info("Check_Header",$sformatf("DLN=%b ,LNG=%b ",axi_req_item.DLN,axi_req_item.LNG),UVM_HIGH)
	end
    else begin
	    `uvm_error("Check_Header",$sformatf("FAILED:DLN=%b ,LNG=%b ",axi_req_item.DLN,axi_req_item.LNG))
	end	
	
	
   if(axi_req_item.CUB == 0 &&
      axi_req_item.SLID==0) begin
       `uvm_info("Check_Header",$sformatf("CUB=%b ",axi_req_item.CUB),UVM_NONE)
	end
    else begin
	    `uvm_error("Check_Header",$sformatf("FAILED:CUB=%b ",axi_req_item.CUB))
	end	


	if(axi_req_item.LNG <=2)begin
	    if(axi_req_item.data.size == (axi_req_item.LNG-1)*2)begin
	     `uvm_info("Check_Header",$sformatf("Data size=%b ,LNG=%b ",axi_req_item.data.size,axi_req_item.LNG),UVM_HIGH) 
	    end
	    else begin
	      `uvm_error("Check_Header",$sformatf("FAILED:Data size=%b ,LNG=%b ",axi_req_item.data.size,axi_req_item.LNG)) 
	    end
	end
	else begin
	    if(axi_req_item.data.size == (axi_req_item.LNG-2)*2+2)begin
	     `uvm_info("Check_Header",$sformatf("Data size=%b ,LNG=%b ",axi_req_item.data.size,axi_req_item.LNG),UVM_HIGH) 
	    end
	    else begin
	      `uvm_error("Check_Header",$sformatf("FAILED:Data size=%b ,LNG=%b ",axi_req_item.data.size,axi_req_item.LNG)) 
	    end  
	end
	
	
    
endtask:Check_Header

