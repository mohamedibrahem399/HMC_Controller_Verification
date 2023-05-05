class AXI_Req_Monitor#(parameter FPW=4) extends uvm_monitor; 
  //register monitor in factory 
  `uvm_component_param_utils(AXI_Req_Monitor#(FPW))
      virtual interface AXI_Req_IF#(FPW) vif;
  //analsis port for broadcasting data to scoreboard
       AXI_Req_Sequence_Item trans_collected;
       uvm_analysis_port#(AXI_Req_Sequence_Item) axireq_ap; 
   //Req_Packet trans_collected;
  //constructor 
     function new (string name ,uvm_component parent =null);
       super.new(name, parent);
    trans_collected= AXI_Req_Sequence_Item::type_id::create("trans_collected",this);
      axireq_ap=new("axireq_ap",this);
  endfunction 
  
//build phase //getting handle to interface 
    
  function void build_phase(uvm_phase phase);
		super.build_phase(phase);

    if(!uvm_config_db#(virtual  AXI_Req_IF) ::get(this, "", "vif",vif) ); //
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction : build_phase
// run_phase - convert the signal level activity to transaction level.
       bit[FPW*128-1:0] TDATA;
      bit[FPW*16-1:0] TUSER;
      bit[63:0][3:0] HDR;
      bit[63:0][3:0] TAIL;
      bit  indicator;
  virtual task run_phase(uvm_phase phase);
      
     forever begin
       @(posedge vif.clk);
       if (vif.TVALID == 1 && vif.TREADY == 1)
        begin
          TDATA=vif.TDATA;
          TUSER=vif.TUSER; 
          monitor();                
      end 
     end  
  endtask : run_phase
  task monitor();

     for(int i=0;i<FPW/64;i++) 
      begin        
       indicator =0;
       if(vif.Valid[i])
        begin 
            if(vif.Hdr[i])
              begin 
                // HDR[i]=TDATA[63+(i*64):0+(64*i)];
		HDR[i] = reverse(TDATA[i * 64 +: 64]);
                 trans_collected.CMD=HDR[5:0];
                 trans_collected.LNG=HDR[10:7];
                 trans_collected.DLN=HDR[14:11];
                 trans_collected.TAG=HDR[23:15];
                 trans_collected.ADRS=HDR[57:24];
                 trans_collected.CUB=HDR[63:61];   
              end 
           if (vif.Tail[i])
              begin 
                indicator=1;
                TAIL[i]=reverse(TDATA[i * 64 +: 64]);
                trans_collected.RRP=TAIL[7:0];
                trans_collected.FRP=TAIL[15:8];
                trans_collected.SEQ=TAIL[18:16];
                trans_collected.SLID=TAIL[26:24];
                trans_collected.RTC=TAIL[31:27];
                trans_collected.CRC=TAIL[63:32];
              end  
          if (vif.Hdr[i] && vif.Tail[i] ) //this case handles header and tail in the same flit 
              begin 
                 indicator=1;
//setting header fields
                 HDR[i]=reverse(TDATA[i * 64 +: 64]);
		TAIL[i]=reverse(TDATA[(i+1) * 64 +: 64]);
                 
                 trans_collected.CMD=HDR[5:0];
                 trans_collected.LNG=HDR[10:7];
                 trans_collected.DLN=HDR[14:11];
                 trans_collected.TAG=HDR[23:15];
                 trans_collected.ADRS=HDR[57:24];
                 trans_collected.CUB=HDR[63:61]; 
// setting Tail fields 
                 trans_collected.RRP=TAIL[7:0];
                trans_collected.FRP=TAIL[15:8];
                trans_collected.SEQ=TAIL[18:16];
                trans_collected.SLID=TAIL[26:24];
                trans_collected.RTC=TAIL[31:27];
                trans_collected.CRC=TAIL[63:32];
               end  
       end 
    if(indicator) 
    begin 
      axireq_ap.write(trans_collected);
    end        
   end 
 endtask
endclass : AXI_Req_Monitor  
		   