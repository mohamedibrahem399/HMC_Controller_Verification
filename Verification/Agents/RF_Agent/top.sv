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

  logic clk;
  logic rst;
  RF_IF #(64, 64, 4) intf(clk, rst);
  
  RF dut(
      //.###()
  );
  
  
  //Interface Setting
  initial begin
    uvm_config_db #(virtual RF_IF)::set(null, "*", "intf", intf );
  end
  
  //Start The Test
  initial begin
    run_test("RF_Test");
  end
  
  initial begin
    rst=0;
    #10
    rst=1;
    #2500
    rst=0;
    #10
    rst=1;
  end

  //Clock Generation
  initial begin
    clock = 0;
    #5;
    forever begin
      clock = ~clock;
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