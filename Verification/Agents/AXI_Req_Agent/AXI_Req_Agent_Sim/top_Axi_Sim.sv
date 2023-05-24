// RTL : https://github.com/mohamedibrahem399/HMC_Controller_Verification/tree/main/Verification/Simple%20Test/RTL
// EDA : https://www.edaplayground.com/x/qMj9

`timescale 1ns/1ns
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "AXI_Req_IF.sv"

`include "CMD_DATA_TYPES.svh"
`include "AXI_Req_Sequence_Item.svh"
`include "AXI_Sequence.svh"
`include "AXI_Sequencer.svh"
`include "AXI_Req_Driver.svh"
//`include "AXI_Req_Config.svh"
`include "AXI_Req_Monitor.svh"
`include "AXI_Req_Agent.svh"
//`include "AXI_Req_Scoreboard.svh"
`include "AXI_Req_Env.svh"
`include "base_test.svh"

module top_Axi_Sim;
    parameter FPW                   = 4;
    parameter LOG_FPW               = 2;
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
    parameter XIL_CNT_PIPELINED     = 1; /////////////////////
    parameter BITSLIP_SHIFT_RIGHT   = 1;   
    //Debug Params
    parameter DBG_RX_TOKEN_MON      = 1;  

   bit clk_user,clk_hmc, res_n_user, res_n_hmc;

   AXI_Req_IF intf(clk_user,clk_hmc, res_n_user, res_n_hmc); 

   openhmc_top #(FPW  ,LOG_FPW ,DWIDTH, LOG_NUM_LANES, NUM_LANES, NUM_DATA_BYTES, HMC_RF_WWIDTH,HMC_RF_RWIDTH, 
   HMC_RF_AWIDTH ,LOG_MAX_RX_TOKENS, LOG_MAX_HMC_TOKENS, HMC_RX_AC_COUPLED, DETECT_LANE_POLARITY, 
   CTRL_LANE_POLARITY, CTRL_LANE_REVERSAL, CTRL_SCRAMBLERS, OPEN_RSP_MODE, RX_RELAX_INIT_TIMING ,
   RX_BIT_SLIP_CNT_LOG ,SYNC_AXI4_IF , XIL_CNT_PIPELINED, BITSLIP_SHIFT_RIGHT ,DBG_RX_TOKEN_MON
   )
   DUT_AXI_Test
   (
   // SYSTEM INTERFACES
   .clk_user(clk_user),
   .clk_hmc(clk_hmc),
   .res_n_user(res_n_user), 
   .res_n_hmc(res_n_hmc),
   // From AXI to HMC Ctrl TX
   .s_axis_tx_TVALID(intf.TVALID),
   .s_axis_tx_TREADY(intf.TREADY),
   .s_axis_tx_TDATA(intf.TDATA),
   .s_axis_tx_TUSER(intf.TUSER),
   // From HMC Ctrl RX to AXI
   .m_axis_rx_TVALID(m_axis_rx_TVALID),
   .m_axis_rx_TREADY(1'b0),
   .m_axis_rx_TDATA(m_axis_rx_TDATA),
   .m_axis_rx_TUSER(m_axis_rx_TUSER),
   // Connect Transceiver
   .phy_data_tx_link2phy(phy_data_tx_link2phy),
   .phy_data_rx_phy2link({DWIDTH{1'b0}}),
   .phy_bit_slip(phy_bit_slip),   
   .phy_lane_polarity(phy_lane_polarity),
   .phy_tx_ready(1'b0),    
   .phy_rx_ready(1'b0),
   .phy_init_cont_set(phy_init_cont_set),
   // Connect HMC
   .P_RST_N(P_RST_N),
   .LXRXPS(LXRXPS),
   .LXTXPS(1'b1),
   .FERR_N(1'b0),
   // Connect RF
   .rf_address({HMC_RF_AWIDTH{1'b0}}),
   .rf_read_data(rf_read_data),
   .rf_invalid_address(rf_invalid_address),
   .rf_access_complete(rf_access_complete),
   .rf_read_en(1'b0),
   .rf_write_en(1'b0),
   .rf_write_data({HMC_RF_WWIDTH{1'b0}})
   );

   initial begin 
    uvm_config_db #(virtual AXI_Req_IF)::set(null, "*", "AXI_Req_IF", intf );
   end
  
  initial begin 
    repeat(100) begin
    #5 
    clk_user =~ clk_user;
    clk_hmc  =~ clk_hmc; 
    end
  end 

  initial begin  
    res_n_user =1; res_n_hmc =1;
    #15
    res_n_user =0; res_n_hmc =0;
  end 

  initial begin
    run_test("base_test");
  end 
  
  initial begin
    #1000;
    $finish;
    $display("Simulation Time Ended");
  end 
  
  initial begin
    $dumpfile("test.vcd");
      $dumpvars;
    end
  
endmodule: top_Axi_Sim
