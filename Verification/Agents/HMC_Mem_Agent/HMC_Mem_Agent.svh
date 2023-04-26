/*
`include "HMC_Mem_Driver.sv"
`include "HMC_Mem_Sequencer.sv"
`include "HMC_MEM_Monitor.sv"
`include "HMC_Mem_Storage.sv"
*/
class HMC_Mem_Agent extends uvm_agent;
    `uvm_component_utils(HMC_Mem_Agent)
    //---------------------------------------
    // component instances
    //---------------------------------------
    HMC_Mem_Driver    driver;
    HMC_Mem_Sequencer sequencer;
    HMC_MEM_Monitor   monitor;
    HMC_Mem_Storage  hmc_memory;
    //---------------------------------------
    // constructor
    //---------------------------------------
    function new (string name= "HMC_Mem_Agent", uvm_component parent);
      super.new(name, parent);
      `uvm_info("HMC_Mem_Agent","new constructor", UVM_HIGH)
    endfunction : new
    //---------------------------------------
    // build_phase
    //---------------------------------------
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("HMC_Mem_Agent","build_phase", UVM_HIGH)
      //creating driver, sequencer, monitor and memorty 
      if(get_is_active() == UVM_ACTIVE) begin
        driver       = HMC_Mem_Driver::type_id::create("driver", this);
        sequencer    = HMC_Mem_Sequencer::type_id::create("sequencer", this);
        monitor      = HMC_MEM_Monitor::type_id::create("monitor", this);
        hmc_memory   = HMC_Mem_Storage::type_id::create("hmc_memory", this);
      end
    endfunction : build_phase
    //---------------------------------------  
    // connect_phase - connecting the driver and sequencer port
    //---------------------------------------
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info("HMC_Mem_Agent","connect_phase", UVM_HIGH)
      if(get_is_active() == UVM_ACTIVE) begin
        monitor.Monitor_to_mem_port.connect(hmc_memory.HMC_Mem_Analysis_Monitor_Storage_Imp); // analysis port in monitor...
        driver.seq_item_port.connect(sequencer.seq_item_export);
        hmc_memory.HMC_Mem_Analysis_Storage_Sequencer_Port.connect(sequencer.HMC_Mem_Analysis_Storage_Sequencer_Export);
      end
    endfunction : connect_phase
endclass : HMC_Mem_Agent
