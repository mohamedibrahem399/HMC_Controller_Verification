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
DUT Signals for the SYSTEM interface:

    //----------------------------------
    //----SYSTEM INTERFACES
    //----------------------------------
    input  wire                         clk_user,   //Connect if SYNC_AXI4_IF==0
    input  wire                         clk_hmc,    //Connect!
    input  wire                         res_n_user, //Connect if SYNC_AXI4_IF==0
    input  wire                         res_n_hmc,  //Connect!

*/




interface System_interface  ;

    bit                         clk_user;   //Connect if SYNC_AXI4_IF==0
    bit                         clk_hmc;    //Connect!
    wire                         res_n_user; //Connect if SYNC_AXI4_IF==0
    wire                         res_n_hmc;  //Connect!

initial begin
      clk_user = 0;
      clk_hmc  = 0;
      fork
         forever begin
            #10;
            clk_user = ~clk_user;
            clk_hmc  = ~clk_hmc ;
         end
      join_none
   end

endinterface : System_interface

