`timescale 1ns/1ns
module openhmc_top_test;
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
    parameter XIL_CNT_PIPELINED     = 1; /////////////////////
    parameter BITSLIP_SHIFT_RIGHT   = 1;   
    //Debug Params
    parameter DBG_RX_TOKEN_MON      = 1;  
    
    //--------------------------------------------
    // SYSTEM INTERFACES
    logic                         clk_user;
    logic                         clk_hmc;
    logic                         res_n_user;
    logic                         res_n_hmc;
    // Connect AXI Ports
    // From AXI to HMC Ctrl TX
    logic                         s_axis_tx_TVALID;
    logic                         s_axis_tx_TREADY;
    logic [DWIDTH-1:0]            s_axis_tx_TDATA;
    logic [NUM_DATA_BYTES-1:0]    s_axis_tx_TUSER;
    // From HMC Ctrl RX to AXI
    logic                         m_axis_rx_TVALID;
    logic                         m_axis_rx_TREADY;
    logic [DWIDTH-1:0]            m_axis_rx_TDATA;
    logic [NUM_DATA_BYTES-1:0]    m_axis_rx_TUSER;
    // Connect Transceiver
    logic  [DWIDTH-1:0]           phy_data_tx_link2phy;
    logic  [DWIDTH-1:0]           phy_data_rx_phy2link;
    logic  [NUM_LANES-1:0]        phy_bit_slip;
    logic  [NUM_LANES-1:0]        phy_lane_polarity;
    logic                         phy_tx_ready;
    logic                         phy_rx_ready;
    logic                         phy_init_cont_set;
    // Connect HMC
    logic                         P_RST_N;
    logic                         LXRXPS;
    logic                         LXTXPS;
    logic                         FERR_N;
    // Connect RF
    logic  [HMC_RF_AWIDTH-1:0]    rf_address;
    logic  [HMC_RF_RWIDTH-1:0]    rf_read_data;
    logic                         rf_invalid_address;
    logic                         rf_access_complete;
    logic                         rf_read_en;
    logic                         rf_write_en;
    logic  [HMC_RF_WWIDTH-1:0]    rf_write_data;

    int TNULL = 220ns;
    int tTRET = 1000ns;

    openhmc_top #(FPW  ,LOG_FPW ,DWIDTH, LOG_NUM_LANES, NUM_LANES, NUM_DATA_BYTES, HMC_RF_WWIDTH,HMC_RF_RWIDTH, 
                HMC_RF_AWIDTH ,LOG_MAX_RX_TOKENS, LOG_MAX_HMC_TOKENS, HMC_RX_AC_COUPLED, DETECT_LANE_POLARITY, 
                CTRL_LANE_POLARITY, CTRL_LANE_REVERSAL, CTRL_SCRAMBLERS, OPEN_RSP_MODE, RX_RELAX_INIT_TIMING ,
                RX_BIT_SLIP_CNT_LOG ,SYNC_AXI4_IF , XIL_CNT_PIPELINED, BITSLIP_SHIFT_RIGHT ,DBG_RX_TOKEN_MON
                )
                DUT
                (
                // SYSTEM INTERFACES
                .clk_user(clk_user),
                .clk_hmc(clk_hmc),
                .res_n_user(res_n_user), 
                .res_n_hmc(res_n_hmc),
                // From AXI to HMC Ctrl TX
                .s_axis_tx_TVALID(s_axis_tx_TVALID),
                .s_axis_tx_TREADY(s_axis_tx_TREADY),
                .s_axis_tx_TDATA(s_axis_tx_TDATA),
                .s_axis_tx_TUSER(s_axis_tx_TUSER),
                // From HMC Ctrl RX to AXI
                .m_axis_rx_TVALID(m_axis_rx_TVALID),
                .m_axis_rx_TREADY(m_axis_rx_TREADY),
                .m_axis_rx_TDATA(m_axis_rx_TDATA),
                .m_axis_rx_TUSER(m_axis_rx_TUSER),
                // Connect Transceiver
                .phy_data_tx_link2phy(phy_data_tx_link2phy),
                .phy_data_rx_phy2link(phy_data_rx_phy2link),
                .phy_bit_slip(phy_bit_slip),   
                .phy_lane_polarity(phy_lane_polarity),
                .phy_tx_ready(phy_tx_ready),    
                .phy_rx_ready(phy_rx_ready),
                .phy_init_cont_set(phy_init_cont_set),
                // Connect HMC
                .P_RST_N(P_RST_N),
                .LXRXPS(LXRXPS),
                .LXTXPS(LXTXPS),
                .FERR_N(FERR_N),
                // Connect RF
                .rf_address(rf_address),
                .rf_read_data(rf_read_data),
                .rf_invalid_address(rf_invalid_address),
                .rf_access_complete(rf_access_complete),
                .rf_read_en(rf_read_en),
                .rf_write_en(rf_write_en),
                .rf_write_data(rf_write_data)
                );

    initial begin : clock
        clk_user = 1;
        clk_hmc = 1;
        forever begin
            #5;
            clk_user = ~clk_user;
            clk_hmc  = ~clk_hmc;
        end
    end : clock

    initial begin : reset
        // set rst "Active Low resets" 3 cycles
        res_n_user = 0; // The AXI-4 user interface may remain in reset during the initialization process "page 25: openHMC_documentation_1_5"
        res_n_hmc  = 0;
        #30; 
        res_n_hmc  = 1; 
        res_n_user = 1;
    end : reset
    

    /*
    initial begin : stop
        #355; // 690
        $display("Simulation Time ended");
        $finish; 
    end : stop
    */

    initial begin
        #40;
        // 1. FERR_N: Fatal error indicator. HMC drives LOW if fatal error occurs 
        FERR_N = 1'b1;

        // 2. disable scrambler and run length limiter
        @(posedge clk_hmc);
            rf_address    = 4'b0010;
            rf_read_en    = 1'b0;
            rf_write_en   = 1'b1;
            rf_write_data = 64'h181000FF0030;
        @(posedge clk_hmc);
            rf_read_en    = 1'b0;
            rf_write_en   = 1'b0;

        // 3. set LXTXPS
        repeat(2) @(posedge clk_hmc);
            LXTXPS = 1'b1;

        // 4. set P_RST_N using Register file
        repeat(2) @(posedge clk_hmc);
            rf_address    = 4'b0010;
            rf_read_en    = 1'b0;
            rf_write_en   = 1'b1;
            rf_write_data = 64'h181000FF0031; 
        @(posedge clk_hmc);
            rf_read_en    = 1'b0;
            rf_write_en   = 1'b0;
        
        // 5. phy_data_rx_phy2link = Nulls or PRBS but in case of HMC Memory it should be PRBS "Pseudo Random binary sequence"
        repeat(3) @(posedge clk_hmc);
            phy_data_rx_phy2link = {DWIDTH{1'b0}}; 
        
        // 6. set phy_tx_ready, phy_rx_ready signals and the init_cont_set in the Register file
        repeat(7) @(posedge clk_hmc);
            phy_tx_ready = 1'b1;
            phy_rx_ready = 1'b1;

            rf_address    = 4'b0010;
            rf_read_en    = 1'b0;
            rf_write_en   = 1'b1;
            rf_write_data = 64'h181000FF0033;
        @(posedge clk_hmc);
            rf_read_en    = 1'b0;
            rf_write_en   = 1'b0; 
        
        #TNULL;

        case(FPW)
            2: begin
                // 7. wait until all descramblers are aligned 'synchronized'
                @(posedge clk_hmc);
                for(bit[15:0] i=0; i<=15; i++) begin
                    phy_data_rx_phy2link = {{16'hF0C0 + i},{14{16'hF050 +i}},{16'hF030 + i}};
                    wait(phy_bit_slip !=0);
                    //repeat(4)@(posedge clk_hmc);
                    wait(phy_bit_slip ==0);
                    repeat(2)@(posedge clk_hmc);
                    wait(phy_bit_slip ==0);
                    if(phy_bit_slip ==0)begin
                        wait(phy_bit_slip !=0);
                        wait(phy_bit_slip ==0);
                        wait(phy_bit_slip !=0);
                    end
                    else if (phy_bit_slip !=0) begin
                        wait(phy_bit_slip ==0);
                        wait(phy_bit_slip !=0);
                    end
                end
                
                // 8. null packet send '16 packet to enter TRET State'
                phy_data_rx_phy2link = {DWIDTH{1'b0}};
                repeat(5) @(posedge clk_hmc); // number of null cycles sent = 4'b1111 = 4'd15;

                // 9. TRET State
                phy_data_rx_phy2link = {'h0, 128'hA1098C6C380239830000000000000882};
                #100;
            end
            default: begin // FPW=4
                repeat(2) begin
                    // 7. wait until all descramblers are aligned 'synchronized'
                    @(posedge clk_hmc);
                    for(bit[15:0]j=0; j<=14; j+=2) begin
                        phy_data_rx_phy2link = {{16'hf0c1+j}, {16'hf0c0+j}, {14{{16'hf051+j},{16'hf050+j}}}, {16'hf031+j}, {16'hf030+j}};
                        wait(phy_bit_slip !=0);
                        //repeat(4)@(posedge clk_hmc);
                        wait(phy_bit_slip ==0);
                        repeat(2)@(posedge clk_hmc);
                        wait(phy_bit_slip ==0);
                        if(phy_bit_slip ==0)begin
                            wait(phy_bit_slip !=0);
                            wait(phy_bit_slip ==0);
                            wait(phy_bit_slip !=0);
                        end
                        else if (phy_bit_slip !=0) begin
                            wait(phy_bit_slip ==0);
                            wait(phy_bit_slip !=0);
                        end
                    end
                end

                // 8. null packet send '16 packet to enter TRET State'
                phy_data_rx_phy2link = {DWIDTH{1'b0}};
                repeat(5) @(posedge clk_hmc); // number of null cycles sent = 4'b1111 = 4'd15;

                // 9. TRET State
                phy_data_rx_phy2link = {'h0, 128'hA1098C6C380239830000000000000882};
                #tTRET;
            end
        endcase
        $finish;
    end
endmodule: openhmc_top_test
