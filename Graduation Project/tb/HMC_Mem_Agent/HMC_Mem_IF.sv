interface HMC_Mem_IF(input bit hmc_clk, hmc_res_n);

    parameter DWIDTH = 256, NUM_LANES = 16;
    // Connect Transceiver
    logic  [DWIDTH-1:0]      phy_data_tx_link2phy;//output: Connect!
    logic  [DWIDTH-1:0]      phy_data_rx_phy2link;//input : Connect!
    logic  [NUM_LANES-1:0]   phy_bit_slip;        //output: Must be connected if DETECT_LANE_POLARITY==1 AND CTRL_LANE_POLARITY=0
    logic  [NUM_LANES-1:0]   phy_lane_polarity;   //output: All 0 if CTRL_LANE_POLARITY=1
    logic                    phy_tx_ready;        //input : Optional information to RF
    logic                    phy_rx_ready;        //input : Release RX descrambler reset when PHY ready
    logic                    phy_init_cont_set;   //output: Can be used to release transceiver reset if used
    
    // Connect HMC
    logic              P_RST_N;   //output:RF
    logic              LXRXPS;    //output
    logic              LXTXPS;    //input
    logic              FERR_N;    //input:RF

endinterface: HMC_Mem_IF
