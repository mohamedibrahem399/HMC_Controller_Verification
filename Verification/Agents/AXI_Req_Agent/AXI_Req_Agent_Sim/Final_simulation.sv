`timescale 1ns/1ns
`include "AXI_Req_IF.sv"
`include "CMD_DATA_TYPES.svh"
`include "AXI_Req_Sequence_Item.svh"
`include "AXI_Sequence.svh"
`include "AXI_Sequencer.svh"
`include "AXI_Req_Driver.svh"
//`include "AXI_Req_Config.svh"
`include "AXI_Req_Monitor.svh"
`include "AXI_Req_Agent.svh"
`include "AXI_Req_Scoreboard.svh"
`include "AXI_Req_Env.svh"
`include "base_test.svh"

module top_Axi_Sim;
   bit clk,RESET;
  AXI_Req_IF intf(clk,RESET); 
  openhmc_top axiTop(
    				          .clk_user(0),
                      .clk_hmc(clk),
  					          .res_n_user(0), 
                      .res_n_hmc(RESET),
                     .m_axis_rx_TVALID(0),
                     .m_axis_rx_TREADY(0),
                     .m_axis_rx_TDATA(0),
                     .m_axis_rx_TUSER(0),
                     .s_axis_tx_TVALID(intf.TVALID),
                     .s_axis_tx_TREADY(intf.TREADY),                                    .s_axis_tx_TDATA(intf.TDATA),
                     .s_axis_tx_TUSER(intf.TUSER),
                     .rf_address(0),
                     .rf_read_data(0),
                     .rf_invalid_address(0),
                     .rf_access_complete(0),
                     .rf_read_en(0),
                     .rf_write_en(0),
                     .rf_write_data(0),
                     .phy_data_tx_link2phy(0),//Connect!
                     .phy_data_rx_phy2link(0),//Connect!
                     .phy_bit_slip(0),       //Must be connected 
                     .phy_lane_polarity(0),  //All 0 if 
                     .phy_tx_ready(0),       //Optional 
                     .phy_rx_ready(0),       //Release RX 
                     .phy_init_cont_set(0),  //Can be used to 
                     .P_RST_N(0),
                     .LXRXPS(0),
                     .LXTXPS(0),
                     .FERR_N(0)
                    );
  
   initial begin 
    uvm_config_db #(virtual AXI_Req_IF)::set(null, "*", "AXI_Req_IF", intf );
   end
  
  initial begin 
    repeat(100) begin
    #5 
    clk =~ clk;
    end
  end 

  initial begin  
   RESET=1;
    #15
   RESET=0;
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
