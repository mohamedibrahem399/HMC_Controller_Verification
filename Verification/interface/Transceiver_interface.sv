/*
This is a graduation project of some engineers at the faculity of engineering of Alexandira.
Project title: Verification using UVM for the HMC_Controller.

Made By:
        1) Mohamed Ibrahem Mohamed EL-Saeed Ibrahem.
        2) Tarek Rayan
        3) Eslamn EL-Feky
        4) Kholoud Ebrahem      
        5) Omnia Mohamed
        6) Youmna Mohamed Refat
        7) Rana Yasser Shafeek
        8) Omnia Salah Mohamed.


Electrical and communication engineers at Alexandira univeristy at Egypt.

Date: 5/3/2023

*/

/*
DUT Signals for the Transceiver interface:

    //----------------------------------
    //----Connect Transceiver
    //----------------------------------
    output wire  [DWIDTH-1:0]           phy_data_tx_link2phy,//Connect!
    input  wire  [DWIDTH-1:0]           phy_data_rx_phy2link,//Connect!
    output wire  [NUM_LANES-1:0]        phy_bit_slip,       //Must be connected if DETECT_LANE_POLARITY==1 AND CTRL_LANE_POLARITY=0
    output wire  [NUM_LANES-1:0]        phy_lane_polarity,  //All 0 if CTRL_LANE_POLARITY=1
    input  wire                         phy_tx_ready,       //Optional information to RF
    input  wire                         phy_rx_ready,       //Release RX descrambler reset when PHY ready
    output wire                         phy_init_cont_set,  //Can be used to release transceiver reset if used

*/




interface Transceiver_interface  ;

    base_interface base();

    logic  [base.DWIDTH-1:0]           phy_data_tx_link2phy;//Connect!
    logic  [base.DWIDTH-1:0]           phy_data_rx_phy2link;//Connect!
    logic  [base.NUM_LANES-1:0]        phy_bit_slip;        //Must be connected if DETECT_LANE_POLARITY==1 AND CTRL_LANE_POLARITY=0
    logic  [base.NUM_LANES-1:0]        phy_lane_polarity;   //All 0 if CTRL_LANE_POLARITY=1
    logic                              phy_tx_ready;        //Optional information to RF
    logic                              phy_rx_ready;        //Release RX descrambler reset when PHY ready
    logic                              phy_init_cont_set;   //Can be used to release transceiver reset if used

    task load (input phy_tx_ready_l, phy_rx_ready_l,
               input [base.DWIDTH-1:0] phy_data_rx_phy2link_l,
               output [base.DWIDTH-1:0] phy_data_tx_link2phy_l,
               output [base.NUM_LANES-1:0] phy_bit_slip_l, phy_lane_polarity_l,
               output phy_init_cont_set_l );


          phy_tx_ready = phy_tx_ready_l;
          phy_rx_ready = phy_rx_ready_l;	
          phy_data_rx_phy2link = phy_data_rx_phy2link_l;	
          phy_lane_polarity_l = 0;
          phy_bit_slip_l = 0;
          phy_lane_polarity_l = 0;
          phy_init_cont_set_l = 0;

    endtask : load

endinterface : Transceiver_interface












