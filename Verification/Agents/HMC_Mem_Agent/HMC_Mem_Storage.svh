class HMC_Mem_Storage #(ADDRESS_WIDTH = 34) extends uvm_component;
    `uvm_component_param_utils(HMC_Mem_Storage#(ADDRESS_WIDTH))

    HMC_Req_Sequence_item Req_item;
    HMC_Rsp_Sequence_item Rsp_item;

    HMC_Req_Sequence_item Req_Transaction [$];

    // TLM analysis port from monitor to memory
    uvm_analysis_imp #(HMC_Req_Sequence_item , HMC_Mem_Storage) HMC_Mem_Analysis_Monitor_Storage_Imp; 
    uvm_analysis_port#(HMC_Rsp_Sequence_item ) HMC_Mem_Analysis_Storage_Sequencer_Port;     

    // Associative Array
    HMC_Req_Sequence_item Storage [bit[ADDRESS_WIDTH-1:0]]; 

    // constructor
    function new ( string name = "HMC_Mem_Storage" , uvm_component parent = null);
        super.new(name,parent);
        `uvm_info("STORAGE_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new

    // build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("STORAGE_CLASS", "Build Phase!", UVM_HIGH)

        HMC_Mem_Analysis_Monitor_Storage_Imp    = new("HMC_Mem_Analysis_Monitor_Storage_Imp"   , this);
        HMC_Mem_Analysis_Storage_Sequencer_Port = new("HMC_Mem_Analysis_Storage_Sequencer_Port", this);
    endfunction: build_phase

    // write task for monitor 
    task write(HMC_Req_Sequence_item Req_item);
        Req_Transaction.push_back(Req_item);
    endtask: write

    // null packet from monitor
    function HMC_Rsp_Sequence_item Null_Packets (HMC_Req_Sequence_item Req_item);
        Null_Packets = 128'b0 ;
        Null_Packets.CRC = Req_item.CRC;
    endfunction: Null_Packets

    // token return from monitor
    function HMC_Rsp_Sequence_item Token_Return_Packets (HMC_Req_Sequence_item Req_item);
        Token_Return_Packets.RES1    = 22'b0;
        Token_Return_Packets.SLID    = Req_item.SLID;
        Token_Return_Packets.RES2    = 6'b0;
        Token_Return_Packets.TGA     = 9'b0;
        Token_Return_Packets.TAG     = Req_item.TAG; // 9'h0
        Token_Return_Packets.DLN     = 4'b0001;
        Token_Return_Packets.LNG     = 4'b0001;
        Token_Return_Packets.RES3    = 1'b0;
        Token_Return_Packets.CMD     = TRET;

        Token_Return_Packets.CRC     = Req_item.CRC;
        Token_Return_Packets.RTC     = Req_item.RTC;
        Token_Return_Packets.ERRSTAT = 7'b0;
        Token_Return_Packets.DINV    = 1'b0;
        Token_Return_Packets.SEQ     = Req_item.SEQ;
        Token_Return_Packets.FRP     = Req_item.FRP;
        Token_Return_Packets.RRP     = Req_item.RRP;
    endfunction: Token_Return_Packets


    // Write packet to the storage
    function void write_req_packet(HMC_Req_Sequence_item Req_item);
        Storage[Req_item.ADRS]= Req_item;
    endfunction: write_req_packet

    function HMC_Rsp_Sequence_item write_rsp_packet(HMC_Req_Sequence_item Req_item);
        write_rsp_packet.RES1    = 22'b0;
        write_rsp_packet.SLID    = Req_item.SLID;
        write_rsp_packet.RES2    = 6'b0;
        write_rsp_packet.TGA     = 9'b0;
        write_rsp_packet.TAG     = Req_item.TAG;
        write_rsp_packet.DLN     = 4'b0001;
        write_rsp_packet.LNG     = 4'b0001;
        write_rsp_packet.RES3    = 1'b0;
        write_rsp_packet.CMD     = WR_RS;

        write_rsp_packet.CRC     = Req_item.CRC;
        write_rsp_packet.RTC     = Req_item.RTC;
        write_rsp_packet.ERRSTAT = 7'b0;
        write_rsp_packet.DINV    = 1'b0;
        write_rsp_packet.SEQ     = Req_item.SEQ;
        write_rsp_packet.FRP     = Req_item.FRP;
        write_rsp_packet.RRP     = Req_item.RRP;
    endfunction: write_rsp_packet

    // Read packet from the storage
    function HMC_Rsp_Sequence_item read_packet(HMC_Req_Sequence_item Req_item);
        if(! Storage.exists(Req_item.ADRS))
            `uvm_info("STORAGE_CLASS","Address is not in the storage", UVM_HIGH)

        else begin
            `uvm_info("STORAGE_CLASS","Address is in the storage", UVM_HIGH)
            read_packet = read_rsp_packet(Storage[Req_item.ADRS]); // DLN   LNG   data

            read_packet.RES1    = 22'b0;
            read_packet.SLID    = Req_item.SLID;
            read_packet.RES2    = 6'b0;
            read_packet.TGA     = 9'b0;
            read_packet.TAG     = Req_item.TAG;
            read_packet.RES3    = 1'b0;
            read_packet.CMD     = RD_RS;

            read_packet.CRC     = Req_item.CRC;
            read_packet.RTC     = Req_item.RTC;
            read_packet.ERRSTAT = 7'b0;
            read_packet.DINV    = 1'b0;
            read_packet.SEQ     = Req_item.SEQ;
            read_packet.FRP     = Req_item.FRP;
            read_packet.RRP     = Req_item.RRP;
        end
    endfunction: read_packet

    function HMC_Rsp_Sequence_item read_rsp_packet(HMC_Req_Sequence_item stored_item);
        read_rsp_packet.RES1    = 22'b0;
        read_rsp_packet.SLID    = stored_item.SLID;
        read_rsp_packet.RES2    = 6'b0;
        read_rsp_packet.TGA     = 9'b0;
        read_rsp_packet.TAG     = stored_item.TAG;
        readread_rsp_packet_packet.RES3    = 1'b0;
        read_rsp_packet.CMD     = RD_RS;

        if (stored_item.data.size() == 0) begin
            read_rsp_packet.DLN     = 4'b0001;
            read_rsp_packet.LNG     = 4'b0001;
        end
        else if(stored_item.data.size() == 2)begin
            read_rsp_packet.DLN     = 4'b0010;
            read_rsp_packet.LNG     = 4'b0010;
        end
        else begin
            read_rsp_packet.DLN     = (stored_item.data.size() - 2)/2 +2;
            read_rsp_packet.LNG     = (stored_item.data.size() - 2)/2 +2;
        end
        
        read_rsp_packet.data    = stored_item.data;

        read_rsp_packet.CRC     = stored_item.CRC;
        read_rsp_packet.RTC     = stored_item.RTC;
        read_rsp_packet.ERRSTAT = 7'b0;
        read_rsp_packet.DINV    = 1'b0;
        read_rsp_packet.SEQ     = stored_item.SEQ;
        read_rsp_packet.FRP     = stored_item.FRP;
        read_rsp_packet.RRP     = stored_item.RRP;     
           
    endfunction: read_rsp_packet

    // Error
    function HMC_Rsp_Sequence_item error_rsp_packet(HMC_Req_Sequence_item Req_item);
        error_rsp_packet.RES1    = 22'b0;            // [63:42]
        error_rsp_packet.SLID    = Req_item.SLID; // [41:39]
        error_rsp_packet.RES2    = 6'b0;             // [38:33] 
        error_rsp_packet.TGA     = 9'b0;             // [32:24]
        error_rsp_packet.TAG     = Req_item.TAG;  // [23:15]
        error_rsp_packet.RES3    = 1'b0;             // [6]

        /*
            Invalid command: An unsupported command existed in a request packet. 
            Rsp: Write response packet(TAG = tag of corresponding request)
        */
        if(Req_item.CMD != NULL||PRET||TRET||IRTRY||WR16||WR32||WR48||WR64||WR80||WR96||WR112||WR128||TWO_ADD8||ADD16||P_WR16||P_WR32||P_WR48||P_WR64||P_WR80||P_WR96||P_WR112||P_WR128||P_TWO_ADD8||P_ADD16||RD16||RD32||RD48||RD64||RD80||RD96||RD112||RD128) begin
            error_rsp_packet.DLN     = 4'b0001;     // [14:11]
            error_rsp_packet.LNG     = 4'b0001;     // [10:7]
            error_rsp_packet.CMD     = WR_RS;       // [5:0] 
            error_rsp_packet.ERRSTAT = 7'b0110000;  // [26:20]
        end

        /*
            Invalid length: An invalid length was specified for the given command in a request packet. 
            Read response packet(TAG = tag of corresponding request)
        */
        else if(Req_item.LNG >= 10)begin
            error_rsp_packet.DLN     = 4'b0001;     // [14:11]
            error_rsp_packet.LNG     = 4'b0001;     // [10:7]
            error_rsp_packet.CMD     = RD_RS;       // [5:0] 
            error_rsp_packet.ERRSTAT = 7'b0110001;  // [26:20]
        end

        error_rsp_packet.CRC     = Req_item.CRC;  // [63:32]
        error_rsp_packet.RTC     = Req_item.RTC;  // [31:27]
        error_rsp_packet.DINV    = 1'b0;          // [19]
        error_rsp_packet.SEQ     = Req_item.SEQ;  // [18:16]
        error_rsp_packet.FRP     = Req_item.FRP;  // [15:8]
        error_rsp_packet.RRP     = Req_item.RRP;  // [7:0]
    endfunction: error_rsp_packet

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("STORAGE_CLASS", "Run Phase!", UVM_HIGH)
        
        forever begin
            HMC_Req_Sequence_item Current_Req_Transaction;

            Rsp_item = HMC_Rsp_Sequence_item::type_id::create("Rsp_item");

            wait(Req_Transaction.size() != 0 );
            Current_Req_Transaction = Req_Transaction.pop_front();

            //Invalid length
            if(Current_Req_Transaction.LNG >= 10) begin
                Rsp_item = error_rsp_packet(Current_Req_Transaction);
            end
            
            //Valid length
            else begin
                // Flow Commands   NULL = 6'b000000
                if(Current_Req_Transaction.CMD == NULL) begin 
                    Rsp_item = Null_Packets(Current_Req_Transaction);
                end

                // Flow Commands   TRET = 6'b000010
                else if (Current_Req_Transaction.CMD == TRET) begin
                    Rsp_item = Token_Return_Packets(Current_Req_Transaction);
                end

                /*
                    // WRITE requests
                    WR16  = 6'b001000, WR32  = 6'b001001, WR48 = 6'b001010,
                    WR64  = 6'b001011, WR80  = 6'b001100, WR96 = 6'b001101,
                    WR112 = 6'b001110, WR128 = 6'b001111
                    // ATOMIC Requests
                    TWO_ADD8= 6'b010010, ADD16 = 6'b010011
                */
                else if(Current_Req_Transaction.CMD == WR16||WR32||WR48||WR64||WR80||WR96||WR112||WR128||TWO_ADD8||ADD16) begin
                    write_req_packet(Current_Req_Transaction);
                    Rsp_item = write_rsp_packet(Current_Req_Transaction);  
                end

                /*
                    // Posted Write Request: not waiting any response
                    P_WR16  = 6'b011000, P_WR32  = 6'b011001, P_WR48 = 6'b011010,
                    P_WR64  = 6'b011011, P_WR80  = 6'b011100, P_WR96 = 6'b011101,
                    P_WR112 = 6'b011110, P_WR128 = 6'b011111
                    //POSTED ATOMIC Requests
                    P_TWO_ADD8 = 6'b100010, P_ADD16 = 6'b100011
                */
                else if (Current_Req_Transaction.CMD == P_WR16||P_WR32||P_WR48||P_WR64||P_WR80||P_WR96||P_WR112||P_WR128||P_TWO_ADD8||P_ADD16) begin
                    write_req_packet(Current_Req_Transaction);
                end

                /*
                    //READ Requests
                    RD16  = 6'b110000, RD32  = 6'b110001, RD48 = 6'b110010,
                    RD64  = 6'b110011, RD80  = 6'b110100, RD96 = 6'b110101,
                    RD112 = 6'b110110, RD128 = 6'b110111
                */
                else if (Current_Req_Transaction.CMD == RD16||RD32||RD48||RD64||RD80||RD96||RD112||RD128) begin
                    Rsp_item = read_packet(Current_Req_Transaction);  
                end
                
                // Invalid command
                else begin 
                    Rsp_item = error_rsp_packet(Current_Req_Transaction);
                end
            end
            // Passing the Response packet to the Sequencer via the analysis port write() 
            HMC_Mem_Analysis_Storage_Sequencer_Port.write(Rsp_item);
        end
    endtask: run_phase
endclass: HMC_Mem_Storage
