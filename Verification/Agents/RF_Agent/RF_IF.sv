interface RF_IF (input bit clk_hmc, res_n_hmc);
    logic [63:0]rf_write_data; // Value to be written
    logic [63:0]rf_read_data;  // Requested Value; Valid when access_complete is asserted
    logic [ 3:0]rf_address;    // Address to be read or written to.
    logic rf_read_en;                       // Read the address provided
    logic rf_write_en;                      // Write the value of write_data to the address provided
    logic rf_invalid_address;               // Address out of the valid range
    logic rf_access_complete;               // Indicates a successful operation

endinterface
