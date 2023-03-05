
//`define DRIV_IF vif.DRIVER.driver_cb

class RA_driver extends uvm_driver #(RA_seq_item);


  `uvm_component_utils(RA_driver)

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  // ** virtual mem_if vif;

  virtual Transceiver_interface trans_ifc();
  virtual HMC_interface hmc_ifc();

  
    
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

     if(!uvm_config_db#(virtual Transceiver_interface)::get(null, "*", "trans_ifc", trans_ifc))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".trans_ifc"});

     if(!uvm_config_db#(virtual HMC_interface)::get(null, "*", "hmc_ifc", hmc_ifc))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".hmc_ifc"});

  endfunction: build_phase


  //--------------------------------------- 
  // run phase
  //---------------------------------------
task run_phase(uvm_phase phase);
      RA_seq_item cmd;

      forever begin : cmd_loop
         shortint unsigned result;
         RA_seq_item_port.get_next_item(cmd);

	 // the place where we need to send the signals.

	 hmc_ifc.load(cmd.LXTXPS , cmd.FERR_N , cmd.P_RST_N , cmd.LXRXPS );
         trans_ifc.load (cmd.phy_tx_ready, cmd.phy_rx_ready,
                         cmd.phy_data_rx_phy2link,
                         cmd.phy_data_tx_link2phy,
                         cmd.phy_bit_slip, phy_lane_polarity,
                         cmd.phy_init_cont_set );
         drive();

         RA_seq_item_port.item_done();
      end : cmd_loop
   endtask : run_phase
   
  task drive();

     if(`DRIV_IF.LXRXPS == 1) `DRIV_IF.LXTXPS = 1;
     else if(`DRIV_IF.LXRXPS == 0) `DRIV_IF.LXTXPS = 0;

    if(DRIV_IF.P_RST_N == 0) //reset mode
       begin 
              `DRIV_IF.FERR_N = 0; // check the values for each signal.
              `DRIV_IF.LXTXPS = 0;
              `DRIV_IF.phy_tx_ready = 0;
              `DRIV_IF.phy_rx_ready = 0;
       end
   else if(DRIV_IF.P_RST_N == 1) //Active mode
       begin 
              `DRIV_IF.FERR_N = 0; // check the values for each signal.
              `DRIV_IF.LXTXPS = 0;
              `DRIV_IF.phy_tx_ready = 1;
              `DRIV_IF.phy_rx_ready = 0;
       end  
  endtask :drive


endclass : mem_driver

