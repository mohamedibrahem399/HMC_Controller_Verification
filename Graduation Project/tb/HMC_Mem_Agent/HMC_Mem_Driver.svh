class HMC_Mem_Driver extends uvm_driver #(HMC_Rsp_Sequence_item);
    `uvm_component_utils(HMC_Mem_Driver)

    parameter FPW = 2, DWIDTH = 128*FPW, NUM_LANES = 16;

    virtual HMC_Mem_IF    hmc_mem_if;
    HMC_Rsp_Sequence_item Rsp_item;
    HMC_Rsp_Sequence_item tret;

    // Timing parameters
    int tNULL = 220ns; // at this time the RX receives null flits

    //Constructor
    function new(string name = "HMC_Mem_Driver", uvm_component parent);
        super.new(name, parent);
        `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new

    //Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)
      
        if(!(uvm_config_db #(virtual HMC_Mem_IF)::get(this,"*","hmc_mem_if",hmc_mem_if)))
            `uvm_error("DRIVER_CLASS", "Failed to get hmc_mem_if from config DB!")
    endfunction: build_phase

    //run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("DRIVER_CLASS", "Inside Run Phase!", UVM_HIGH)

        Power_On_and_initialization();
        forever begin
            Rsp_item = HMC_Rsp_Sequence_item::type_id::create("Rsp_item");
            seq_item_port.get_next_item(Rsp_item);
            drive(Rsp_item);
            seq_item_port.item_done();
        end
    endtask: run_phase
          
    //====================== Power-On and Initialization ========================
    task Power_On_and_initialization();
        #40; // time of the reset
        // 1. FERR_N: Fatal error indicator. HMC drives LOW if fatal error occurs  
        hmc_mem_if.FERR_N = 1'b1;
        // 2. disable scrambler and run length limiter "in RF"
        // 3. set LXTXPS
        repeat(4) @(posedge hmc_mem_if.hmc_clk);
            hmc_mem_if.LXTXPS = 1'b1;
        // 4. set P_RST_N "in RF"
        @(posedge hmc_mem_if.P_RST_N); // wait 3 posedge clk
        
        null_1();
        ts1();
        null_2();
        initial_trets();
    endtask: Power_On_and_initialization
    //===========================================================================
    task null_1();
        // 5. phy_data_rx_phy2link = Nulls or PRBS but in case of HMC Memory it should be PRBS "Pseudo Random binary sequence"
        repeat(3) @(posedge hmc_mem_if.hmc_clk);
            hmc_mem_if.phy_data_rx_phy2link = {DWIDTH{1'b0}}; 
            
        // 6. set phy_tx_ready, phy_rx_ready signals and the init_cont_set "in RF"
        repeat(7) @(posedge hmc_mem_if.hmc_clk);               
            hmc_mem_if.phy_tx_ready = 1'b1;
            hmc_mem_if.phy_rx_ready = 1'b1;
        @(posedge hmc_mem_if.hmc_clk);
        
        if(hmc_mem_if.phy_data_tx_link2phy[5:0]==6'b0)
            `uvm_info(get_type_name(),$sformatf("@%0t: The TX Side is Now sending null_1 packet", $time), UVM_LOW)
        else begin
            `uvm_info(get_type_name(),$sformatf("@%0t: The TX Side doesn't send null_1 packet", $time), UVM_LOW)
            repeat(3) @(posedge hmc_mem_if.hmc_clk);
                hmc_mem_if.phy_data_rx_phy2link = {DWIDTH{1'b0}}; 
        end
        
        #tNULL;
    endtask:null_1
    //===========================================================================
    task ts1();
        case(FPW)
            2: begin
                // 7. wait until all descramblers are aligned 'synchronized'
                @(posedge hmc_mem_if.hmc_clk);
                for(bit[15:0] i=0; i<=15; i++) begin
                    hmc_mem_if.phy_data_rx_phy2link = {{16'hF0C0 + i},{14{16'hF050 +i}},{16'hF030 + i}};
                    wait(hmc_mem_if.phy_bit_slip !=0);
                    wait(hmc_mem_if.phy_bit_slip ==0);
                    repeat(2)@(posedge hmc_mem_if.hmc_clk);
                    wait(hmc_mem_if.phy_bit_slip ==0);
                    if(hmc_mem_if.phy_bit_slip ==0)begin
                        wait(hmc_mem_if.phy_bit_slip !=0);
                        wait(hmc_mem_if.phy_bit_slip ==0);
                        wait(hmc_mem_if.phy_bit_slip !=0);
                    end
                    else if (hmc_mem_if.phy_bit_slip !=0) begin
                        wait(hmc_mem_if.phy_bit_slip ==0);
                        wait(hmc_mem_if.phy_bit_slip !=0);
                    end
                end
            end
            default: begin // FPW=4
                // 7. wait until all descramblers are aligned "synchronized"
                @(posedge hmc_mem_if.hmc_clk);
                for(bit[15:0]j=0; j<=14; j+=2) begin
                    hmc_mem_if.phy_data_rx_phy2link = {{16'hf0c1+j}, {16'hf0c0+j}, {14{{16'hf051+j},{16'hf050+j}}}, {16'hf031+j}, {16'hf030+j}};
                    wait(hmc_mem_if.phy_bit_slip !=0);
                    wait(hmc_mem_if.phy_bit_slip ==0);
                    repeat(2)@(posedge hmc_mem_if.hmc_clk);
                    wait(hmc_mem_if.phy_bit_slip ==0);
                    if(hmc_mem_if.phy_bit_slip ==0)begin
                        wait(hmc_mem_if.phy_bit_slip !=0);
                        wait(hmc_mem_if.phy_bit_slip ==0);
                        wait(hmc_mem_if.phy_bit_slip !=0);
                    end
                    else if (hmc_mem_if.phy_bit_slip !=0) begin
                        wait(hmc_mem_if.phy_bit_slip ==0);
                        wait(hmc_mem_if.phy_bit_slip !=0);
                    end
                end
            end
        endcase 

        if(hmc_mem_if.phy_data_tx_link2phy[5:0]!=6'b0)
            `uvm_info(get_type_name(),$sformatf("@%0t: The TX Side is Now sending TS1 packet", $time), UVM_LOW)
        else 
            `uvm_info(get_type_name(),$sformatf("@%0t: The TX Side doesn't send TS1 packet", $time), UVM_LOW)
    endtask:ts1
    //===========================================================================
    task null_2();
        // 8. null packet send "16 packet to enter TRET State"
        hmc_mem_if.phy_data_rx_phy2link = {DWIDTH{1'b0}};
        repeat(5) @(posedge hmc_mem_if.hmc_clk); // number of null cycles sent = 4'b1111 = 4'd15;
        // After this line the Link Up in Status General RF is seted which means Link is ready for operation
        
        if(hmc_mem_if.phy_data_tx_link2phy[5:0]==6'b0)
            `uvm_info(get_type_name(),$sformatf("@%0t: The TX Side is Now sending null_2 packet", $time), UVM_LOW)
        else begin
            `uvm_info(get_type_name(),$sformatf("@%0t: The TX Side doesn't send null_2 packet", $time), UVM_LOW)
            hmc_mem_if.phy_data_rx_phy2link = {DWIDTH{1'b0}}; 
            repeat(5) @(posedge hmc_mem_if.hmc_clk);
        end
    endtask:null_2
    //================= Transaction Layer Initialization =========================
    task initial_trets(); 
        bit[63:0]       TRET_Header;
        bit[63:0]       TRET_Tail;
        bit[127:0]      TRET_Packet;

        tret =  HMC_Rsp_Sequence_item::type_id::create("tret");
        // 9. Sending a tret packet to the controller
        repeat (40) begin
            @(posedge hmc_mem_if.hmc_clk);
            TRET_Packet_Rand: assert(tret.randomize() with {CMD == TRET; 
                                                            DLN == 1;
                                                            LNG == 1;
                                                            TAG == 0;}
                                                            );
            tret.print();
            TRET_Header = {tret.RES1, tret.SLID, tret.RES2, tret.TGA, tret.TAG, tret.DLN, tret.LNG, tret.RES3, tret.CMD};
            TRET_Tail = {tret.CRC, tret.RTC, tret.ERRSTAT, tret.DINV, tret.SEQ, tret.FRP, tret.RRP};                                        
            TRET_Packet = {TRET_Tail, TRET_Header};
            hmc_mem_if.phy_data_rx_phy2link = {TRET_Packet, TRET_Packet};
        end
        hmc_mem_if.phy_data_rx_phy2link = 0;
        #50ns;

    endtask: initial_trets
    //===========================================================================
    task drive(HMC_Rsp_Sequence_item Rsp_item);

        bit[ 63:0]       Rsp_Header;
        bit[ 63:0]       Rsp_Tail;
        bit[127:0]       Flit;
        bit[127:0]       Rsp_in_Flits[$];
        bit[127:0]       Rsp_in_Flits_queue[$:9]; 
        bit[DWIDTH-1:0]  phy_data_rx;
        
        int Num_Cycle = 0;


        Rsp_item.print();
        $display("Data size: %0d",Rsp_item.data.size(),"  LNG: %0d", Rsp_item.LNG,"  CMD: ",  Rsp_item.CMD.name);

        //The Header of the Response Packet
        Rsp_Header = {Rsp_item.RES1, Rsp_item.SLID, Rsp_item.RES2, Rsp_item.TGA, Rsp_item.TAG, Rsp_item.DLN, Rsp_item.LNG, Rsp_item.RES3, Rsp_item.CMD};
        $displayh("Header: ", Rsp_Header);
    
        //The Tail of the Response Packet
        Rsp_Tail = {Rsp_item.CRC, Rsp_item.RTC, Rsp_item.ERRSTAT, Rsp_item.DINV, Rsp_item.SEQ, Rsp_item.FRP, Rsp_item.RRP};
        $displayh("Tail: ", Rsp_Tail);
    
        // Split the Response packet to number of Flits according to the packet length each Flit 128 bits
        case(Rsp_item.LNG)
            1:  begin 
                Flit = {Rsp_Tail, Rsp_Header};
                Rsp_in_Flits.push_front(Flit);
            end
            2:  begin 
                Flit = {Rsp_item.data[0], Rsp_Header};
                Rsp_in_Flits.push_front(Flit); 
                
                Flit = {Rsp_Tail, Rsp_item.data[1]};
                Rsp_in_Flits.push_front(Flit); 
            end
            3:  begin
                Flit = {Rsp_item.data[0], Rsp_Header};
                Rsp_in_Flits.push_front(Flit); 
                  
                Flit = {Rsp_item.data[2],Rsp_item.data[1]};
                Rsp_in_Flits.push_front(Flit);
    
                Flit={Rsp_Tail, Rsp_item.data[3]};
                Rsp_in_Flits.push_front(Flit);
            end
            default: begin
                Flit = {Rsp_item.data[0], Rsp_Header};
                Rsp_in_Flits.push_front(Flit); 
    
                for(int i=1, j=1; j <= Rsp_item.LNG-2 ; i+=2, j++) begin
                    Flit = {Rsp_item.data[i+1], Rsp_item.data[i]};
                    Rsp_in_Flits.push_front(Flit);
                    //$display("Rsp_in_Flits: ",Rsp_in_Flits);
                end
    
                Flit = {Rsp_Tail, Rsp_item.data[Rsp_item.data.size() -1]};
                Rsp_in_Flits.push_front(Flit);
            end    
        endcase
        if(Rsp_item.LNG %2)
            Rsp_in_Flits.push_front(128'b0);

        $displayh("Rsp_in_Flits: ");
        $displayh(Rsp_in_Flits);
    
        while(Rsp_in_Flits.size()!=0) begin 
            for(int k=0; k<FPW; k++) begin  
                Rsp_in_Flits_queue.push_front(Rsp_in_Flits.pop_back());
            end
                
            @(posedge hmc_mem_if.hmc_clk);
    
            if(FPW == 2) 
                phy_data_rx = {Rsp_in_Flits_queue[0], Rsp_in_Flits_queue[1]};
                
            else if (FPW == 4) 
                phy_data_rx = {Rsp_in_Flits_queue[0], Rsp_in_Flits_queue[1], Rsp_in_Flits_queue[2], Rsp_in_Flits_queue[3]};
                
            else if (FPW == 6) 
                phy_data_rx = {128'b0, 128'b0, Rsp_in_Flits_queue[0], Rsp_in_Flits_queue[1], Rsp_in_Flits_queue[2], Rsp_in_Flits_queue[3], Rsp_in_Flits_queue[4], Rsp_in_Flits_queue[5]};            
                
            else if (FPW == 8) 
                phy_data_rx = { Rsp_in_Flits_queue[0], Rsp_in_Flits_queue[1], Rsp_in_Flits_queue[2], Rsp_in_Flits_queue[3], Rsp_in_Flits_queue[4], Rsp_in_Flits_queue[5], Rsp_in_Flits_queue[6], Rsp_in_Flits_queue[7]};            
            
            //$displayh("@%0t : ",$time , phy_data_rx);
            
            hmc_mem_if.phy_data_rx_phy2link <=  phy_data_rx;               
            Num_Cycle++;
            $display("Cycle: %0d",Num_Cycle);
        end
          
        Rsp_in_Flits_queue.delete();
        $display("Rsp_in_Flits size: %0d", Rsp_in_Flits.size());
        $display("Rsp_in_Flits_queue size: %0d", Rsp_in_Flits_queue.size());

        
        if(Rsp_in_Flits.size()==0) begin
            @(posedge hmc_mem_if.hmc_clk);
            hmc_mem_if.phy_data_rx_phy2link <=  0; 
        end
        
    endtask: drive
endclass: HMC_Mem_Driver