interface RF_IF (input bit clk_hmc, res_n_hmc);
    logic [63:0]rf_write_data; // Value to be written
    logic [63:0]rf_read_data;  // Requested Value; Valid when access_complete is asserted
    logic [ 3:0]rf_address;    // Address to be read or written to.
    logic rf_read_en;                       // Read the address provided
    logic rf_write_en;                      // Write the value of write_data to the address provided
    logic rf_invalid_address;               // Address out of the valid range
    logic rf_access_complete;               // Indicates a successful operation

    // assertions for wen, ren, inv_addr & access_comp
    // assert(0) -> Offending 
    property wen_valid;
        // not working in the reset case 'active low'
        @(posedge clk_hmc) disable iff (!res_n_hmc)
        // wen on when address and write data not x or z
        rf_write_en |-> !$isunknown(rf_invalid_address) && !$isunknown(rf_write_data);
    endproperty :wen_valid

    property ren_valid;
        // not working in the reset case 'active low'
        @(posedge clk_hmc) disable iff (!res_n_hmc)
        // ren set when address not x or z
        rf_read_en |-> !$isunknown(rf_address);
    endproperty :ren_valid

    property wen_ren_not_together;
        // not working in the reset case 'active low'
        @(posedge clk_hmc) disable iff (!res_n_hmc)
        (rf_write_en |-> !rf_read_en) or (rf_read_en |-> !rf_write_en);
    endproperty :wen_ren_not_together

    property access_complete_valid;
        // not working in the reset case 'active low'
        @(posedge clk_hmc) disable iff (!res_n_hmc)
        // wen or ren is 1 and after clk cycle 0, 
        (rf_write_en||rf_read_en) |=> !(rf_write_en||rf_read_en)[*0:$] ##1 rf_access_complete;
    endproperty :access_complete_valid

    property access_complete_1_cycle;
        // not working in the reset case 'active low'
        @(posedge clk_hmc) disable iff (!res_n_hmc)
        $rose(rf_access_complete) |=> !(rf_access_complete);
    endproperty :access_complete_1_cycle

    property invalid_addr_access_complete_together;
        // not working in the reset case 'active low'
        @(posedge clk_hmc) disable iff (!res_n_hmc)
        // access complete and invalid address in the same cycle
        rf_invalid_address |-> rf_access_complete;
    endproperty :invalid_addr_access_complete_together

    ass1: assert property (wen_valid) 
		$info("ASS1:", "Assertion passed, Write enable valid.");
    else 
		$error("ERR1:", "Assertion failed, Write enable not valid.");

    ass2: assert property (ren_valid) 
		$info("ASS2:", "Assertion passed, read enable valid.");
    else 
		$error("ERR2: ", "Assertion failed, read enable not valid.");

    ass3: assert property (wen_ren_not_together) 
		$info("ASS3:", "Assertion passed, Write and read enable not on the same clk cycle.");
    else 
		$error("ERR3: ", "Assertion failed, Write and read enable on the same clk cycle.");

    ass4: assert property (access_complete_valid) 
		$info("ASS4:", "Assertion passed, Write enable valid.");
    else 
		$error("ERR4: ", "Assertion failed, access complete not valid.");

    ass5: assert property (access_complete_1_cycle) 
		$info("ASS5:", "Assertion passed,  access complete valid.");
    else 
		$error("ERR5: ", "Assertion failed, access complete takes more than one clk cycle.");

    ass6: assert property (invalid_addr_access_complete_together) 
		$info("ASS6:", "Assertion passed, access complete and invalid address not together.");
    else 
	$error("ERR6: ", "Assertion failed, access complete and invalid address not together.");
endinterface
