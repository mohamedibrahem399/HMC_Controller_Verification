
/*
DUT Signals for the HMC interface:
    //----------------------------------
    //----Connect HMC
    //----------------------------------
    output wire                         P_RST_N,
    output wire                         LXRXPS,
    input  wire                         LXTXPS,
    input  wire                         FERR_N,
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



class RA_seq_item extends uvm_sequence_item;

    // define base interface to get the main configurations.
    base_interface base();

    //----------------------------------
    //----Connect HMC
    //----------------------------------
    bit                        P_RST_N;// input  for the agent // the reset signal
    bit                        LXRXPS; // input  for the agent // for entering sleep mode or power reduction mode
    rand   bit                 LXTXPS; // output for the agent // for entering sleep mode or power reduction mode
    rand   bit                 FERR_N; // output for the agent // inicating a fatal error happens in the memory ( in this case the RA ).

    //----------------------------------
    //----Connect Transceiver
    //----------------------------------
    bit        [base.DWIDTH-1:0]           phy_data_tx_link2phy;//Connect! // the data came from the controller tx to the RA.
    rand  bit  [base.DWIDTH-1:0]           phy_data_rx_phy2link;//Connect! // the data came from the RA to the controller RX.
    bit        [base.NUM_LANES-1:0]        phy_bit_slip;        //Must be connected if DETECT_LANE_POLARITY==1 AND CTRL_LANE_POLARITY=0
    bit        [base.NUM_LANES-1:0]        phy_lane_polarity;   //All 0 if CTRL_LANE_POLARITY=1
    rand  bit                              phy_tx_ready;        //Optional information to RF
    rand  bit                              phy_rx_ready;        //Release RX descrambler reset when PHY ready
    bit                                    phy_init_cont_set;   //Can be used to release transceiver reset if used

  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------


  `uvm_object_utils_begin(RA_seq_item)

     // For the HMC interface signals...
    `uvm_field_int(P_RST_N                ,UVM_ALL_ON)
    `uvm_field_int(LXRXPS                 ,UVM_ALL_ON)
    `uvm_field_int(LXTXPS                 ,UVM_ALL_ON)
    `uvm_field_int(FERR_N                 ,UVM_ALL_ON)

     // For the Transceiver interface signals...
    `uvm_field_int(phy_data_tx_link2phy   ,UVM_ALL_ON)
    `uvm_field_int(phy_data_rx_phy2link   ,UVM_ALL_ON)
    `uvm_field_int(phy_bit_slip           ,UVM_ALL_ON)
    `uvm_field_int(phy_lane_polarity      ,UVM_ALL_ON)
    `uvm_field_int(phy_tx_ready           ,UVM_ALL_ON)
    `uvm_field_int(phy_rx_ready           ,UVM_ALL_ON)
    `uvm_field_int(phy_init_cont_set      ,UVM_ALL_ON)

  `uvm_object_utils_end

  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "mem_seq_item");
    super.new(name);
  endfunction
  
  //---------------------------------------
  //constaint, to generate any one among write and read
  //---------------------------------------
  constraint default_values { phy_rx_ready != phy_tx_ready;
    if( LXRXPS == 1  ) LXTXPS ==1; else LXTXPS ==0; 
    FERR_N == 0; }


endclass
