class RA_agent extends uvm_agent;

    //---------------------------------------
    // component instances
    //---------------------------------------
    HMC_Mem_Driver    driver;
    HMC_Mem_Sequencer sequencer;
    RA_monitor   monitor;
    HMC_Mem_Storage  hmc_memory;
    `uvm_component_utils(RA_agent)

    //---------------------------------------
    // constructor
    //---------------------------------------
    function new (string name= "RA_agent", uvm_component parent);
      super.new(name, parent);
    endfunction : new

    //---------------------------------------
    // build_phase
    //---------------------------------------
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("HMC_Agent","build_phase", UVM_HIGH)
  
      //creating driver, sequencer, monitor and memorty 
      if(get_is_active() == UVM_ACTIVE) begin
        driver    = HMC_Mem_Driver::type_id::create("driver", this);
        sequencer = RA_sequencer::type_id::create("sequencer", this);
        monitor    = RA_monitor::type_id::create("monitor", this);
        hmc_memory   = HMC_Mem_Storage::type_id::create("hmc_memory", this);
      end
    endfunction : build_phase
  
    //---------------------------------------  
    // connect_phase - connecting the driver and sequencer port
    //---------------------------------------
    function void connect_phase(uvm_phase phase);
      `uvm_info("HMC_Agent","connect_phase", UVM_HIGH)
      if(get_is_active() == UVM_ACTIVE) begin
        driver.RA_seq_item_port.connect(sequencer.RA_seq_item_export);
        monitor.mem_put_port.connect(hmc_memory.HMC_Mem_Analysis_Monitor_Storage_Imp);
        driver.seq_item_port.connect(sequencer.seq_item_export);
        hmc_memory.HMC_Mem_Analysis_Storage_Sequencer_Port.connect(sequencer.HMC_Mem_Analysis_Storage_Sequencer_Export);
      end
    endfunction : connect_phase

endclass : RA_agent
