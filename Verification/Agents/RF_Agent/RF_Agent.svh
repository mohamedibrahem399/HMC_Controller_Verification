class RF_Agent #(parameter HMC_RF_WWIDTH= 64, HMC_RF_RWIDTH= 64, HMC_RF_AWIDTH= 4) extends uvm_agent;
    `uvm_component_param_utils(RF_Agent#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_RWIDTH))
     
    RF_Sequencer  sqr;
    RF_Driver    drv;
    RF_Monitor   mon;


    //Constructor
    function new(string name = "RF_Agent", uvm_component parent);
      super.new(name, parent);
      `uvm_info("AGENT_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new
    
    
    //Build Phase
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("AGENT_CLASS", "Build Phase!", UVM_HIGH)

      if(get_is_active()) begin
        sqr = RF_Sequencer::type_id::create("sqr", this);
        drv = RF_Driver#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_AWIDTH)::type_id::create("drv", this);
      end
      mon = RF_Monitor#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_AWIDTH)::type_id::create("mon", this);  
    endfunction: build_phase
    
    //Connect Phase
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info("AGENT_CLASS", "Connect Phase!", UVM_HIGH)
      
      if(get_is_active()) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
      end
    endfunction: connect_phase
    
endclass: RF_Agent