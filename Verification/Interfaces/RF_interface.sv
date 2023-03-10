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
DUT Signals for the RF:

    input  wire  [HMC_RF_AWIDTH-1:0]    rf_address,
    output wire  [HMC_RF_RWIDTH-1:0]    rf_read_data,
    output wire                         rf_invalid_address,
    output wire                         rf_access_complete,
    input  wire                         rf_read_en,
    input  wire                         rf_write_en,
    input  wire  [HMC_RF_WWIDTH-1:0]    rf_write_data

*/




interface RF_interface  ;

    base_interface base();

    wire  [base.HMC_RF_AWIDTH-1:0]    rf_address;
    wire  [base.HMC_RF_RWIDTH-1:0]    rf_read_data;
    wire                         rf_invalid_address;
    wire                         rf_access_complete;
    wire                         rf_read_en;
    wire                         rf_write_en;
    wire  [base.HMC_RF_WWIDTH-1:0]    rf_write_data;



endinterface : RF_interface












