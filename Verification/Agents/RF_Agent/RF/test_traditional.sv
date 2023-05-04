module test_traditional;
  bit clk_hmc, res_n_hmc;
  bit [63:0] rf_write_data, rf_read_data;
  bit  rf_invalid_address, rf_access_complete, rf_read_en, rf_write_en;
  bit [3:0]  rf_address;
  
  RF_openhmc_top  dut1( clk_hmc,  res_n_hmc, rf_address,   rf_read_data, rf_invalid_address, rf_access_complete, rf_read_en, rf_write_en,  rf_write_data );
  
  initial begin
    forever begin
      #10; clk_hmc = ~clk_hmc;
    end 
  end
  
  initial begin
    res_n_hmc=0; #20; res_n_hmc = 1;
  end
  
  initial begin
    $displayb("%0t: ",$time,,   rf_read_data,,, rf_invalid_address,,, rf_access_complete,,,  rf_write_data );
    #40;
    @(posedge clk_hmc);
    rf_address =2;
    rf_write_data = {64{1'b1}};
    rf_read_en =0;
    rf_write_en =1;
    @(posedge clk_hmc);
    rf_read_en =0;
    rf_write_en =0;
    $displayb("%0t: ",$time,,   rf_read_data,,, rf_invalid_address,,, rf_access_complete,,,  rf_write_data );
    @(posedge clk_hmc);
    rf_write_data  = {64{1'b0}};
    rf_address     = {4{1'b0}};
    #30;
    @(posedge clk_hmc);
    rf_address =2;
    rf_read_en =1;
    rf_write_en =0;
    @(posedge clk_hmc);
    rf_read_en =0;
    rf_write_en =0;
    $displayb("%0t: ",$time,,   rf_read_data,,, rf_invalid_address,,, rf_access_complete,,,  rf_write_data );
    @(posedge clk_hmc);
    rf_write_data  = {64{1'b0}};
    rf_address     = {4{1'b0}};
  end
  
  initial begin
    #1000; $finish;
  end
  
  initial begin
    $dumpfile("test.vcd");
    $dumpvars;
  end
endmodule: test_traditional
