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
    //From AXI to HMC Ctrl TX
    input  wire                         s_axis_tx_TVALID,
    output wire                         s_axis_tx_TREADY,
    input  wire [DWIDTH-1:0]            s_axis_tx_TDATA,
    input  wire [NUM_DATA_BYTES-1:0]    s_axis_tx_TUSER,
*/


interface AXI_Slave_interface  ;

    base_interface base();
    //From AXI to HMC Ctrl TX
    wire                         s_axis_tx_TVALID;
    wire                         s_axis_tx_TREADY;
    wire [base.DWIDTH-1:0]            s_axis_tx_TDATA;
    wire [base.NUM_DATA_BYTES-1:0]    s_axis_tx_TUSER;


endinterface : AXI_Slave_interface 




