`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

//Include Files
`include "RF_IF.sv"
`include "RF_Sequence_Item.sv"
`include "RF_Sequences.sv"
`include "RF_Sequencer.sv"
`include "RF_Driver.sv"
`include "RF_Monitor.sv"
`include "RF_Agent.sv"
`include "RF_Scoreboard.sv"
`include "RF_Env.sv"
`include "RF_Test.sv"


module top;
  parameter HMC_RF_WWIDTH= 64;
  parameter HMC_RF_RWIDTH= 64;
  parameter HMC_RF_AWIDTH= 4;
  logic clk;
  logic rst;

  RF_IF #(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_AWIDTH) intf(.clk_hmc(clk), .res_n_hmc(rst));

  RF dut(
        .clk_hmc(clk), 
        .res_n_hmc(rst),
        .rf_write_data(intf.rf_write_data), 
        .rf_read_data(intf.rf_read_data), 
        .rf_address(intf.rf_address),
        .rf_read_en(intf.rf_read_en), 
        .rf_write_en(intf.rf_write_en),
        .rf_invalid_address(intf.rf_invalid_address), 
        .rf_access_complete(intf.rf_access_complete)
        );
  
  //Interface Setting
  initial begin
    uvm_config_db #(virtual RF_IF)::set(null, "*", "intf", intf );
  end
  
  //Start The Test
  initial begin
    run_test("RF_Test");
  end
  
  //Reset Generation
  initial begin
    rst=0; // active low
    #10
    forever begin
      rst=1;
      #500
      rst=0;
      #10;
    end
  end

  //Clock Generation
  initial begin
    clk = 0;
    #5;
    forever begin
      clk = ~clk;
      #2;
    end
  end
  
  //Maximum Simulation Time
  initial begin
    #5000;
    $display("Sorry! Ran out of clock cycles!");
    $finish();
  end
  
  //Generate Waveforms
  initial begin
    $dumpfile("d.vcd");
    $dumpvars();
  end
endmodule: top
