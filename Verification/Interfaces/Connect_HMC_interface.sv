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
DUT Signals for the HMC interface:
    //----------------------------------
    //----Connect HMC
    //----------------------------------
    output wire                         P_RST_N,
    output wire                         LXRXPS,
    input  wire                         LXTXPS,
    input  wire                         FERR_N,
*/




interface HMC_interface  ;

    logic                          P_RST_N;
    logic                          LXRXPS ;
    logic                          LXTXPS ;
    logic                          FERR_N ;


    task load (input LXTXPS_l,FERR_N_l, output P_RST_N_l, LXRXPS_l);
          LXTXPS = LXTXPS_l;
          FERR_N = FERR_N_l;	
          P_RST_N_l = 1;
          LXRXPS_l = 1;

    endtask : load

endinterface : HMC_interface
