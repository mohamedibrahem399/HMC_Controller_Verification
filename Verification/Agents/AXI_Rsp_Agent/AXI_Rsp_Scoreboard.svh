class AXI_Rsp_Scoreboard extends uvm_scoreboard;
  `uvm_component_utils(AXI_Rsp_Scoreboard)
  
  uvm_analysis_imp #(AXI_Rsp_Sequence_Item, AXI_Rsp_Scoreboard) Rsp_aport;
  AXI_Rsp_Sequence_Item item_q[$];
  
  function new(string name = "AXI_Res_Scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    Rsp_aport = new("Res_Port", this);
  endfunction: build_phase
  
  function void write(AXI_Rsp_Sequence_Item item);
    item_q.push_back(item);
  endfunction: write
  
  virtual task run_phase (uvm_phase phase);
    
    AXI_Rsp_Sequence_Item sb_item = AXI_Rsp_Sequence_Item::type_id::create("sb_item",this);
    
    forever begin
      wait(item_q.size > 0);
      
      if(item_q.size > 0) begin
        sb_item = item_q.pop_front();
        Checker(sb_item);
      end
    end 
    
  endtask: run_phase
          
          
  task Checker(AXI_Rsp_Sequence_Item sb_item);
  bit Tail;
  AXI_Rsp_Sequence_Item predicted_item = AXI_Rsp_Sequence_Item::type_id::create("predicted_item",this);
  case(sb_item.CMD)
    NULL: begin
      predicted_item.LNG = 0;
      predicted_item.DLN = predicted_item.LNG;
    end

    PRET:begin        
      predicted_item.LNG = 1;
      predicted_item.DLN = predicted_item.LNG;
    end

    TRET:begin        
      predicted_item.LNG = 1;
      predicted_item.DLN = predicted_item.LNG;   
    end

    IRTRY :begin        
      predicted_item.LNG = 1;
      predicted_item.DLN = predicted_item.LNG;
    end

    WR_RS :begin        
      predicted_item.LNG = 1;
      predicted_item.DLN = predicted_item.LNG;
    end

    MD_RD_RS :begin        
      predicted_item.LNG = 2;
      predicted_item.DLN = predicted_item.LNG;
    end

    MD_WR_RS :begin        
      predicted_item.LNG = 1;
      predicted_item.DLN = predicted_item.LNG;
    end

    ERROR :begin        
      predicted_item.LNG = 1;
      predicted_item.DLN = predicted_item.LNG;   
    end
    endcase 
    
    
    
    
    if(sb_item.CMD != RD_RS )begin
      Is_Zero(sb_item,Tail);
      if ((sb_item.LNG != predicted_item.LNG) && (sb_item.DLN != predicted_item.DLN) && (Tail != 1))
        $error ("FAILED: CMD: %s  LEN: %0h  DLN: %0h RRP: %0h  FRP: %0h  SEQ: %0h  DINV: %0h  ERRSTAT: %0h  RTC: %0h  CRC: %0h",
                sb_item.CMD.name(), sb_item.LNG, sb_item.DLN , sb_item.RRP, sb_item.FRP, sb_item.SEQ, sb_item.DINV, sb_item.ERRSTAT, sb_item.RTC, sb_item.CRC);
    end

  endtask: Checker
  
    
  task Is_Zero(input AXI_Rsp_Sequence_Item sb_item, output bit flag);
    
    if ((sb_item.RRP ==0) && (sb_item.FRP ==0) && (sb_item.SEQ ==0)  && (sb_item.DINV ==0 ) && (sb_item.ERRSTAT ==0) && (sb_item.RTC ==0 ) && (sb_item.CRC ==0))
      flag = 1;
    else
      flag =  0;
    
  endtask: Is_Zero
      
          
  
  
endclass: AXI_Rsp_Scoreboard
