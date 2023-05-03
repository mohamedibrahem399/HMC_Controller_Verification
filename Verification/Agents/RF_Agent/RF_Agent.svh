class RF_Agent extends uvm_agent;
    `uvm_component_utils(RF_Agent)
     
    RF_Sequencer  sqr;
    RF_Driver    drv;
    RF_Monitor   mon;


    //Constructor
    function new(string name = "RF_Agent", uvm_component parent);
      super.new(name, parent);
      `uvm_info(get_type_name(), $sformatf("%m"), UVM_NONE)
    endfunction: new
    
    
    //Build Phase
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(), $sformatf("%m"), UVM_NONE)

      if(get_is_active()) begin
        sqr = RF_Sequencer::type_id::create("sqr", this);
        drv = RF_Driver::type_id::create("drv", this);
      end
      mon = RF_Monitor::type_id::create("mon", this);  
    endfunction: build_phase
    
    //Connect Phase
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(), $sformatf("%m"), UVM_NONE)
      
      if(get_is_active()) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
      end
    endfunction: connect_phase
    
endclass: RF_Agent
