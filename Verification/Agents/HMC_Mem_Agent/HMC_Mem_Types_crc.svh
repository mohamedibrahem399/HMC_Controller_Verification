typedef enum bit [5:0] {HMC_WRITE_16 = 6'b001000,
			   					HMC_WRITE_32 = 6'b001001,
			   					HMC_WRITE_48 = 6'b001010,
			   					HMC_WRITE_64 = 6'b001011,
			   					HMC_WRITE_80 = 6'b001100,
			   					HMC_WRITE_96 = 6'b001101,
			   					HMC_WRITE_112 = 6'b001110,
			   					HMC_WRITE_128 = 6'b001111,
			   					
			   					HMC_MODE_WRITE = 6'b010000,
								HMC_BIT_WRITE = 6'b010001,
								HMC_DUAL_8B_ADDI = 6'b010010,
								HMC_SINGLE_16B_ADDI = 6'b010011,
			   					
			   					HMC_POSTED_WRITE_16 = 6'b011000,
			   					HMC_POSTED_WRITE_32 = 6'b011001,
			   					HMC_POSTED_WRITE_48 = 6'b011010,
			   					HMC_POSTED_WRITE_64 = 6'b011011,
			   					HMC_POSTED_WRITE_80 = 6'b011100,
			   					HMC_POSTED_WRITE_96 = 6'b011101,
			   					HMC_POSTED_WRITE_112 = 6'b011110,
			   					HMC_POSTED_WRITE_128 = 6'b011111,
			   					HMC_POSTED_BIT_WRIT = 6'b100001,
			   					
								HMC_POSTED_DUAL_8B_ADDI = 6'b100010,
								HMC_POSTED_SINGLE_16B_ADDI = 6'b100011,
			   					
			   					HMC_MODE_READ = 6'b101000,
			   					HMC_READ_16 = 6'b110000,
			   					HMC_READ_32 = 6'b110001,
			   					HMC_READ_48 = 6'b110010,
			   					HMC_READ_64 = 6'b110011,
			   					HMC_READ_80 = 6'b110100,
			   					HMC_READ_96 = 6'b110101,
			   					HMC_READ_112 = 6'b110110, 
			   					HMC_READ_128= 6'b110111,
                          
                                                                HMC_READ_RESPONSE = 6'b111000,
				                                HMC_WRITE_RESPONSE = 6'b111001,
				                                HMC_ERROR_RESPONSE = 6'b111110,
				                                HMC_MODE_READ_RESPONSE = 6'b111010,
				                                HMC_MODE_WRITE_RESPONSE = 6'b111011,
        
                                                                //HMC_MODE_READ_TYPE,
                                                                //HMC_FLOW_TYPE
                                                                // Null
                                                                 HMC_NULL = 6'b000000,
                                                                 // Retry pointer return
	                                                         HMC_PRET = 6'b000001,
                                                                 // Token return
								 HMC_TRET = 6'b000010,
                                                                 // Init retry
								 HMC_IRTRY = 6'b000011} hmc_command_encoding;


/*typedef enum bit [5:0] {
	HMC_FLOW_TYPE = 6'h000000,
	HMC_WRITE_TYPE = 6'h001000,
	HMC_POSTED_WRITE_TYPE = 6'h011000,
	HMC_MODE_READ_TYPE = 6'h101000,
	HMC_READ_TYPE = 6'h110000,
	HMC_RESPONSE_TYPE = 6'h111000
} hmc_command_type;*/


typedef enum bit [5:0] {
	HMC_FLOW_TYPE = 6'h00,
	HMC_WRITE_TYPE = 6'h08,
	HMC_POSTED_WRITE_TYPE = 6'h18,
	HMC_MODE_READ_TYPE = 6'h28,
	HMC_READ_TYPE = 6'h30,
	HMC_RESPONSE_TYPE = 6'h38
} hmc_command_type;
