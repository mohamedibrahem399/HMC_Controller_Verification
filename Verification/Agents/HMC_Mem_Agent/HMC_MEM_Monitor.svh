/* monitor in 
       initialization -> done
       normal mode -> done.
       sleep mode -> needed to know the sequences and packets should be sent.
       IDLE mode  -> done.
       link retry mode -> still working on it
*/
class HMC_MEM_Monitor #(parameter FPW       = 4,
                        parameter DWIDTH    = FPW*128,
                        parameter NUM_LANES = 8) extends uvm_monitor;

  `uvm_component_utils(HMC_MEM_Monitor)

  // Virtual Interface
  virtual HMC_Mem_IF mem_vifc;
  //sequence item
  HMC_Req_Sequence_item seq_item;
  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //***********************  connections and ports  ***********************

  // analysis port, to send the transaction to scoreboard (for scoreboard and coverage)
  //uvm_analysis_port #(RA_seq_item) item_collected_port;

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
  endfunction: build_phase
  //**********************************************************************************************************

  // control signals
  logic [DWIDTH-1:0] data_in_temp = 0;
  bit packet_captured = 0;
  bit new_flit =1;
  bit error_flag = 0;

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
    phase.raise_objection(this);
    if(mem_vifc.P_RST_N ==1) begin 
      if (link_on == 0) initialization_mode_operation();  // Initialization mode start....
      else if( link_on == 1 ) begin // After initialization mode... 
          if(mem_vifc.LXRXPS == 1 ) begin // normal mode
                normal_mode_operation();
                seq_item.LXRXPS =mem_vifc.LXRXPS;
                Monitor_to_mem_port.write(seq_item);
              end
          else if( mem_vifc.LXRXPS == 0 )begin // sleep mode   // still working on it....
                sleep_mode_operation();
             end
        end
    end
    else if (mem_vifc.P_RST_N == 0) reset_operation(); // reset mode.... (REVIEW)
    phase.drop_objection(this);
  endtask : run_phase


  //**********************************************************************************************************
  /*
  The upcoming function does the monitor operation in normal mode.
  this operation is divided into 3 phases
    1st phase -> sniffing for upcoming data from the controller tx
    2nd phase -> storing the hall packet into a queue.
    3rd phase -> dequeue the stored packet and send it to the memory
  */

  // ********************** normal mode operation task **************************************** 
  task normal_mode_operation( );
    // collecting the full packet.
    while( test != 1 ) begin 
       receive_data_from_dut();                      // first phase
       store_received_data_in_queue();               // second phase
       dequeuing_full_packet_from_the_queue();       // final phase
       //link_retry_operation();                     // if anything wrong happened (still working on it)
      end
    
    if (error_flag != 1) begin //send packets to memory (if there is no errors occurred)
        //save the collected packet in the sequence item and get it's LNG.
         seq_item.packet = new(LNG);
         seq_item.packet = packet;
         seq_item.extract_request_packet_header_and_tail();
         seq_item.set_LNG_from_cmd ( seq_item.cmd , seq_item.LNG );
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
               data_in_temp = 0; // we will remove this 0 and put the descrambled input
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
              test = 1 ;             
           end
  endtask:dequeuing_full_packet_from_the_queue


  // ********** link_retry_operation task **********

/*
task link_retry_operation();

else begin // here we can implement link retry.
             $display("Fatal error happend, we will drop this packet"); test = 1 ;
             seq_item.FERR_N = 1;
             seq_item.packet = new(1);
             seq_item.packet = 0; // start retry packet... search on it.
             error_flag = 1;
             test = 1 ;
             break;  
             end 
 
endtask:link_retry_operation
*/

             /*
             The HMC then issues a programmable series of start_retry packets to
             the RX link to force a link retry. Start_retry packets have the ?StartRetryFlag? set (FRP[0]=1).
             When the irtry_received_threshold at the Receive (RX)-Link is reached, the Transmit (TX)
             link starts to transmit a series of clear_error packets that have the ?ClearErrorFlag? set
             (FRP[1]=1). Afterwards, the TX link uses the last received RRP as the RAM read address
             and re-transmits any valid FLITs in the retry buffer until the read address equals the write
             address, meaning that all pending packets where re-transmitted. Upon completion the RAM
             read address returns to the last received RRP. Re-transmitted packets may therefore be
             re-transmitted again if another error occurs.
             */ 

             /*
             // for link retry mode
             //PRET
             wire    [63:0]              pret_hdr;
             assign                      pret_hdr        = {6'h0,34'h0,9'h0,4'h1,4'h1,1'h0,6'b000001};

             This command is issued by the link master to return retry pointers when there is no
             other link traffic flowing at the time the pointer is to be returned. It is a single-FLIT
             packet with no data payload. PRET packets are not saved in the retry buffer, so their SEQ
             and FRP fields should be set to 0. Tokens should not be returned in these packets, so the
             RTC field should be set to 0.
             */


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
      if(mem_vifc.phy_data_tx_link2phy[5:0] == 5'b00000) begin // if it found null flits...
       while(mem_vifc.phy_data_tx_link2phy[5:0] == 5'b00000 ) begin // check the command == 0
          null1_received  = 0 ;
          // send this packet to the memory
          fill_seq_item_packet();
          Monitor_to_mem_port.write(seq_item);
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
      if(mem_vifc.phy_data_tx_link2phy[5:0] == 5'b00000) begin
       while(mem_vifc.phy_data_tx_link2phy[5:0] == 5'b00000 ) begin // check the command == 0
          null2_received  = 0 ;
          // send this packet to the memory
          fill_seq_item_packet();
          Monitor_to_mem_port.write(seq_item);
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
            end
        seq_item.LXRXPS =mem_vifc.LXRXPS;
  endtask:sleep_mode_operation

endclass : HMC_MEM_Monitor


