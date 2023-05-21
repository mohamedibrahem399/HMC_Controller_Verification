//-------------------------------------------------------------------------------------------------------------
//										 request packets functions .....
//-------------------------------------------------------------------------------------------------------------
	function automatic put_crc_in_request_packet(ref HMC_Req_Sequence_item Req_seq_item);
		Req_seq_item.check_CMD_and_extract_request_packet_header_and_tail();
		Req_seq_item.CRC = calculate_request_packet_crc(Req_seq_item);
		Req_seq_item.packet[Req_seq_item.packet.size()-1][127:96] = Req_seq_item.CRC;
	endfunction: put_crc_in_request_packet


	function bit[1:0] request_packet_poison_checker_with_crc(HMC_Req_Sequence_item Req_seq_item);
		bit[31:0] temp1 = Req_seq_item.packet[Req_seq_item.packet.size()][127:96];
		bit[31:0] temp2 = calculate_request_packet_crc(Req_seq_item);
        if(temp1 == temp2) return 2'b00;
		else if (temp1 == !temp2 ) return 2'b01;
		else return 2'b11;
	endfunction: request_packet_poison_checker_with_crc


	function bit [31:0] calculate_request_packet_crc(HMC_Req_Sequence_item Req_seq_item);
        bit bitstream[];
      bitstream = new[Req_seq_item.packet.size()];
		Req_seq_item.check_CMD_and_extract_request_packet_header_and_tail();
        from_request_packet_to_bitstream(Req_seq_item,bitstream);
		return calc_crc(bitstream);
	endfunction: calculate_request_packet_crc
    

    function automatic from_request_packet_to_bitstream(HMC_Req_Sequence_item Req_seq_item , ref bit bitstream[]);
        for(int i =0 ; i<Req_seq_item.packet.size() ; i++) begin
            if(i==0)
                 for (int j =0 ; j<128; j++) bitstream[j] = Req_seq_item.packet[0][j];
            else if(i>0)
              for(int k=0;k<128;k++) bitstream[ 128*i + k ] = Req_seq_item.packet[i][k];
        end
    endfunction: from_request_packet_to_bitstream

//-------------------------------------------------------------------------------------------------------------
//										 calc_crc function .....
//-------------------------------------------------------------------------------------------------------------

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
 

//checksumcrc.blogspot.com/2023/01/explanation-of-crc-operation-polynomial.html
//https://www.lddgo.net/en/encrypt/crc