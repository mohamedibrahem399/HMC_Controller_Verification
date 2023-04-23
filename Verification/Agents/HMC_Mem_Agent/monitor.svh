/* monitor in 
       initialization -> done
       normal mode -> done.
       sleep mode -> needed to know the sequences and packets should be sent.
       IDLE mode  -> done.
       link retry mode -> still working on it

*/
class RA_monitor #(parameter FPW       =4,
                   parameter
                   parameter DWIDTH    = FPW*128,
                   parameter NUM_LANES = 8);
 extends uvm_monitor;

  `uvm_component_utils(RA_monitor)
   RA_seq_item seq_item;
  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual Transceiver_interface trans_vifc;
  virtual HMC_interface HMC_vifc;
  virtual System_interface sys_vifc; 
  //**********************************************************************************************************

  // analysis port, to send the transaction to scoreboard
  //uvm_analysis_port #(RA_seq_item) item_collected_port;
  // uvm_analysis_port#(HMC_Rsp_Sequence_item) HMC_Mem_Analysis_Monitor_Storage_Port; "Review"

  uvm_blocking_put_port#(RA_seq_item) mem_put_port; // put port from monitor to memory
  //**********************************************************************************************************

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  //**********************************************************************************************************

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq_item = RA_seq_item::type_id::create("seq_item", this);
    if(!uvm_config_db#(virtual Transceiver_interface)::get(this, "", "trans_vifc", trans_vifc))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".trans_vifc"});
    if(!uvm_config_db#(virtual HMC_interface)::get(this, "", "HMC_vifc", HMC_vifc))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".HMC_vifc"});
    if(!uvm_config_db#(virtual System_interface)::get(this, "", "sys_vifc", sys_vifc))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".sys_vifc"});
    // this port is made for the outer subscribers.
    mem_put_port = new("mem_put_port", this);
    //HMC_Mem_Analysis_Monitor_Storage_Port = new("HMC_Mem_Analysis_Monitor_Storage_Port" , this); "Review"
  endfunction: build_phase
  //**********************************************************************************************************

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

    // initalization commmands needed to be written here...
    if(HMC_vifc.P_RST_N ==1) begin 
        if (link_on == 0) begin
             initialization_mode_operation();
        end
        // After initialization mode...
        else if( link_on == 1 ) begin
            if(HMC_vifc.LXRXPS == 1 ) begin // normal mode
                 normal_mode_operation();
                 seq_item.LXRXPS =HMC_vifc.LXRXPS;
                 mem_put_port.put(seq_item);
	         //HMC_Mem_Analysis_Monitor_Storage_Port.write(seq_item); "Review"
                 end
            // sleep mode 
            // still working on it....
            else if( HMC_vifc.LXRXPS == 0 )begin // still needed to have more details
                   sleep_mode_operation();
                 end
        end
    end
   else if (HMC_vifc.P_RST_N == 0) begin
       reset_operation();
      end

    phase.drop_objection(this);
  endtask : run_phase

  //**********************************************************************************************************

  // data in temp into coming flits
  function automatic split_data_in( bit [DWIDTH-1:0] data_in_temp, ref bit [127:0] coming_flits[FPW] );
     for( int i =0; i<FPW ; i++) begin
         coming_flits[i] = data_in_temp [ 128*(i+1) -1  : i*128 ];
  endfunction: split_data_in
 
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
       
       //*****************************************************
       // this part responsable for receiving data from the TX. 
       while ( packet_captured == 0 ) begin
	@(posedge sys_vifc.hmc_clk);
	 if(trans_vifc.phy_data_tx_link2phy == 0) begin // checking at this posedge whether there is data sent or just all zeros.
              $display("there is no data coming in this cycle %t ",$time); // IDLE mode, wating for any packet to be received.
              packet_captured = 0;
             end
         else if(trans_vifc.phy_data_tx_link2phy != 0) begin
              // assume we caught a packet from the 
               data_in_temp = 0; // we will remove this 0 and put the descrambled input
               split_data_in( data_in_temp , coming_flits );

               if(new_flit==1)new_flit =1; else new_flit =0; // don't change it.
               packet_captured =1;
             end    
        end
        //*****************************************************
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
              if (LNG <= FPW) begin // checking if the received packet length is less than 4
                                  // so that we will capture it in this cycle only
                   for (int x =0 ; x<LNG ; x++) begin
                        flits_queue.push_back(coming_flits[x]); 
                        stored_flits_n = stored_flits_n + 1; 
                      end
                   c=0;
                end
              else if (LNG > FPW) begin // checking if the received packet length ls more than 4 
                                      // so that it will take more than one cycle to be stored in the queue
                   for (int x =0 ; x<FPW ; x++) begin 
                        flits_queue.push_back(coming_flits[x]);
                        stored_flits_n = stored_flits_n + 1;
                      end
                   c=c-FPW;
                   packet_captured =0;
                 end
           end
         else if(new_flit == 0 && c>0) begin // new_flit = 0 means-> the received packet length at first was more than 4 
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
        //*****************************************************
        // final phase -> dequeuing the hall packet from the queue.
         else if( new_flit == 0 && c==0 && LNG == stored_flits_n) begin // ready to dequeue...
              for(int i=0; i< LNG; i++) flits_queue.pop_front(packet[i]);
              test = 1 ;             
           end
        else begin // here we can implement link retry.
             $display("Fatal error happend, we will drop this packet"); test = 1 ;
             seq_item.FERR_N = 1;
             seq_item.packet = new(1);
             seq_item.packet = 0; // start retry packet... search on it.
             error_flag = 1;
             break;  
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
             end 
      end 
    if (error_flag != 1) begin
        //save the collected packet in the sequence item and get it's LNG.
         seq_item.packet = new(LNG);
         seq_item.packet = packet;
         seq_item.extract_request_packet_header_and_tail();
         seq_item.set_LNG_from_cmd ( seq_item.cmd , seq_item.LNG );
    end
    // reset counters 
    c=0;
    test=0;
    new_flit =1;
    stored_flits_n=0;
    packet_captured =0;
    error_flag = 0;
  endtask : normal_mode_operation
  //**********************************************************************************************************

  task initialization_mode_operation();
       /*
                Steps of operation....
        1- check on p_rst_n == 1.
        2- receive NULL1 packets.
        3- receive TS1 packets.
        4- within 1us TS1 packets should be sent from the driver.
        5- will receive NULL2 packets until the receiver start to send TRET packets.
        6- start to receive TRET packets.
        7- finally we are in the active mode, so link_on = 1      
       */
        while(HMC_vifc.P_RST_N ==1 && link_on == 0) begin
           // NULL1 needed to be recognized. -> all zeros flits..
           if( null1_received == 0)// null 1 received , wait until driver sends PRBS packets
                  null1_flit_received();
           // TS1 needed to be recognized. -> ...........
           else if(null1_received==1 && TS1_received == 0 ) begin
              // here we should wait until the driver sends TS1
              TS1_flit_received();
             end
           // NULL2 needed to be recognized. -> all zeros flits..
           else if (null1_received==1 && TS1_received ==1 && null2_received ==0)
                    null2_flit_received();
           // TRET flits needed to be recognized -> check it with the special tret_hdr
           else if (null1_received==1 && TS1_received ==1 && null2_received==1) begin
                TRET_flit_received();
                link_on=1;
           end
           else $display("unvalid packet is received at hmc memory monitor during initialization");
        end
  endtask: initialization_mode_operation

  // ********************** sleep mode operation task **************************************** 
  task sleep_mode_operation();
        // still working on it....
        $display("sleep mode ON");
        seq_item.LXRXPS =HMC_vifc.LXRXPS;
        while (HMC_vifc.LXRXPS == 0) begin
               seq_item.packet = new(1);
               seq_item.packet = 0; // required sleep mode packets.
               mem_put_port.put(seq_item);
            end
        seq_item.LXRXPS =HMC_vifc.LXRXPS;
  endtask:sleep_mode_operation

  // ********************** null1 receving check task **************************************** 
    task null1_flit_received();
       while(trans_vifc.phy_data_tx_link2phy[5:0] == 5'b00000 )null1_received  = 0 ;// check the command == 0
       null1_received = 1;
    endtask: null_flit_received
  // ********************** TS1 receving check task **************************************** 
    task TS1_flit_received();
       // still wotking on it....
       // needed to be checked
       while(trans_vifc.phy_data_tx_link2phy [127:0] == 128'hffffffff0000000080fe017fxxxxxxxx)TS1_reveived =0;
       TS1_reveived = 1; 
    endtask: TS1_flit_received
  // ********************** null2 receving check task **************************************** 
    task null2_flit_received();
       while(trans_vifc.phy_data_tx_link2phy[5:0] == 5'b00000 )null2_received  = 0 ;// check the command == 0
       null2_received = 1;
    endtask: null_flit_received
  // ********************** TRET receving check task **************************************** 
    task TRET_flit_received();
       logic [63:0] tret_hdr = {6'h0,34'h0,9'h0,4'h1,4'h1,1'h0,6'b000010};
       while(trans_vifc.phy_data_tx_link2phy [63:0] == tret_hdr)TRET_reveived =0;
       TRET_reveived = 1; 
    endtask: TRET_flit_received
    // ********************** reset_operation task **************************************** 
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

endclass : mem_monitor



/*
DUT Signals for the Transceiver interface:

    //----------------------------------
    //----Connect Transceiver
    //----------------------------------
    output wire  [DWIDTH-1:0]           phy_data_tx_link2phy,//Connect!
    input  wire  [DWIDTH-1:0]           phy_data_rx_phy2link,//Connect!
    output wire  [NUM_LANES-1:0]        phy_bit_slip,       //Must be connected if DETECT_LANE_POLARITY==1 AND CTRL_LANE_POLARITY=0
    output wire  [NUM_LANES-1:0]        phy_lane_polarity,  //All 0 if CTRL_LANE_POLARITY=1
    input  wire                         phy_tx_ready,       //Optional information to RF
    input  wire                         phy_rx_ready,       //Release RX descrambler reset when PHY ready
    output wire                         phy_init_cont_set,  //Can be used to release transceiver reset if used


DUT Signals for the HMC interface:
    //----------------------------------
    //----Connect HMC
    //----------------------------------
    output wire                         P_RST_N,
    output wire                         LXRXPS,
    input  wire                         LXTXPS,
    input  wire                         FERR_N,
*/
