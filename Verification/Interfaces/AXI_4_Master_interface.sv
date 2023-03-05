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
DUT Signals for the AXI interface:
    //----------------------------------
    //----Connect AXI Ports
    //----------------------------------
    //From HMC Ctrl RX to AXI
    output wire                         m_axis_rx_TVALID,
    input  wire                         m_axis_rx_TREADY,
    output wire [DWIDTH-1:0]            m_axis_rx_TDATA,
    output wire [NUM_DATA_BYTES-1:0]    m_axis_rx_TUSER,

*/

interface AXI_Master_interface  ;

    base_interface base();
    //From HMC Ctrl RX to AXI
    wire                              m_axis_rx_TVALID;
    wire                              m_axis_rx_TREADY;
    wire [base.DWIDTH-1:0]            m_axis_rx_TDATA;
    wire [base.NUM_DATA_BYTES-1:0]    m_axis_rx_TUSER;


endinterface : AXI_Master_interface
