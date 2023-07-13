`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

//Include Files
`include "Sys_IF.sv"
`include "Sys_Sequence_Item.svh"
`include "Sys_Sequence.svh"
`include "Sys_Sequencer.svh"
`include "Sys_Driver.svh"
`include "Sys_Monitor.svh"
`include "Sys_Agent.svh"

`include "RF_IF.sv"
`include "RF_Sequence_Item.svh"
`include "RF_Sequences.svh"
`include "RF_Sequencer.svh"
`include "RF_Driver.svh"
`include "RF_Monitor.svh"
`include "RF_Agent.svh"

`include "HMC_Mem_Types.svh"

`include "AXI_Req_IF.sv"
`include "AXI_Req_Sequence_item.svh"
`include "AXI_Req_Sequences.svh"
`include "AXI_Req_Sequencer.svh"
`include "AXI_Req_Driver.svh"
`include "AXI_Req_Monitor.svh"
`include "AXI_Req_Agent.svh"

`include "HMC_Mem_IF.sv"
`include "HMC_Req_Sequence_item.svh"
`include "HMC_Rsp_Sequence_item.svh"
`include "HMC_Mem_Init_Sequence.svh"
`include "HMC_Mem_Sequencer.svh"
`include "HMC_Mem_Base_Sequence.svh"
`include "HMC_Mem_Driver.svh"
`include "HMC_Mem_Monitor.svh"
`include "HMC_Mem_Storage.svh"
`include "HMC_Mem_Agent.svh"

`include "AXI_Rsp_IF.sv"
`include "AXI_Rsp_Sequence_item.svh"
`include "AXI_Rsp_Sequences.svh"
`include "AXI_Rsp_Sequencer.svh"
`include "AXI_Rsp_Driver.svh"
`include "AXI_Rsp_Monitor.svh"
`include "AXI_Rsp_Agent.svh"

`include "Open_HMC_Env.svh"
`include "Open_HMC_Test.svh"

