`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

//Include Files
`include "RF_IF.sv"
`include "RF_Sequence_Item.svh"
`include "RF_Sequences.svh"
`include "RF_Sequencer.svh"
`include "RF_Driver.svh"
`include "RF_Monitor.svh"
`include "RF_Agent.svh"
`include "RF_Scoreboard.svh"
`include "RF_Env.svh"
`include "RF_Test.svh"

module top;

    bit hmc_clk;
    bit hmc_rst;

    RF_IF           intf  (.clk_hmc(hmc_clk), .res_n_hmc(hmc_rst));
    RF_openhmc_top  RF_DUT(.clk_hmc(hmc_clk), 
                           .res_n_hmc(hmc_rst),
                           .rf_address(intf.rf_address), 
                           .rf_read_data(intf.rf_read_data),
                           .rf_invalid_address(intf.rf_invalid_address), 
                           .rf_access_complete(intf.rf_access_complete), 
                           .rf_read_en(intf.rf_read_en),
                           .rf_write_en(intf.rf_write_en),
                           .rf_write_data(intf.rf_write_data) 
                           );

    // Set The interface in The Data Base
    initial begin
        uvm_config_db #(virtual RF_IF)::set(null, "*", "rf_vif", intf );
    end

    // Start The Test
    initial begin
        run_test("RF_Test");
    end

    // Clock Generation
    initial begin
        forever begin
            #5;  hmc_clk = ~hmc_clk;
        end
    end

    // Reset Generation
    initial begin
        hmc_rst =0; // active low
        #20;
        hmc_rst =1;  
    end

    //Maximum Simulation Time
    initial begin
        #100;
        $display("Sorry! Ran out of clock cycles!");
        $finish();
    end

    //Generate Waveforms
    initial begin
        $dumpfile("test.vcd");
        $dumpvars();
    end
endmodule: top
