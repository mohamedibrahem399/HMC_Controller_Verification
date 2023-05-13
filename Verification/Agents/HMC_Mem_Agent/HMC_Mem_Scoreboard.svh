
/*
Checks in this scoreboard:

    A- Request packet checks:
            1) check if the command exists or not. ✔✔
            2) check if it is posted write request command or not.. ✔✔
            3) check LNG with the cmd ✔✔
            4) check the CRC of the request packets. ***


    B- Common Checks:
            1) check if the request and response packets has the same (TAG, SEQ_NUMBER ) ✔✔
            2) Check if the response packet CMD is the right response CMD for the request packet CMD. ✔✔
            3) check if the request and response packets has the same (FRP , RRP) ✔✔

    C- Responce packet checks:
            1) check if the command exists or not. ✔✔
            2) check the CRC of the Responce packets.***
            3) check ERRSTAT, DINV **** -> needed to know if they are needed to be checked or not...
*/

// --------------------------------------------
// Using uvm micros to be able to implement 2 analysis implementation write functions at the scoreboard.
// --------------------------------------------
`uvm_analysis_imp_decl(_memory)
`uvm_analysis_imp_decl(_monitor)


class HMC_Mem_Scoreboard extends uvm_scoreboard;
    // Adding scoreboard to factory.
    `uvm_component_utils(HMC_Mem_Scoreboard);

    // class constructor.
    function new(string name = "HMC_Mem_Scoreboard" ,uvm_component parent)
        super.new(name,parent);
    endfunction : new

    // defining memory and monitor analysis implementations.
    uvm_analysis_imp_memory#( HMC_Rsp_Sequence_item , HMC_Mem_Scoreboard) mem_to_scoreboard_analysis_imp;
    uvm_analysis_imp_monitor#( HMC_Req_Sequence_item , HMC_Mem_Scoreboard) monitor_to_scoreboard_analysis_imp;
    
    //defining request and responce seq_item
    protected HMC_Req_Sequence_item Req_seq_item;
    protected HMC_Rsp_Sequence_item Rsp_seq_item;

    // --------------------------------------------
    // Scoreboard build phase
    // --------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mem_to_scoreboard_analysis_imp = new("mem_to_scoreboard_analysis_imp",this);
        monitor_to_scoreboard_analysis_imp = new("monitor_to_scoreboard_analysis_imp",this);
    endfunction : build_phase

    // --------------------------------------------
    // write function of monitor analysis port.
    // --------------------------------------------
    bit monitor_transaction_received = 0;
    bit wrong_request_CMD = 0;

    virtual function void write_monitor(HMC_Req_Sequence_item collected_Req_seq_item);
        `uvm_info("write_monitor",$sformat("Data received = 0x%0p", collected_Req_seq_item.packet),UVM_MEDIUM)
        wrong_request_CMD = 0;
        Req_seq_item = collected_Req_seq_item;

        if ( !Req_seq_item.check_CMD_and_extract_request_packet_header_and_tail() ) begin // Check request packet CMD.
             `uvm_fatal("Scoreboard", $sformat(  "INVALID Request Packet CMD with TAG = 0x%0d", Req_seq_item.TAG), UVM_HIGH);
             wrong_request_CMD = 1;
             // if there is invalid request CMD we should make something....
        end

        monitor_transaction_received = 1;
        // other things to do...
    endfunction : write

    // --------------------------------------------
    // write function of memory analysis port.
    // --------------------------------------------
    bit memory_transaction_received =0;
    bit wrong_response_CMD = 0;

    virtual function void write_memory(HMC_Rsp_Sequence_item collected_Rsp_seq_item);
        `uvm_info("write_memory",$sformat("Data received = 0x%0p", collected_Rsp_seq_item.packet),UVM_MEDIUM)
        wrong_response_CMD = 0;

        Rsp_seq_item = collected_Rsp_seq_item;
        if(! Rsp_seq_item.check_CMD_and_extract_response_packet_header_and_tail()) begin// Check response packet CMD
            `uvm_fatal("Scoreboard", $sformat(  "INVALID Responce Packet CMD with TAG = 0x%0d", Rsp_seq_item.TAG)  , UVM_HIGH);
            wrong_response_CMD = 1;
            // if there is invalid request CMD we should make something....
        end
            
        memory_transaction_received = 1;
        // other things to do...
    endfunction : write

    // --------------------------------------------
    // Scoreboard run phase
    // --------------------------------------------

    virtual task run_phase(uvm_phase phase)

        if(monitor_transaction_received == 1 && wrong_request_CMD == 0) begin // CMD is checked before we enter here.
            // request packet checks only.
            if(!check_LNG_and_CMD(Req_seq_item)) // LNG check with CMD
                `uvm_info("Scoreboard", $sformat(  "INVALID Responce Packet LNG with CMD (%0s) = 0x%0d", Rsp_seq_item.CMD.name() , Rsp_seq_item.CMD)  , UVM_HIGH);

            // CRC check... missing...

            if (!check_posted_write_requests(Req_seq_item)) begin // wait until memory sent the transaction. if not ( POSTED WRITErequests )
                if(memory_transaction_received ==1 && wrong_response_CMD == 0)  begin // response packet checks, then common checks between request and response packets.
                    // A- Response packet checks:
                        // CRC check... missing...

                    // B- Common checks between request and response packets:

                        // 1) Check TAG and Sequence number.
                   if( !common_check_TAG_and_seq_number(Req_seq_item , Rsp_seq_item))
                        `uvm_info("Scoreboard", $sformat( "INVALID match between TAG or seq_numb of Responce and Request Packets")  , UVM_HIGH);

                        // 2) Check if the response packet CMD is the right response CMD for the request packet CMD.
                    if( !check_response_cmd_wrt_request_cmd(Req_seq_item , Rsp_seq_item))
                        `uvm_info("Scoreboard", $sformat( "INVALID responce packet CMD W.R.T request packet CMD")  , UVM_HIGH);
                    
                        // 3) Check FRP and RRP.
                   if( !common_check_FRP_and_RRP(Req_seq_item , Rsp_seq_item))
                        `uvm_info("Scoreboard", $sformat( "INVALID match between FRP or RRP of Responce and Request Packets with TAG = 0x%0d", Req_seq_item.TAG)  , UVM_HIGH);  
                
                end
            end
            memory_transaction_received   = 0;
            monitor_transaction_received  = 0;
            wrong_request_CMD  = 0;
            wrong_response_CMD = 0;
        end
    endtask: run_phase

    //---------------------------------------------------------------------------------------------------------------
    //  Checks functions implementation:
    //---------------------------------------------------------------------------------------------------------------
    
    // --------------------------------------------
    // A- Request packet checks:
    // --------------------------------------------

        // 2- check if it is posted write request command or not.
    function bit check_posted_write_requests(HMC_Req_Sequence_item called_Req_seq_item);
        case(called_Req_seq_item.CMD)
            // Posted Write Request
            6'b011000: return 1;  //P_WR16  = 6'b011000,   //16-byte POSTED WRITErequest
            6'b011001: return 1;  //P_WR32  = 6'b011001,
            6'b011010: return 1;  //P_WR48  = 6'b011010,
            6'b011011: return 1;  //P_WR64  = 6'b011011,
            6'b011100: return 1;  //P_WR80  = 6'b011100,
            6'b011101: return 1;  //P_WR96  = 6'b011101,
            6'b011110: return 1;  //P_WR112 = 6'b011110,
            6'b011111: return 1;  //P_WR128 = 6'b011111,
            default: return 0;
        endcase
    endfunction:check_posted_write_requests


        //3- check LNG with the cmd.
  function bit check_LNG_and_CMD(HMC_Req_Sequence_item called_Req_seq_item);
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

         default: begin `uvm_fatal("Scoreboard", $sformat(  "INVALID Request Packet CMD with TAG = 0x%0d", Req_seq_item.TAG), UVM_HIGH); return 0; end
    endcase
       
  endfunction:check_LNG_and_CMD

    // --------------------------------------------
    // B- Common Checks:
    // --------------------------------------------

    
           // 1) check if the request and response packets has the same (TAG, SEQ_NUMBER ) ✔✔
    function bit common_check_TAG_and_seq_number(HMC_Req_Sequence_item called_Req_seq_item , HMC_Rsp_Sequence_item called_Rsp_seq_item);
        if ( (called_Req_seq_item.TAG ==  HMC_Rsp_Sequence_item TAG)  &&  (called_Req_seq_item.seq_numb ==  called_Rsp_seq_item.seq_numb) )
             return 1;
        else return 0;
    endfunction: common_check_TAG_and_seq_number

           // 2) Check if the response packet CMD is the right response CMD for the request packet CMD. ✔✔
    function bit check_response_cmd_wrt_request_cmd(HMC_Req_Sequence_item called_Req_seq_item , HMC_Rsp_Sequence_item called_Rsp_seq_item);
           bit [5:0] req_packet_CMD = called_Req_seq_item.packet[0] [5:0] ;
           bit [5:0] rsp_packet_CMD = called_Rsp_seq_item.packet[0] [5:0] ;
           case(req_packet_CMD)
                6'b000000: if (rsp_packet_CMD == 6'b000000) return 1; else return 0; // Null
                6'b000010: if (rsp_packet_CMD == 6'b000010) return 1; else return 0; // Token return (TRET)
                6'b000001: if (rsp_packet_CMD == 6'b000001) return 1; else return 0; // Retry pointer return (PRET)
                6'b000011: if (rsp_packet_CMD == 6'b000011) return 1; else return 0; // Init retry
                6'b001000, 6'b001001,6'b001010,6'b001011,6'b001100,6'b001101,6'b001110,6'b001111: if (rsp_packet_CMD == 6'b111001) return 1; else return 0; // WRITE requests
                6'b110000,6'b110001,6'b110010,6'b110011,6'b110100,6'b110101,6'b110110,6'b110111,6'b101000: if (rsp_packet_CMD == 6'b111000) return 1; else return 0; //READ Requests
                6'b011000,6'b011001,6'b011010,6'b011011,6'b011100,6'b011101,6'b011110,6'b011111: return 1; // Posted Write Request (there is no responce here)
                6'b100010,6'b100011: return 1; //POSTED ATOMIC Requests (there is no responce here)
                //6'b010010,6'b010011: if (rsp_packet_CMD == 6'bxxxxxx) return 1; else return 0;  // ATOMIC Requests
                default: return 0;
           endcase 
    endfunction:check_response_cmd_wrt_request_cmd

           // 3) check if the request and response packets has the same (FRP , RRP) ✔✔
    function bit common_check_FRP_and_RRP(HMC_Req_Sequence_item called_Req_seq_item , HMC_Rsp_Sequence_item called_Rsp_seq_item);
        if ( (called_Req_seq_item.FRP ==  HMC_Rsp_Sequence_item FRP)  &&  (called_Req_seq_item.RRP ==  called_Rsp_seq_item.RRP) )
             return 1;
        else return 0;
    endfunction: common_check_FRP_and_RRP

    //---------------------------------------------------------------------------------------------------------------
    //  Optional part (for future needings.)
    //---------------------------------------------------------------------------------------------------------------

    /*
    // [Optional] Perform any remaining comparisons or checks beforof simulation
    virtual function void check_phase (uvm_phase phase);
        //some code..
    endfunction : check_phase
    */

    // connection of scoreboard in environemt... ( https://www.chipverify.com/uvm/uvm-scoreboard )

endclass: HMC_Mem_Scoreboard

