`include "HMC_Mem_Types_crc.svh"


class hmc_packet_crc extends uvm_sequence_item;
        
        rand hmc_command_encoding 	command;			// CMD
        rand bit [3:0]			packet_length;			// LNG 128-bit (16-byte) flits
        rand bit				data_invalid;			// DINV
	// request tail fields
        rand bit [4:0]			return_token_count;		// RTC
	rand bit [2:0]			source_link_ID;			// SLID
	rand bit [2:0]			sequence_number;		// SEQ
	rand bit [7:0]			forward_retry_pointer;	// FRP
	rand bit [7:0]			return_retry_pointer;	// RRP
	rand bit [31:0]		packet_crc;				// CRC


	// CRC status fields
	rand bit				poisoned;				// Inverted CRC
	rand bit				crc_error;

        `uvm_object_utils_begin(hmc_packet_crc)
		`uvm_field_enum(hmc_command_encoding,command,UVM_ALL_ON)
                //response pascket data
                `uvm_field_queue_int(data, UVM_ALL_ON)
                //response packet tail
                `uvm_field_int(packet_crc,       UVM_ALL_ON)
                `uvm_field_int(crc_error,       UVM_ALL_ON)
                `uvm_field_int(poisoned,       UVM_ALL_ON)
                `uvm_field_int(return_token_count,       UVM_ALL_ON)
                `uvm_field_int(ERRSTAT,   UVM_ALL_ON)
                `uvm_field_int(data_invalid,      UVM_ALL_ON)
                `uvm_field_int(sequence_number,       UVM_ALL_ON)
                `uvm_field_int(forward_retry_pointer,       UVM_ALL_ON)
                `uvm_field_int(return_retry_pointer,       UVM_ALL_ON)
	`uvm_object_utils_end

	constraint c_poisoned { poisoned == 0; }
        constraint c_crc_error { crc_error == 0; }
        constraint command_c {
		   command inside { 	HMC_WRITE_16,
			   					HMC_WRITE_32,
			   					HMC_WRITE_48,
			   					HMC_WRITE_64,
			   					HMC_WRITE_80,
			   					HMC_WRITE_96,
			   					HMC_WRITE_112,
			   					HMC_WRITE_128,
			   					
			   					HMC_MODE_WRITE,
								HMC_BIT_WRITE,
								HMC_DUAL_8B_ADDI,
								HMC_SINGLE_16B_ADDI,
			   					
			   					HMC_POSTED_WRITE_16,
			   					HMC_POSTED_WRITE_32,
			   					HMC_POSTED_WRITE_48,
			   					HMC_POSTED_WRITE_64,
			   					HMC_POSTED_WRITE_80,
			   					HMC_POSTED_WRITE_96,
			   					HMC_POSTED_WRITE_112,
			   					HMC_POSTED_WRITE_128,
			   					HMC_POSTED_BIT_WRIT,
			   					
			   					HMC_POSTED_BIT_WRIT,
								HMC_POSTED_DUAL_8B_ADDI,
								HMC_POSTED_SINGLE_16B_ADDI,
			   					
			   					HMC_MODE_READ,
			   					HMC_READ_16,
			   					HMC_READ_32,
			   					HMC_READ_48,
			   					HMC_READ_64,
			   					HMC_READ_80,
			   					HMC_READ_96,
			   					HMC_READ_112, 
			   					HMC_READ_128,
                          
                                                                HMC_READ_RESPONSE,
				                                HMC_WRITE_RESPONSE,
				                                HMC_MODE_READ_RESPONSE,
				                                HMC_MODE_WRITE_RESPONSE,
				                                HMC_ERROR_RESPONSE,

                                                                //HMC_MODE_READ_TYPE,
                                                                //HMC_FLOW_TYPE
                                                                  HMC_NULL,
                                                                  HMC_PRET,
                                                                  HMC_TRET,
                                                                  HMC_IRTRY
                                                                                                                            
			   
			   				};
	}
        constraint c_packet_length { (
						(packet_length == 2 && command == HMC_POSTED_WRITE_16) ||
						(packet_length == 3 && command == HMC_POSTED_WRITE_32) ||
						(packet_length == 4 && command == HMC_POSTED_WRITE_48) ||
						(packet_length == 5 && command == HMC_POSTED_WRITE_64) ||
						(packet_length == 6 && command == HMC_POSTED_WRITE_80) ||
						(packet_length == 7 && command == HMC_POSTED_WRITE_96) ||
						(packet_length == 8 && command == HMC_POSTED_WRITE_112) ||
						(packet_length == 9 && command == HMC_POSTED_WRITE_128) ||
						(packet_length == 2 && command == HMC_WRITE_16) ||
						(packet_length == 3 && command == HMC_WRITE_32) ||
						(packet_length == 4 && command == HMC_WRITE_48) ||
						(packet_length == 5 && command == HMC_WRITE_64) ||
						(packet_length == 6 && command == HMC_WRITE_80) ||
						(packet_length == 7 && command == HMC_WRITE_96) ||
						(packet_length == 8 && command == HMC_WRITE_112) ||
						(packet_length == 9 && command == HMC_WRITE_128) ||
						(packet_length > 1 && packet_length <= 9 && command == HMC_READ_RESPONSE) ||
						(packet_length == 1 && command == HMC_WRITE_RESPONSE) ||
						(packet_length == 1 && command == HMC_MODE_WRITE_RESPONSE) ||
						(packet_length == 1 && command == HMC_ERROR_RESPONSE) ||
						(packet_length == 1 && command inside {HMC_MODE_READ_RESPONSE, HMC_READ_RESPONSE}) ||
						(packet_length == 1 && command  inside{[HMC_READ_16:HMC_READ_128]}) ||
						(packet_length == 1 && command  inside {[HMC_NULL:HMC_IRTRY]})
		); }


