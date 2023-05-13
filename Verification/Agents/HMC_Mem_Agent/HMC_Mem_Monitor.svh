/* monitor in 
       initialization -> done
       normal mode -> done.
       sleep mode -> done.
       IDLE mode  -> done.
       link retry mode -> done.
*/

/*
  // what should we do in this case???
  //PRET
  wire    [63:0]              pret_hdr;
  assign                      pret_hdr        = {6'h0,34'h0,9'h0,4'h1,4'h1,1'h0,6'b000001};
*/

class HMC_Mem_Monitor #(parameter FPW       = 4,
                        parameter DWIDTH    = FPW*128,
                        parameter NUM_LANES = 8) extends uvm_monitor;

  `uvm_component_utils(HMC_Mem_Monitor)

  // Virtual Interface
  virtual HMC_Mem_IF mem_vifc;
  //sequence item
  HMC_Req_Sequence_item seq_item;
  hmc_packet_crc crc_class;
  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //***********************  connections and ports  ***********************

  // analysis port, to send the transaction to scoreboard (for scoreboard and coverage)
  uvm_analysis_port #(HMC_Req_Sequence_item) mem_to_scoreboard_port;

  uvm_analysis_port#(HMC_Req_Sequence_item) Monitor_to_mem_port; // "Reviewed"

  //uvm_blocking_put_port#(RA_seq_item) mem_put_port; // put port from monitor to memory // (Review what is better)

  //**********************************************************************************************************

  //---------------------------------------
  // build_phase - getting the interface handle and connection ports.
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq_item = HMC_Req_Sequence_item::type_id::create("seq_item", this);
    if(!uvm_config_db#(virtual HMC_Mem_IF)::get(this, "", "mem_vifc", mem_vifc))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".mem_vifc"});
    // this port is made for the outer subscribers.
    Monitor_to_mem_port = new("Monitor_to_mem_port", this);
    mem_to_scoreboard_port = new("mem_to_scoreboard_port",this);
  endfunction: build_phase
  //**********************************************************************************************************

  // control signals
  logic [DWIDTH-1:0] data_in_temp = 0;
  bit packet_captured = 0;
  bit new_flit =1;
  

  logic [127:0] packet[];
  logic [3:0] LNG;
  logic [5:0] CMD;
  logic [127:0] flit;
  logic [127:0] coming_flits[FPW];
  bit   [127:0] flits_queue [$];
  int c=0;
  bit test =0;
  int stored_flits_n=0;
  //**********************************************************************************************************
  // link retry flags....
  bit error_flag = 0;
  int error_cycle_counter = 0;
  bit link_retry_loop =0;

  //**********************************************************************************************************

  // initialization flags...
  bit link_on = 0;
  bit null1_received =0;
  bit null2_received =0;
  bit TS1_received =0;
  bit TRET_reveived =0;
  //**********************************************************************************************************

  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  
  virtual task run_phase(uvm_phase phase);
    forever begin
        @(posedge mem_vifc.hmc_clk);
        phase.raise_objection(this);
        if(mem_vifc.P_RST_N ==1) begin // not in the reset mode 
          if (link_on == 0) initialization_mode_operation();  // Initialization mode start....
          else if( link_on == 1 ) begin // After initialization mode... 
              if(mem_vifc.LXRXPS == 1 && error_flag == 0) begin // normal mode
                    normal_mode_operation();
                    seq_item.LXRXPS =mem_vifc.LXRXPS;
                    seq_item.link_retry_mode =0;
                    Monitor_to_mem_port.write(seq_item);
                    mem_to_scoreboard_port.write(seq_item);
                  end
              else if(error_flag ==1) begin // link retry mode
                    normal_mode_operation();
                    link_retry_loop = 1;
                    link_retry_operation();
              end
              else if( mem_vifc.LXRXPS == 0 )begin // sleep mode   // still working on it....
                    sleep_mode_operation();
                end
            end
        end
        else if (mem_vifc.P_RST_N == 0) reset_operation(); // reset mode.... (REVIEW)
        phase.drop_objection(this);
    end
  endtask : run_phase


  //**********************************************************************************************************
  /*
  The upcoming function does the monitor operation in normal mode.
  this operation is divided into 3 phases
    1st phase -> sniffing for upcoming data from the controller tx
    2nd phase -> storing the hall packet into a queue.
    3rd phase -> dequeue the stored packet and send it to the memory
  */



  //                  ********************** normal mode operation task **************************************** 
  task normal_mode_operation( );
    // collecting the full packet.
    while( test != 1 ) begin 
       receive_data_from_dut();                      // first phase
       store_received_data_in_queue();               // second phase
       dequeuing_full_packet_from_the_queue();       // final phase
       Check_link_retry();                       // if anything wrong happened (still working on it)
      end
    
    if (error_flag != 1) begin //send packets to memory (if there is no errors occurred)
        //save the collected packet in the sequence item and get it's LNG.
         seq_item.packet = new(LNG);
         seq_item.packet = packet;
         if (!seq_item.check_CMD_and_extract_request_packet_header_and_tail())
              `uvm_info("HMC_Mem_Monitor", "INVALID Packet CMD!", UVM_HIGH);
              // if there is invalid reٍquest CMD we should make something....
    end
    else if (error_flag == 1) begin
         seq_item.packet = new(LNG);
         seq_item.packet = packet;
         seq_item.check_CMD_and_extract_request_packet_header_and_tail();
    end
   reset_counters();
  endtask : normal_mode_operation


  // ********** receive_data_from_dut task **********
  task receive_data_from_dut();
       while ( packet_captured == 0 ) begin
	@(posedge mem_vifc.hmc_clk);
	 if(mem_vifc.phy_data_tx_link2phy == 0) begin // checking at this posedge whether there is data sent or just all zeros.
              $display("there is no data coming in this cycle %t ",$time); // IDLE mode, wating for any packet to be received.
              packet_captured = 0;
             end
         else if(mem_vifc.phy_data_tx_link2phy != 0) begin
              // assume we caught a packet from the                                  // *****************  (REVIEW)   *****************
               data_in_temp = mem_vifc.phy_data_tx_link2phy; // we will remove this 0 and put the descrambled input
               split_data_in( data_in_temp , coming_flits );

               if(new_flit==1)new_flit =1; else new_flit =0; // don't change it.
               packet_captured =1;
             end    
        end
  endtask:receive_data_from_dut


  // ********** split_data_in task **********
  // data in temp into coming flits
  function automatic split_data_in( bit [DWIDTH-1:0] data_in_temp, ref bit [127:0] coming_flits[FPW] );
     for( int i =0; i<FPW ; i++) 
         coming_flits[i] = data_in_temp [ 128*(i+1) -1  : i*128 ];
  endfunction: split_data_in


  // ********** store_received_data_in_queue task **********
   task store_received_data_in_queue();
        // start catching the packet.
        // after catching the new packet, we will store it in a queue.
           if(new_flit ==1 ) begin // new_flit = 1 means -> there is new packet received and we will need to know it's command and size.
              flit = coming_flits[0];
              CMD = flit[ 6:0 ]; // take the cmd from the header
              seq_item.set_LNG_from_cmd ( CMD , LNG );
              c=LNG;
              new_flit =0;
              packet = new(LNG);
              // store those flits in the queue.
              if (LNG <= FPW) begin // checking if the received packet length is less than FPW == 4
                                    // so that we will capture it in this cycle only
                   for (int x =0 ; x<LNG ; x++) begin
                        flits_queue.push_back(coming_flits[x]); 
                        stored_flits_n = stored_flits_n + 1; 
                      end
                   c=0;
                end
              else if (LNG > FPW) begin // checking if the received packet length ls more than FPW == 4 
                                        // so that it will take more than one cycle to be stored in the queue
                   for (int x =0 ; x<FPW ; x++) begin 
                        flits_queue.push_back(coming_flits[x]);
                        stored_flits_n = stored_flits_n + 1;
                      end
                   c=c-FPW;
                   packet_captured =0;
                 end
           end
         else if(new_flit == 0 && c>0) begin // new_flit = 0 means-> the received packet length at first was more than FPW == 4 
                                             // so it needed to be stored in more than one cycle.
                                             // in here, we continue receving the rest of the packet in next cycles.
              if (c <= FPW) begin // same as above.
                   for (int x =0 ; x<c ; x++) begin flits_queue.push_back(coming_flits[x]); stored_flits_n = stored_flits_n + 1; end
                   c=0;
                   end
              else if (c > FPW) begin // same as above.
                   for (int x =0 ; x<FPW ; x++) begin flits_queue.push_back(coming_flits[x]); stored_flits_n = stored_flits_n + 1; end
                   c=c-FPW;
                   packet_captured =0;
                   end
           end

  endtask:store_received_data_in_queue


  // ********** dequeuing_full_packet_from_the_queue task **********
  task dequeuing_full_packet_from_the_queue();
        // final phase -> dequeuing the hall packet from the queue.
          if( new_flit == 0 && c==0 && LNG == stored_flits_n) begin // ready to dequeue...
              for(int i=0; i< LNG; i++) flits_queue.pop_front(packet[i]);
              test = 1 ;     // needed to be deleted..        
           end
  endtask:dequeuing_full_packet_from_the_queue


  // ********** reset_counters task **********
  task reset_counters();
    c=0;
    test=0;
    new_flit =1;
    stored_flits_n=0;
    packet_captured =0;
    error_flag = 0;
  endtask:reset_counters

  //**********************************************************************************************************

  //                                    ********** Check_link_retry task **********

