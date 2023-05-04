`include "openhmc_counter48.v"
`include "openhmc_rf.v"


`default_nettype none

module RF_openhmc_top #(
    parameter LOG_NUM_LANES         = 3,                //Set 3 for half-width, 4 for full-width
    parameter NUM_LANES             = 2**LOG_NUM_LANES, //Leave untouched
    
    //Define width of the register file
    parameter HMC_RF_WWIDTH         = 64,   //Leave untouched    
    parameter HMC_RF_RWIDTH         = 64,   //Leave untouched
    parameter HMC_RF_AWIDTH         = 4,    //Leave untouched
    //Configure the Functionality
    parameter LOG_MAX_RX_TOKENS     = 8,    //Set the depth of the RX input buffer. Must be >= LOG(rf_rx_buffer_rtc) in the RF. Dont't care if OPEN_RSP_MODE=1
    parameter LOG_MAX_HMC_TOKENS    = 10,   //Set the depth of the HMC input buffer. Must be >= LOG of the corresponding field in the HMC internal register
    parameter HMC_RX_AC_COUPLED     = 1,    //Set to 0 to bypass the run length limiter, saves logic and 1 cycle delay
    parameter DETECT_LANE_POLARITY  = 1,    //Set to 0 if lane polarity is not applicable, saves logic
    parameter CTRL_LANE_POLARITY    = 1,    //Set to 0 if lane polarity is not applicable or performed by the transceivers, saves logic and 1 cycle delay
                                            //If set to 1: Only valid if DETECT_LANE_POLARITY==1, otherwise tied to zero
    parameter CTRL_LANE_REVERSAL    = 1,    //Set to 0 if lane reversal is not applicable or performed by the transceivers, saves logic
    parameter CTRL_SCRAMBLERS       = 1,    //Set to 0 to remove the option to disable (de-)scramblers for debugging, saves logic
    parameter OPEN_RSP_MODE         = 0,    //Set to 1 if running response open loop mode, bypasses the RX input buffer
    parameter RX_RELAX_INIT_TIMING  = 1,    //Per default, incoming TS1 sequences are only checked for the lane independent h'F0 sequence. Save resources and
                                            //eases timing closure. !Lane reversal is still detected
    parameter RX_BIT_SLIP_CNT_LOG   = 5,    //Define the number of cycles between bit slips. Refer to the transceiver user guide
                                            //Example: RX_BIT_SLIP_CNT_LOG=5 results in 2^5=32 cycles between two bit slips
    parameter SYNC_AXI4_IF          = 0,    //Set to 1 if AXI IF is synchronous to clk_hmc to use simple fifos
    parameter XIL_CNT_PIPELINED     = 0,    //If Xilinx counters are used, set to 1 to enabled output register pipelining
    //Set the direction of bitslip. Set to 1 if bitslip performs a shift right, otherwise set to 0 (see the corresponding transceiver user guide)
    parameter BITSLIP_SHIFT_RIGHT   = 1,    
    //Debug Params
    parameter DBG_RX_TOKEN_MON      = 1     //Set to 0 to remove the RX Link token monitor, saves logic
) (
    //----------------------------------
    //----SYSTEM INTERFACES
    //----------------------------------
    input  wire                         clk_hmc,    //Connect!
    input  wire                         res_n_hmc,  //Connect!




    //----------------------------------
    //----Connect RF
    //----------------------------------
    input  wire  [HMC_RF_AWIDTH-1:0]    rf_address,
    output wire  [HMC_RF_RWIDTH-1:0]    rf_read_data,
    output wire                         rf_invalid_address,
    output wire                         rf_access_complete,
    input  wire                         rf_read_en,
    input  wire                         rf_write_en,
    input  wire  [HMC_RF_WWIDTH-1:0]    rf_write_data

    );

//=====================================================================================================
//-----------------------------------------------------------------------------------------------------
//---------WIRING AND SIGNAL STUFF---------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------
//=====================================================================================================


`ifdef XILINX
    localparam RF_COUNTER_SIZE          = 48;
`else
    localparam RF_COUNTER_SIZE          = 64;
`endif                                 

// ----Register File
//Counter
wire                        rf_cnt_retry;
wire                        rf_run_length_bit_flip;
wire                        rf_error_abort_not_cleared;
wire  [RF_COUNTER_SIZE-1:0] rf_cnt_poisoned;
wire  [RF_COUNTER_SIZE-1:0] rf_cnt_p;
wire  [RF_COUNTER_SIZE-1:0] rf_cnt_np;
wire  [RF_COUNTER_SIZE-1:0] rf_cnt_r;
wire  [RF_COUNTER_SIZE-1:0] rf_cnt_rsp_rcvd;
//Status
wire                        rf_link_up;
wire [2:0]                  rf_rx_init_status;
wire [1:0]                  rf_tx_init_status;
wire [LOG_MAX_HMC_TOKENS-1:0]rf_hmc_tokens_av;
wire [LOG_MAX_RX_TOKENS-1:0]rf_rx_tokens_av;
//Init Status
wire                        rf_all_descramblers_aligned;
wire [NUM_LANES-1:0]        rf_descrambler_aligned;
wire [NUM_LANES-1:0]        rf_descrambler_part_aligned;
//Control
wire                        rf_hmc_init_cont_set;
wire                        rf_set_hmc_sleep;
wire                        rf_warm_reset;
wire                        rf_scrambler_disable;
wire [NUM_LANES-1:0]        rf_lane_polarity;
wire [NUM_LANES-1:0]        rf_descramblers_locked;
wire [LOG_MAX_RX_TOKENS-1:0]rf_rx_buffer_rtc;
wire                        rf_lane_reversal_detected;
wire [4:0]                  rf_irtry_received_threshold;
wire [4:0]                  rf_irtry_to_send;
wire                        rf_run_length_enable;