/*
		The CRC algorithm used on the HMC is the Koopman CRC-32K. This algorithm was
		chosen for the HMC because of its balance of coverage and ease of implementation. The
		polynomial for this algorithm is:
		x32 + x30 + x29 + x28 + x26 + x20 + x19 + x17 + x16 + x15 + x11 + x10 + x7 + x6 + x4 + x2 + x + 1

		bit [31:0] polynomial = 32'b0111_0100_0001_1011_1000_1100_1101_0111;	// Normal

		The CRC calculation operates on the LSB of the packet first. The packet CRC calculation
		must insert 0s in place of the 32-bits representing the CRC field before generating or
		checking the CRC. For example, when generating CRC for a packet, bits [63: 32] of the
		Tail presented to the CRC generator should be all zeros. The output of the CRC generator
		will have a 32-bit CRC value that will then be inserted in bits [63:32] of the Tail before
		forwarding that FLIT of the packet. When checking CRC for a packet, the CRC field
		should be removed from bits [63:32] of the Tail and replaced with 32-bits of zeros, then
		presented to the CRC checker. The output of the CRC checker will have a 32-bit CRC
		value that can be compared with the CRC value that was removed from the tail. If the two
		compare, the CRC check indicates no bit failures within the packet.
*/
	
	function bit [31:0] calc_crc(bit bitstream[]);
		bit [32:0] polynomial = 33'h1741B8CD7; // Normal
		
		bit [32:0] remainder = 33'h0;
		for( int i=0; i < bitstream.size()-32; i++ ) begin	// without the CRC
			remainder = {remainder[31:0], bitstream[i]};
			if( remainder[32] ) begin
				remainder = remainder ^ polynomial;
			end
		end

		for( int i=0; i < 64; i++ ) begin	// zeroes for CRC and remainder
			remainder = {remainder[31:0], 1'b0};
			if( remainder[32] ) begin
				remainder = remainder ^ polynomial;
			end
		end

		return remainder[31:0];
	endfunction : calc_crc

endclass : hmc_packet_crc



// http://checksumcrc.blogspot.com/2023/01/explanation-of-crc-operation-polynomial.html 
// https://www.lddgo.net/en/encrypt/crc 