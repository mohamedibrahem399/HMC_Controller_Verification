interface Sys_IF;
    logic clk_user;    //Connect if SYNC_AXI4_IF==0
    logic clk_hmc;     //Connect!
    logic res_n_user;  //Connect if SYNC_AXI4_IF==0
    logic res_n_hmc;   //Connect!
endinterface :Sys_IF
