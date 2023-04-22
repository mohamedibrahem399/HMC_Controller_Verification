/* monitor in 
       initialization -> still working on it
       normal mode -> done.
       sleep mode -> needed to know the sequences and packets should be sent.
       IDLE mode  -> done.
       link retry mode -> still working on it

*/
class RA_monitor extends uvm_monitor;


  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual Transceiver_interface trans_vifc;
  virtual HMC_interface HMC_vifc;
  virtual System_interface sys_vifc; 

  //**********************************************************************************************************

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  //uvm_analysis_port #(RA_seq_item) item_collected_port;

  uvm_blocking_put_port#(RA_seq_item) mem_put_port; // put port from monitor to memory

  //**********************************************************************************************************

  `uvm_component_utils(RA_monitor)
   RA_seq_item seq_item;

  //**********************************************************************************************************

  //---------------------------------------
  // new - constructor
  //---------------------------------------
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

  endfunction: build_phase
  

  //**********************************************************************************************************

  logic [511:0] data_in_temp = 0;
  bit packet_captured = 0;
  bit new_flit =1;
  bit error_flag = 0;


  logic [127:0] packet[];
  logic [3:0] LNG;
  logic [5:0] CMD;
  logic [127:0] flit;
  logic [127:0] coming_flits[4];
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

  //**********************************************************************************************************

  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // initalization commmands needed to be written here...

    if (link_on == 0) begin
	 // still working on it
         initialization_mode_operation();
    end

    // After initialization mode...
    else if( link_on == 1 ) begin
        if(HMC_vifc.LXRXPS == 1 ) begin // normal mode

             normal_mode_operation();

             seq_item.LXRXPS =HMC_vifc.LXRXPS;
             mem_put_port.put(seq_item);
             end

        else if( HMC_vifc.LXRXPS == 0 )begin // sleep mode // still needed to have more details
               sleep_mode_operation();
             end
    end
         

    phase.drop_objection(this);


  endtask : run_phase

  //**********************************************************************************************************

  // data in temp  into coming flits
  function automatic split_data_in( bit [511:0] data_in_temp, ref bit [127:0] coming_flits[4] );
     for( int i =0; i<4 ; i++) begin
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
              if (LNG <= 4) begin // checking if the received packet length is less than 4
                                  // so that we will capture it in this cycle only
                   for (int x =0 ; x<LNG ; x++) begin
                        flits_queue.push_back(coming_flits[x]); 
                        stored_flits_n = stored_flits_n + 1; 
                      end
                   c=0;
                end
              else if (LNG > 4) begin // checking if the received packet length ls more than 4 
                                      // so that it will take more than one cycle to be stored in the queue
                   for (int x =0 ; x<4 ; x++) begin 
                        flits_queue.push_back(coming_flits[x]);
                        stored_flits_n = stored_flits_n + 1;
                      end
                   c=c-4;
                   packet_captured =0;
                 end
           end

         else if(new_flit == 0 && c>0) begin // new_flit = 0 means-> the received packet length at first was more than 4 
                                             // so it needed to be stored in more than one cycle.
                                             // in here, we continue receving the rest of the packet in next cycles.
              if (c <= 4) begin // same as above.
                   for (int x =0 ; x<c ; x++) begin flits_queue.push_back(coming_flits[x]); stored_flits_n = stored_flits_n + 1; end
                   c=0;
                   end
              else if (c > 4) begin // same as above.
                   for (int x =0 ; x<4 ; x++) begin flits_queue.push_back(coming_flits[x]); stored_flits_n = stored_flits_n + 1; end
                   c=c-4;
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


        while (HMC_vifc.P_RST_N ==1) begin
           // NULL1 needed to be recognized. -> all zeros flits..
           if( null1_received==0 && trans_vifc == 0);// null 1 received , wait until driver sends PRBS packets
           // TS1 needed to be recognized. -> ...........
           else if( TS1_received ==0 && trans_vifc == /* the TS1 packet form */) begin
              null1_received=1;
              // here we should wait until the driver sends TS1
             end
           // NULL2 needed to be recognized. -> all zeros flits..
           else if ( null1_received==1 && null2_received ==0 && trans_vifc == 0) TS1_received =1; // null2 received
           else if ( null1_received==1 && null2_received ==0 && trans_vifc ==  /* the TRET packet form */ )
               begin
                null2_received=1;
                link_on=1;
             end
             else $display("unvalid packet is received during initialization");
        end
  endtask: initialization_mode_operation



  task sleep_mode_operation();

        $display("sleep mode ON");
        seq_item.LXRXPS =HMC_vifc.LXRXPS;
        while (HMC_vifc.LXRXPS == 0) begin
               seq_item.packet = new(1);
               seq_item.packet = 0; // required sleep mode packets.
               mem_put_port.put(seq_item);
            end
        seq_item.LXRXPS =HMC_vifc.LXRXPS;
  endtask:sleep_mode_operation

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