//Generate
wire                    rf_scrambler_disable_temp;
wire [LOG_MAX_RX_TOKENS-1:0]  rf_rx_buffer_rtc_temp;
generate
    if(CTRL_SCRAMBLERS==1) begin : ctrl_scramblers
        assign rf_scrambler_disable = rf_scrambler_disable_temp;
    end else begin : remove_scrambler_disable_bit
        assign rf_scrambler_disable = 1'b0;
    end
    if(OPEN_RSP_MODE==1) begin : remove_rx_tokens_rsp_open_loop_mode
        assign rf_rx_buffer_rtc = {LOG_MAX_RX_TOKENS{1'b0}};
    end else begin : regular_mode_use_rx_tokens
        assign rf_rx_buffer_rtc = rf_rx_buffer_rtc_temp;
    end
endgenerate


//----------------------------------------------------------------------
//---Register File---Register File---Register File---Register File---Reg
//----------------------------------------------------------------------
    openhmc_rf #(
        .NUM_LANES(NUM_LANES),
        .XIL_CNT_PIPELINED(XIL_CNT_PIPELINED),
        .LOG_MAX_RX_TOKENS(LOG_MAX_RX_TOKENS),
        .LOG_MAX_HMC_TOKENS(LOG_MAX_HMC_TOKENS),
        .RF_COUNTER_SIZE(RF_COUNTER_SIZE),
        .HMC_RF_WWIDTH(HMC_RF_WWIDTH),
        .HMC_RF_AWIDTH(HMC_RF_AWIDTH),
        .HMC_RF_RWIDTH(HMC_RF_RWIDTH)
    ) openhmc_rf_I (
        //system IF
        .res_n(res_n_hmc),
        .clk(clk_hmc),

        //rf access
        .address(rf_address),
        .read_data(rf_read_data),
        .invalid_address(rf_invalid_address),
        .access_complete(rf_access_complete),
        .read_en(rf_read_en),
        .write_en(rf_write_en),
        .write_data(rf_write_data),

        //status registers
        .status_general_link_up_next(rf_link_up),
        .status_general_link_training_next(~rf_link_up),
        .status_general_sleep_mode_next(1'b0),
        .status_general_FERR_N_next(1'b0),
        .status_general_phy_tx_ready_next(1'b0),
        .status_general_phy_rx_ready_next(1'b0),
        .status_general_lanes_reversed_next(rf_lane_reversal_detected),
        .status_general_hmc_tokens_remaining_next(rf_hmc_tokens_av),
        .status_general_rx_tokens_remaining_next(rf_rx_tokens_av),
        .status_general_lane_polarity_reversed_next(rf_lane_polarity),

        //init status
        .status_init_lane_descramblers_locked_next(rf_descramblers_locked),
        .status_init_descrambler_part_aligned_next(rf_descrambler_part_aligned),
        .status_init_descrambler_aligned_next(rf_descrambler_aligned),
        .status_init_all_descramblers_aligned_next(rf_all_descramblers_aligned),
        .status_init_rx_init_state_next(rf_rx_init_status),
        .status_init_tx_init_state_next(rf_tx_init_status),

        //counters
        .sent_np_cnt_next(rf_cnt_np),
        .sent_p_cnt_next(rf_cnt_p),
        .sent_r_cnt_next(rf_cnt_r),
        .poisoned_packets_cnt_next(rf_cnt_poisoned),
        .rcvd_rsp_cnt_next(rf_cnt_rsp_rcvd),

        //Single bit counter
        .tx_link_retries_count_countup(rf_cnt_retry),
        .errors_on_rx_count_countup(1'b1),
        .run_length_bit_flip_count_countup(rf_run_length_bit_flip),
        .error_abort_not_cleared_count_countup(rf_error_abort_not_cleared),

        //control
       // .control_p_rst_n(1'b0),
        .control_hmc_init_cont_set(rf_hmc_init_cont_set),
        .control_set_hmc_sleep(rf_set_hmc_sleep),
        .control_warm_reset(rf_warm_reset),
        .control_scrambler_disable(rf_scrambler_disable_temp),
        .control_run_length_enable(rf_run_length_enable),
        .control_rx_token_count(rf_rx_buffer_rtc_temp),
        .control_irtry_received_threshold(rf_irtry_received_threshold),
        .control_irtry_to_send(rf_irtry_to_send)
    );

endmodule

`default_nettype wire