/*
monitor part:
1- detect error from "Cycle 1"
	a- Sequence number error. (we may neglect this error)
	b- CRC error.
	c- LEN error
2- Start error flag. (needed to be discussed with Kholoud for what will be sent to the memory).
3- in the next cycle "Cycle 2":
	a- the driver should send "StartRetry pulse"
	b- monitor should receive the coming packet from the controller (if there is upcoming packet)
4- in the next cylce "Cycle 3":
	a- the monitor should not receive any new packets
	b- the monitor should be wating to "ClearError packets" and count up to 16 packets.
5- after receiving the 16 ClearError packets, the monitor should be wating to receive the retried packet.
*/


  task Check_link_retry();
    // checking part:
    bit poisioned_crc_check = crc_class.request_packet_poison_checker_with_crc (seq_item);
    bit LNG_check = check_LNG_and_CMD(seq_item);
    
    if(poisioned_crc_check == 1 || LNG_check == 1 ) begin 
          error_flag = 1;
          seq_item.link_retry_mode =1;
          `uvm_info("HMC_Mem_Monitor","Posisioned packet detected so initialize link retry mode",UMM_HIGH);
    end
    else begin
          error_flag =0;
          seq_item.link_retry_mode =0;
    end
    test = 1 ;

  endtask:Check_link_retry 

// checking part:

 //crc_class.request_packet_poison_checker_with_crc (seq_item);

  //check LNG with the cmd.
  function bit check_LNG_and_CMD(HMC_Req_Sequence_item called_Req_seq_item);
    called_Req_seq_item.check_CMD_and_extract_request_packet_header_and_tail();
    case (called_Req_seq_item.CMD) 
        // Write operations.
        6'b001000: if(called_Req_seq_item.LNG != 2) return 0; else return 1; //WR16  = 6?b001000,   //16-byte WRITE request
        6'b001001: if(called_Req_seq_item.LNG != 3) return 0; else return 1; //WR32  = 6?b001001,
        6'b001010: if(called_Req_seq_item.LNG != 4) return 0; else return 1; //WR48  = 6?b001010,
        6'b001011: if(called_Req_seq_item.LNG != 5) return 0; else return 1; //WR64  = 6?b001011,
        6'b001100: if(called_Req_seq_item.LNG != 6) return 0; else return 1; //WR80  = 6?b001100,
        6'b001101: if(called_Req_seq_item.LNG != 7) return 0; else return 1; //WR96  = 6?b001101,
        6'b001110: if(called_Req_seq_item.LNG != 8) return 0; else return 1; //WR112 = 6?b001110,
        6'b001111: if(called_Req_seq_item.LNG != 9) return 0; else return 1; //WR128 = 6?b001111,
        6'b010000: if(called_Req_seq_item.LNG != 2) return 0; else return 1; //MD_WR = 6?b010000  //MODE WRITE request

        // Posted Write Request
        6'b011000: if(called_Req_seq_item.LNG != 2) return 0; else return 1; //P_WR16  = 6?b011000,   //16-byte POSTED WRITErequest
        6'b011001: if(called_Req_seq_item.LNG != 3) return 0; else return 1; //P_WR32  = 6?b011001,
        6'b011010: if(called_Req_seq_item.LNG != 4) return 0; else return 1; //P_WR48  = 6?b011010,
        6'b011011: if(called_Req_seq_item.LNG != 5) return 0; else return 1; //P_WR64  = 6?b011011,
        6'b011100: if(called_Req_seq_item.LNG != 6) return 0; else return 1; //P_WR80  = 6?b011100,
        6'b011101: if(called_Req_seq_item.LNG != 7) return 0; else return 1; //P_WR96  = 6?b011101,
        6'b011110: if(called_Req_seq_item.LNG != 8) return 0; else return 1; //P_WR112 = 6?b011110,
        6'b011111: if(called_Req_seq_item.LNG != 9) return 0; else return 1; //P_WR128 = 6?b011111,

        //READ Requests
        6'b110000: if(called_Req_seq_item.LNG != 1) return 0; else return 1;  //RD16  = 6?b110000,   //16-byte READ request
        6'b110001: if(called_Req_seq_item.LNG != 1) return 0; else return 1;  //RD32  = 6?b110001,
        6'b110010: if(called_Req_seq_item.LNG != 1) return 0; else return 1;  //RD48  = 6?b110010,
        6'b110011: if(called_Req_seq_item.LNG != 1) return 0; else return 1;  //RD64  = 6?b110011,
        6'b110100: if(called_Req_seq_item.LNG != 1) return 0; else return 1;  //RD80  = 6?b110100,
        6'b110101: if(called_Req_seq_item.LNG != 1) return 0; else return 1;  //RD96  = 6?b110101,
        6'b110110: if(called_Req_seq_item.LNG != 1) return 0; else return 1;  //RD112 = 6?b110110,
        6'b110111: if(called_Req_seq_item.LNG != 1) return 0; else return 1;  //RD128 = 6?b110111,
        6'b101000: if(called_Req_seq_item.LNG != 1) return 0; else return 1;  //MD_RD = 6?b101000,  //MODE READ request

        //ARITHMETIC ATOMICS
        6'b010010: if(called_Req_seq_item.LNG != 2) return 0; else return 1; //Dual_ADD8   = 6?b010010,   //Dual 8-byte signed add immediate
        6'b010011: if(called_Req_seq_item.LNG != 2) return 0; else return 1; //ADD16       = 6?b010011,   //Single 16-byte signed add immediate
        6'b100010: if(called_Req_seq_item.LNG != 2) return 0; else return 1; //P_2ADD8     = 6?b100010,   //Posted dual 8-byte signed add immediate
        6'b100011: if(called_Req_seq_item.LNG != 2) return 0; else return 1; //P_ADD16     = 6?b100011,   //Posted single 16-byte signed add immediate
        6'b010000: if(called_Req_seq_item.LNG != 1) return 0; else return 1; //INC8        = 6?b010000,   //8-byte increment
        6'b010100: if(called_Req_seq_item.LNG != 1) return 0; else return 1; //P_INC8      = 6?b010100,   //Posted 8-byte increment

        //BITWISE ATOMICS
        6'b010001: if(called_Req_seq_item.LNG != 2)  return 0; else return 1; //8-byte bit write 
        6'b100001: if(called_Req_seq_item.LNG != 2)  return 0; else return 1; //Posted 8-byte bit write 

        //Flow packets... (TRET , TS1 , NULL , PRET , IRTRY)
        6'b000000: return 1; // null packets.
        6'b000010: return 1; // TRET
        6'b000001: return 1; // PRET
        6'b000011: return 1; // IRTRY
        // TS1

         default: return 0;
    endcase
       
  endfunction:check_LNG_and_CMD



  //**********************************************************************************************************
  //                                 ********** link_retry_operation task **********

  task link_retry_operation();
    // we should stay here for some cycles until the hall operation done.
    while (link_retry_loop == 1) begin
        receive_data_from_dut();                      // first phase
        store_received_data_in_queue();               // second phase
        dequeuing_full_packet_from_the_queue();       // final phase
        //save the collected packet in the sequence item and get it's LNG.
        seq_item.packet = new(LNG);
        seq_item.packet = packet;
        seq_item.check_CMD_and_extract_request_packet_header_and_tail();
        ClearError_packets_check();
        reset_counters();
        @(posedge mem_vifc.hmc_clk);

    end
    Check_link_retry();
    if(error_flag == 0) begin    
        // send the retried packet to the memory
        seq_item.LXRXPS =mem_vifc.LXRXPS;
        seq_item.link_retry_mode =0;
        Monitor_to_mem_port.write(seq_item);
        mem_to_scoreboard_port.write(seq_item); 
    end
    else if(error_flag == 1) begin // link retry failed...
      // we will drop this packet.
      error_flag =0;
      seq_item.link_retry_mode =0;
    end

  endtask:link_retry_operation
/*
IRTRY packet:
Seq_num =0
CMD = 6'b000011
RTC field =0
If (FRP[1] == 1) ClearError packets {Coming from the controller into the Reactive agent)
If (FRP[0] == 1) StartRetry packet {Sent by the driver of the reactive agent to the controller}


*/
  //check receiving "ClearError packets" 
  task ClearError_packets_check();

      if(seq_item.CMD == 6'b000011 && seq_item.FRP[1] == 1)begin
        error_cycle_counter = error_cycle_counter + 4; 
        // or +1 (i don't know if it will send one or more packets at the same cycle)
      end

      if( seq_item.CMD != 6'b000011  && error_cycle_counter >= 16) begin
         link_retry_loop = 0;
         error_flag = 0;
         error_cycle_counter = 0;
      end
  endtask:ClearError_packets_check

  //**********************************************************************************************************

       /*
                Steps of initalization operation....
        1- check on p_rst_n == 1.
        2- receive NULL1 packets.
        3- receive TS1 packets.
        4- within 1us TS1 packets should be sent from the driver.
        5- will receive NULL2 packets until the receiver start to send TRET packets.
        6- start to receive TRET packets.
        7- finally we are in the active mode, so link_on = 1      
       */

  task initialization_mode_operation();
        while(mem_vifc.P_RST_N ==1 && link_on == 0) begin
          case({null1_received , TS1_received , null2_received})
               // NULL1 needed to be recognized. ->  wait until driver sends PRBS packets
               3'b000: null1_flit_received();

               // TS1 needed to be recognized. -> wait until the driver sends TS1
               3'b100: TS1_flit_received();

               // NULL2 needed to be recognized. -> all zeros flits..
               3'b110: null2_flit_received();

               // TRET flits needed to be recognized -> check it with the special tret_hdr
               3'b111: TRET_flit_received();

               default: $display("unvalid packet is received at hmc memory monitor during initialization");
          endcase
        end
  endtask: initialization_mode_operation

  // ********** null1 receving check task **********
    task null1_flit_received();
      if(mem_vifc.phy_data_tx_link2phy[5:0] == 6'b000000) begin // if it found null flits...
       while(mem_vifc.phy_data_tx_link2phy[5:0] == 6'b000000 ) begin // check the command == 0
          null1_received  = 0 ;
          // send this packet to the memory
          fill_seq_item_packet();
          Monitor_to_mem_port.write(seq_item);
          mem_to_scoreboard_port.write(seq_item);
          @(posedge mem_vifc.hmc_clk); // wait to the next clk.
          end
       null1_received = 1;
      end
      else begin
         null1_received  = 0 ;
         $display("NO NULL packets received from the controller at stage 1 in inialization mode at this cycle");
         @(posedge mem_vifc.hmc_clk);  // wait to the next clk.
       end
    endtask: null1_flit_received

  // ********** TS1 receving check task **********
    task TS1_flit_received();
       // still wotking on it....
       // needed to be checked
       if(mem_vifc.phy_data_tx_link2phy [127:0] == 128'hffffffff0000000080fe017fxxxxxxxx) begin
        while(mem_vifc.phy_data_tx_link2phy [127:0] == 128'hffffffff0000000080fe017fxxxxxxxx) begin 
            TS1_reveived =0;
            // send this packet to the memory
            fill_seq_item_packet();
            Monitor_to_mem_port.write(seq_item);
            mem_to_scoreboard_port.write(seq_item);
            @(posedge mem_vifc.hmc_clk); // wait to the next clk.
            end
       TS1_reveived = 1; 
       end
       else begin 
         TS1_reveived =0;
         $display("NO TS1 packets received from the controller at stage 2 in inialization mode at this cycle");
         @(posedge mem_vifc.hmc_clk);  // wait to the next clk.
       end
    endtask: TS1_flit_received

  // ********** null2 receving check task **********
    task null2_flit_received();
      if(mem_vifc.phy_data_tx_link2phy[5:0] == 6'b000000 ) begin
       while(mem_vifc.phy_data_tx_link2phy[5:0] == 6'b000000 ) begin // check the command == 0
          null2_received  = 0 ;
          // send this packet to the memory
          fill_seq_item_packet();
          Monitor_to_mem_port.write(seq_item);
          mem_to_scoreboard_port.write(seq_item);
          @(posedge mem_vifc.hmc_clk); // wait to the next clk.
          end
       null2_received = 1;
      end
      else begin 
         null2_received  = 0 ;
         $display("NO null2 packets received from the controller at stage 3 in inialization mode at this cycle");
         @(posedge mem_vifc.hmc_clk);  // wait to the next clk.
      end
    endtask: null2_flit_received

  // ********** TRET receving check task **********
    task TRET_flit_received(); // packet with length of 15 bits...
       logic [63:0] tret_hdr = {6'h0,   34'h0, 9'h0, 4'h1, 4'h1, 1'h0, 6'b000010};
       //      CUB 3bits & RES 3bits, Address,  TAG,  DLN,  LNG,  RES,     CMD
        if(mem_vifc.phy_data_tx_link2phy [63:0] == tret_hdr) begin // if TRET packet detected ..
            //collect_TRET_packet
            bit   [127:0] TRET_flits_queue [$];
            bit   [127:0] temp_flits[FPW]
            for(int j=0; j< 16/FPW ; j++) begin 
              split_data_in( mem_vifc.phy_data_tx_link2phy  , temp_flits);
              for(int i=0;i<FPW; i++) begin
                TRET_flits_queue.push_back(temp_flits[i]);
              end
              if(j<3) @(posedge mem_vifc.hmc_clk);  // wait to the next clk.
            end
            seq_item.packet = new(15);
            for (int i=0;i<15;i++) TRET_flits_queue.pop_front(seq_item.packet[i]); // dequeue the full packet into seq_item.packet ...

            TRET_flits_queue.pop_front(temp_flits[FPW-1]); // getting the last not needed item stored in the queue...
            Monitor_to_mem_port.write(seq_item);  // send TRET packet...
            mem_to_scoreboard_port.write(seq_item);
            // final touch...
            TRET_reveived = 1;
            link_on=1;
        end
        else begin 
            TRET_reveived =0; 
            $display("NO TRET packets received from the controller at stage 4 in inialization mode at this cycle");
            @(posedge mem_vifc.hmc_clk);  // wait to the next clk.
        end
    endtask: TRET_flit_received

  // ********** fill seq_item.packet task **********
    task fill_seq_item_packet();
        seq_item.packet = new(FPW);
        for(int i=0;i<4;i++)
        seq_item.packet[i] =mem_vifc.phy_data_tx_link2phy [128*(i+1)-1:i*128];
    endtask: fill_seq_item_packet

    // ********** reset_operation task **********
   task reset_operation ();
       // reset initalization flags....
       null1_received = 0;
       TS1_reveived = 0;
       null2_received = 0;
       TRET_reveived = 0;
       link_on = 0;
       // reset counters ....
       c=0;
       test =0;
       stored_flits_n=0;
       packet_captured = 0;
       new_flit =1;
       error_flag = 0;
   endtask : reset_operation

  //**********************************************************************************************************

  // ********************** sleep mode operation task **************************************** 
  task sleep_mode_operation();
        // still working on it....
        $display("sleep mode ON");
        seq_item.LXRXPS =mem_vifc.LXRXPS;
        while (mem_vifc.LXRXPS == 0) begin
               seq_item.packet = new(1);
               seq_item.packet = 0; // required sleep mode packets.
               Monitor_to_mem_port.write(seq_item);
               mem_to_scoreboard_port.write(seq_item);
            end
        seq_item.LXRXPS =mem_vifc.LXRXPS;
  endtask:sleep_mode_operation

endclass : HMC_Mem_Monitor