module Open_HMC_Top;
    parameter FPW                   = 2;
    parameter LOG_FPW               = 1;
    parameter DWIDTH                = FPW*128;
    //Define HMC interface width
    parameter LOG_NUM_LANES         = 4;
    parameter NUM_LANES             = 2**LOG_NUM_LANES;
    parameter NUM_DATA_BYTES        = FPW*16;
    //Define width of the register file
    parameter HMC_RF_WWIDTH         = 64;   
    parameter HMC_RF_RWIDTH         = 64;
    parameter HMC_RF_AWIDTH         = 4;
    //Configure the Functionality
    parameter LOG_MAX_RX_TOKENS     = 8;
    parameter LOG_MAX_HMC_TOKENS    = 10;
    parameter HMC_RX_AC_COUPLED     = 1;
    parameter DETECT_LANE_POLARITY  = 1;
    parameter CTRL_LANE_POLARITY    = 1;    
    parameter CTRL_LANE_REVERSAL    = 1;
    parameter CTRL_SCRAMBLERS       = 1;
    parameter OPEN_RSP_MODE         = 0;
    parameter RX_RELAX_INIT_TIMING  = 1;
    parameter RX_BIT_SLIP_CNT_LOG   = 5; 
    parameter SYNC_AXI4_IF          = 0;
    parameter XIL_CNT_PIPELINED     = 1; 
    parameter BITSLIP_SHIFT_RIGHT   = 1;   
    //Debug Params
    parameter DBG_RX_TOKEN_MON      = 1;  
    

    Sys_IF          sys_if();
    RF_IF           rf_if (.clk_hmc(sys_if.clk_hmc), .res_n_hmc(sys_if.res_n_hmc));
    AXI_Req_IF      axi_req_vif(.clk(sys_if.clk_hmc), .rst(sys_if.res_n_hmc));
    HMC_Mem_IF      hmc_mem_if(.hmc_clk(sys_if.clk_hmc), .hmc_res_n(sys_if.res_n_hmc));
    AXI_Rsp_IF      axi_rsp_vif(.clk(sys_if.clk_hmc), .rst(sys_if.res_n_hmc));

    openhmc_top #(FPW  ,LOG_FPW ,DWIDTH, LOG_NUM_LANES, NUM_LANES, NUM_DATA_BYTES, HMC_RF_WWIDTH,HMC_RF_RWIDTH, 
    HMC_RF_AWIDTH ,LOG_MAX_RX_TOKENS, LOG_MAX_HMC_TOKENS, HMC_RX_AC_COUPLED, DETECT_LANE_POLARITY, 
    CTRL_LANE_POLARITY, CTRL_LANE_REVERSAL, CTRL_SCRAMBLERS, OPEN_RSP_MODE, RX_RELAX_INIT_TIMING ,
    RX_BIT_SLIP_CNT_LOG ,SYNC_AXI4_IF , XIL_CNT_PIPELINED, BITSLIP_SHIFT_RIGHT ,DBG_RX_TOKEN_MON
    )
    DUT
    (
    // SYSTEM INTERFACES
    .clk_user(sys_if.clk_user),
    .clk_hmc(sys_if.clk_hmc),
    .res_n_user(sys_if.res_n_user), 
    .res_n_hmc(sys_if.res_n_hmc),

    // From AXI to HMC Ctrl TX
    .s_axis_tx_TVALID(axi_req_vif.TVALID),
    .s_axis_tx_TREADY(axi_req_vif.TREADY),
    .s_axis_tx_TDATA(axi_req_vif.TDATA),
    .s_axis_tx_TUSER(axi_req_vif.TUSER),

    // From HMC Ctrl RX to AXI
    .m_axis_rx_TVALID(axi_rsp_vif.TVALID),
    .m_axis_rx_TREADY(axi_rsp_vif.TREADY),
    .m_axis_rx_TDATA(axi_rsp_vif.TDATA),
    .m_axis_rx_TUSER(axi_rsp_vif.TUSER),

    // Connect HMC Mem
    .phy_data_tx_link2phy(hmc_mem_if.phy_data_tx_link2phy),
    .phy_data_rx_phy2link(hmc_mem_if.phy_data_rx_phy2link),
    .phy_bit_slip(hmc_mem_if.phy_bit_slip),   
    .phy_lane_polarity(hmc_mem_if.phy_lane_polarity),
    .phy_tx_ready(hmc_mem_if.phy_tx_ready),    
    .phy_rx_ready(hmc_mem_if.phy_rx_ready),
    .phy_init_cont_set(hmc_mem_if.phy_init_cont_set),
    
    .P_RST_N(hmc_mem_if.P_RST_N),
    .LXRXPS(hmc_mem_if.LXRXPS),
    .LXTXPS(hmc_mem_if.LXTXPS),
    .FERR_N(hmc_mem_if.FERR_N),
   
    // Connect RF
    .rf_address(rf_if.rf_address),
    .rf_read_data(rf_if.rf_read_data),
    .rf_invalid_address(rf_if.rf_invalid_address),
    .rf_access_complete(rf_if.rf_access_complete),
    .rf_read_en(rf_if.rf_read_en),
    .rf_write_en(rf_if.rf_write_en),
    .rf_write_data(rf_if.rf_write_data)
    );

    // Set The interface in The Data Base
    initial begin
        uvm_config_db #(virtual Sys_IF)::set(null, "*", "sys_if", sys_if );
        uvm_config_db #(virtual RF_IF)::set(null, "*", "rf_if", rf_if );
        uvm_config_db #(virtual AXI_Req_IF)::set(null, "*", "axi_req_vif", axi_req_vif );
        uvm_config_db #(virtual HMC_Mem_IF)::set(null, "*", "hmc_mem_if", hmc_mem_if );
        uvm_config_db #(virtual AXI_Rsp_IF)::set(null, "*", "axi_rsp_vif", axi_rsp_vif );
    end

    // Start The Test
    initial begin
        run_test("Open_HMC_Test");
    end

        //Maximum Simulation Time 
    initial begin
        #12000ns;
        $display("Sorry! Ran out of clock cycles!");
        $finish();
    end
    
    //Generate Waveforms
    initial begin
        $dumpfile("test.vcd");
        $dumpvars();
    end
    
endmodule :Open_HMC_Top