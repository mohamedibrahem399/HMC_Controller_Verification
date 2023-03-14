`include "uvm_macros.svh"
import uvm_pkg::*;
class axireq_moniter extends uvm_monitor; 
  //register monitor in factory 
  `uvm_component_utils(axi_master_monitor);
    virtual interface AX_REQ_IF vif;
  //analsis port for broadcasting data to scoreboard
   uvm_analysis_port#( Req_Packet) axireq_ap;
   Req_Packet trans_collected;
  //constructor 
  function new (string name ,uvm_component parent =null);//Not general
    super.new(name,parent);
    trans_collected=new();
    axireq_ap=new("axireq_ap", this);
  endfunction 
  
//build phase //getting handle to interface 
    
  function void build_phase(uvm_phase phase);
		super.build_phase(phase);

    if(!uvm_config_db#(virtual  AX_REQ_IF) ::get(this, "", "vif",vif) ) //
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction : build_phase
// run_phase - convert the signal level activity to transaction level.
   virtual task run_phase(uvm_phase phase);
     forever begin
       @(posedge vif.clk);
       if (vif.TVALID == 1 && vif.TREADY == 1)
        begin
         trans_collected.TUSER = vif.Tuser;
         trans_collected.Tdata = vif.Tdata;
         item_collected_port.write(trans_collected);
        end   
  endtask : run_phase
endclass : axireq_moniter