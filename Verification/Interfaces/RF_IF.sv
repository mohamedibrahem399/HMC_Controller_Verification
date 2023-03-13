interface RF_IF #(parameter HMC_RF_WWIDTH= 64, parameter HMC_RF_RWIDTH= 64, parameter HMC_RF_AWIDTH= 4)(input bit clk_hmc, res_n_hmc);
    logic [HMC_RF_WWIDTH-1:0]rf_write_data; // Value to be written
    logic [HMC_RF_RWIDTH-1:0]rf_read_data;  // Requested Value; Valid when access_complete is asserted
    logic [HMC_RF_AWIDTH-1:0]rf_address;    // Address to be read or written to.
    logic rf_read_en;                       // Read the address provided
    logic rf_write_en;                      // Write the value of write_data to the address provided
    logic rf_invalid_address;               // Address out of the valid range
    logic rf_access_complete;               // Indicates a successful operation
endinterface