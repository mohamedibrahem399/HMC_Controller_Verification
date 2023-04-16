/*
`include "seq_item.sv"
`include "sequencer.sv"
`include "sequence.sv"
`include "driver.sv"
`include "monitor.sv"
*/

class RA_agent extends uvm_agent;

  //---------------------------------------
  // component instances
  //---------------------------------------

  RA_driver    driver;
  RA_sequencer sequencer;
  RA_monitor   monitor;
  HMC_Mem_Storage  hmc_memory;
  `uvm_component_utils(RA_agent)

  //---------------------------------------
  // constructor
  //---------------------------------------

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    
    monitor = RA_monitor::type_id::create("monitor", this);

    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      driver    = RA_driver::type_id::create("driver", this);
      sequencer = RA_sequencer::type_id::create("sequencer", this);
      monitor    = RA_monitor::type_id::create("monitor", this);
      hmc_memory   = HMC_Mem_Storage::type_id::create("hmc_memory", this);
    end
    

  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);

    if(get_is_active() == UVM_ACTIVE) begin
      driver.RA_seq_item_port.connect(sequencer.RA_seq_item_export);
      monitor.mem_put_port.connect(hmc_memory.mem_put_imp);
    end

  endfunction : connect_phase

endclass : RA_agent
