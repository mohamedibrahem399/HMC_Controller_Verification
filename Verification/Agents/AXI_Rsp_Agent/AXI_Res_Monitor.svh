class AXI_Res_Monitor #(parameter FPW = 4) extends  uvm_monitor;
  
  //uvm_component_utils only can register the defaults,if you intend other than the default parameter values we should use this
	`uvm_component_param_utils(AXI_Res_Monitor #(FPW ))
  
  virtual AXI_Res_IF #(FPW) vif;
  uvm_analysis_port #(AXI_Res_Sequence_Item) Res_Mon_Port;

  
  function new ( string name = "AXI_Res_Monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create an instance of the declared analysis port
    Res_Mon_Port = new("Res_Mon_Port", this);
    
    // Get virtual interface handle from the configuration db
    if(!uvm_config_db #(virtual AXI_Res_IF)::get(this, "*", "vif", vif)) begin
      `uvm_error(get_type_name(), "Interface Not Found!")
    end
  endfunction: build_phase
 
  
  // Run Phase
   task run_phase (uvm_phase phase);
     super.run_phase(phase);
     
     AXI_Res_Sequence_Item item = AXI_Res_Sequence_Item::type_id::create("item",this);
     int j = 1;

     
     
     forever begin
       @(posedge vif.clk);
       if (vif.TVALID == 1 && vif.TREADY == 1)begin 
	       Pin_To_Trans(item,j);
       
       end
      
       // I am not sure if we should rst when TVALID = 0
       /*
       else if (vif.TVALID == 0) begin
         //field should be zero
         To_Header(64'b0, item);
         To_Tail(64'b0, item);
         axireq_ap.write(item); //Where??
       end*/
       
     end    
   endtask:run_phase
  
  
  
  
	task Pin_To_Trans(AXI_Res_Sequence_Item item, int j);
    
    bit[63:0] header;
    bit[63:0] tail;    
    
    //To access TDATA: i -> TDATA[((i+1)*128)-1 :i*128]
    for(int i=0; i<FPW; i++)begin
 
      if(vif.Valid[i])begin
        int Upper_Limit = ((i+1) * 128) -1;
        int Lower_Limit = i*128;

        if(vif.Hdr[i])begin  

          header = vif.TDATA[ Lower_Limit + 63 : Lower_Limit];
          To_Header(header, item);
         // fill data
          if(item.LEN > 1) item.data[0] = vif.TDATA[ Upper_Limit : Upper_Limit - 63];

        end   

        if (vif.Tail[i])begin

          tail = vif.TDATA[ Upper_Limit : Upper_Limit - 63];
          To_Tail(tail, item);
          // fill data
          if(item.LEN > 1) item.data[$] = vif.TDATA[ Lower_Limit + 63 : Lower_Limit];
          j = 1;
          axireq_ap.write(item);
          end
        
        //fill the rest of the data
        if(!vif.Tail[i] && !vif.Hdr[i])begin
          item.data[j++] = vif.TDATA[ Lower_Limit + 63 : Lower_Limit];
          item.data[j++] = vif.TDATA[ Upper_Limit : Upper_Limit - 63];
          
        end
        
      end
    end
          

      
  endtask:Pin_To_Trans
	
	
	
  task To_Header(bit[63:0] header, AXI_Res_Sequence_Item item);

    item.CMD = header[5:0];
    item.LEN = header[10:7];       
    item.DLN = header[14:11];
    item.TAG = header[23:15];
	  
  endtask:To_Header
  
  
  task To_Tail (bit[63:0] tail, AXI_Res_Sequence_Item item);
    item.RRP = tail[7:0];
    item.FRP = tail[15:8];
    item.SEQ = tail[18:16];
    item.DINV = tail[19];
    item.ERRSTAT = tail[26:20];
    item.RTC = tail[31:27];
    item.CRC = tail[63:32];
    
  endtask:To_Tail
  
  
endclass
