`include "HMC_Mem_Types.svh"
    
class HMC_Mem_Driver #(parameter FPW = 4, DWIDTH = 128*FPW, NUM_LANES = 8) extends uvm_driver #(HMC_Rsp_Sequence_item);
    `uvm_component_param_utils(HMC_Mem_Driver#(DWIDTH, NUM_LANES))

    virtual HMC_Mem_IF #(DWIDTH, NUM_LANES)vif;
    HMC_Rsp_Sequence_item Rsp_item;

    state_t next_state = RESET;
    state_t state      = RESET;
    state_t last_state = LINK_UP;

    //Constructor
    function new(string name = "HMC_Mem_Driver", uvm_component parent);
        super.new(name, parent);
        `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new

    //Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)

        if(!(uvm_config_db #(virtual HMC_Mem_IF)::get(this,"*","vif",vif)))
            `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!")
    endfunction: build_phase

    //run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("DRIVER_CLASS", "Inside Run Phase!", UVM_HIGH)

        forever begin
            Rsp_item = HMC_Rsp_Sequence_item::type_id::create("Rsp_item");
            
            if(! vif.P_RST_N)
                next_state = RESET;
             
                forever begin
                    state = next_state;
                    last_state = state;
        
                    case(state)
                        RESET:              reset();
                        INIT:               init();
                        NULL_1:             null_1();
                        TS1:                ts1();
                        NULL_2:             null_2();
                        INITIAL_TRETS:      initial_trets();
                        LINK_UP:            link_up();
                    endcase
                end
        end
    endtask: run_phase
        
    //====================== Power-On and Initialization ========================
    task reset();
        // Write 64'b0000000000000000000110000001000000000000111111110000000000010001 on the control_register at address 4'b0010
        // to disable scrambler and run length enable and to set P_RST_N
        @(posedge vif.P_RST_N);
            next_state = INIT;
    endtask: reset
    //===========================================================================
    task init();
        @(posedge vif.hmc_clk);
            vif.LXTXPS = 1'b1; 
            vif.FERR_N = 1'b0; 
        @(posedge vif.hmc_clk);
        vif.phy_tx_ready = 1'b0;
        vif.phy_rx_ready = 1'b0;
        // Write 64'b0000000000000000000110000001000000000000111111110000000000010011 on the control_register at address 4'b0010
        // to set init_cont_set 
        next_state = NULL_1;
    endtask: init
    //===========================================================================
    task null_1();
        wait(Rsp_item.CMD == 6'b000000);
        while($time< vif.tRESP1)
            vif.phy_data_rx_phy2link = {DWIDTH{1'b0}}; 
        
        while($time< vif.tRESP2)
            vif.phy_data_rx_phy2link = {DWIDTH{1'b0}};
        
        next_state = TS1;
    endtask:null_1
    //===========================================================================
    task ts1();
        /*
        // Training Sequence that is generated and repeated at TX  detected by testing the RTL in Questa-Sim
        @ (FPW =4 & Half width Config 'LOG_NUM_LANES = 3')
        Ts1: 11110000110000111111000011000010111100001100000111110000110000001111000001010011111100000101001011110000010100011111000001010000111100000101001111110000010100101111000001010001111100000101000011110000010100111111000001010010111100000101000111110000010100001111000001010011111100000101001011110000010100011111000001010000111100000101001111110000010100101111000001010001111100000101000011110000010100111111000001010010111100000101000111110000010100001111000000110011111100000011001011110000001100011111000000110000
        Ts2: 11110000110001111111000011000110111100001100010111110000110001001111000001010111111100000101011011110000010101011111000001010100111100000101011111110000010101101111000001010101111100000101010011110000010101111111000001010110111100000101010111110000010101001111000001010111111100000101011011110000010101011111000001010100111100000101011111110000010101101111000001010101111100000101010011110000010101111111000001010110111100000101010111110000010101001111000000110111111100000011011011110000001101011111000000110100  
        Ts3: 11110000110010111111000011001010111100001100100111110000110010001111000001011011111100000101101011110000010110011111000001011000111100000101101111110000010110101111000001011001111100000101100011110000010110111111000001011010111100000101100111110000010110001111000001011011111100000101101011110000010110011111000001011000111100000101101111110000010110101111000001011001111100000101100011110000010110111111000001011010111100000101100111110000010110001111000000111011111100000011101011110000001110011111000000111000     
        Ts4: 11110000110011111111000011001110111100001100110111110000110011001111000001011111111100000101111011110000010111011111000001011100111100000101111111110000010111101111000001011101111100000101110011110000010111111111000001011110111100000101110111110000010111001111000001011111111100000101111011110000010111011111000001011100111100000101111111110000010111101111000001011101111100000101110011110000010111111111000001011110111100000101110111110000010111001111000000111111111100000011111011110000001111011111000000111100 

        @ (FPW =4 & Full width Config 'LOG_NUM_LANES = 4')
        Ts1: 11110000110000011111000011000000111100000101000111110000010100001111000001010001111100000101000011110000010100011111000001010000111100000101000111110000010100001111000001010001111100000101000011110000010100011111000001010000111100000101000111110000010100001111000001010001111100000101000011110000010100011111000001010000111100000101000111110000010100001111000001010001111100000101000011110000010100011111000001010000111100000101000111110000010100001111000001010001111100000101000011110000001100011111000000110000
        Ts2: 11110000110000111111000011000010111100000101001111110000010100101111000001010011111100000101001011110000010100111111000001010010111100000101001111110000010100101111000001010011111100000101001011110000010100111111000001010010111100000101001111110000010100101111000001010011111100000101001011110000010100111111000001010010111100000101001111110000010100101111000001010011111100000101001011110000010100111111000001010010111100000101001111110000010100101111000001010011111100000101001011110000001100111111000000110010
        Ts3: 11110000110001011111000011000100111100000101010111110000010101001111000001010101111100000101010011110000010101011111000001010100111100000101010111110000010101001111000001010101111100000101010011110000010101011111000001010100111100000101010111110000010101001111000001010101111100000101010011110000010101011111000001010100111100000101010111110000010101001111000001010101111100000101010011110000010101011111000001010100111100000101010111110000010101001111000001010101111100000101010011110000001101011111000000110100
        Ts4: 11110000110001111111000011000110111100000101011111110000010101101111000001010111111100000101011011110000010101111111000001010110111100000101011111110000010101101111000001010111111100000101011011110000010101111111000001010110111100000101011111110000010101101111000001010111111100000101011011110000010101111111000001010110111100000101011111110000010101101111000001010111111100000101011011110000010101111111000001010110111100000101011111110000010101101111000001010111111100000101011011110000001101111111000000110110
        Ts5: 11110000110010011111000011001000111100000101100111110000010110001111000001011001111100000101100011110000010110011111000001011000111100000101100111110000010110001111000001011001111100000101100011110000010110011111000001011000111100000101100111110000010110001111000001011001111100000101100011110000010110011111000001011000111100000101100111110000010110001111000001011001111100000101100011110000010110011111000001011000111100000101100111110000010110001111000001011001111100000101100011110000001110011111000000111000
        Ts6: 11110000110010111111000011001010111100000101101111110000010110101111000001011011111100000101101011110000010110111111000001011010111100000101101111110000010110101111000001011011111100000101101011110000010110111111000001011010111100000101101111110000010110101111000001011011111100000101101011110000010110111111000001011010111100000101101111110000010110101111000001011011111100000101101011110000010110111111000001011010111100000101101111110000010110101111000001011011111100000101101011110000001110111111000000111010
        Ts7: 11110000110011011111000011001100111100000101110111110000010111001111000001011101111100000101110011110000010111011111000001011100111100000101110111110000010111001111000001011101111100000101110011110000010111011111000001011100111100000101110111110000010111001111000001011101111100000101110011110000010111011111000001011100111100000101110111110000010111001111000001011101111100000101110011110000010111011111000001011100111100000101110111110000010111001111000001011101111100000101110011110000001111011111000000111100
        Ts8: 11110000110011111111000011001110111100000101111111110000010111101111000001011111111100000101111011110000010111111111000001011110111100000101111111110000010111101111000001011111111100000101111011110000010111111111000001011110111100000101111111110000010111101111000001011111111100000101111011110000010111111111000001011110111100000101111111110000010111101111000001011111111100000101111011110000010111111111000001011110111100000101111111110000010111101111000001011111111100000101111011110000001111111111000000111110
        */
        // ==============  incompleted  ==============
        
        next_state = NULL_2;
    endtask:ts1
    //===========================================================================
    task null_2();
        int null_count;
        assert (std::randomize(null_count) with {null_count >= 16 && null_count < 32;});
        //send number of NULL FLITs between 16:64 null flit
        for (int i=0; i < null_flit_count; i++)
            vif.phy_data_rx_phy2link = {DWIDTH{1'b0}}; 
    
        next_state = INITIAL_TRETS;
    endtask:null_2
    //================= Transaction Layer Initialization =========================
    task initial_trets(); 
        // ==============  incompleted  ==============

        next_state = LINK_UP;
    endtask: initial_trets
    //===========================================================================
    task link_up();
        seq_item_port.get_next_item(Rsp_item);
        drive(Rsp_item);
        seq_item_port.item_done();
    endtask: link_up
    //===========================================================================
    task drive(HMC_Rsp_Sequence_item Rsp_item);

        bit[ 63:0]       Rsp_Header;
        bit[ 63:0]       Rsp_Tail;
        bit[127:0]       Flit;
        bit[127:0]       Rsp_in_Flits[$];
        bit[127:0]       Rsp_in_Flits_queue[$:7]; //Maximum size 8 flit [FPW = 8]
        bit[DWIDTH-1:0]  phy_data_rx;
        
        int Num_Cycle = 0;
    
        //The Header of the Response Packet
        Rsp_Header = {Rsp_item.RES1, Rsp_item.SLID, Rsp_item.RES2, Rsp_item.TGA, Rsp_item.TAG, Rsp_item.DLN, Rsp_item.LNG, Rsp_item.RES3, Rsp_item.CMD};
        //$displayh(Rsp_Header);
    
        //The Tail of the Response Packet
        Rsp_Tail = {Rsp_item.CRC, Rsp_item.RTC, Rsp_item.ERRSTAT, Rsp_item.DINV, Rsp_item.SEQ, Rsp_item.FRP, Rsp_item.RRP};
        //$displayh(Rsp_Tail);
    
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
        //$display(Rsp_in_Flits);
    
        while(Rsp_in_Flits.size()!=0) begin 
            for(int k=0; k<FPW; k++) begin
                Rsp_in_Flits_queue.push_front(Rsp_in_Flits.pop_back());
            end
                
            @(posedge vif.hmc_clk);
    
            if(FPW == 2) 
                phy_data_rx = {Rsp_in_Flits_queue[0], Rsp_in_Flits_queue[1]};
                
            else if (FPW == 4) 
                phy_data_rx = {Rsp_in_Flits_queue[0], Rsp_in_Flits_queue[1], Rsp_in_Flits_queue[2], Rsp_in_Flits_queue[3]};
                
            else if (FPW == 6) 
                phy_data_rx = {128'b0, 128'b0, Rsp_in_Flits_queue[0], Rsp_in_Flits_queue[1], Rsp_in_Flits_queue[2], Rsp_in_Flits_queue[3], Rsp_in_Flits_queue[4], Rsp_in_Flits_queue[5]};            
                
            else if (FPW == 8) 
                phy_data_rx = { Rsp_in_Flits_queue[0], Rsp_in_Flits_queue[1], Rsp_in_Flits_queue[2], Rsp_in_Flits_queue[3], Rsp_in_Flits_queue[4], Rsp_in_Flits_queue[5], Rsp_in_Flits_queue[6], Rsp_in_Flits_queue[7]};            
            
            //$displayh("@%0t : ",$time , phy_data_rx);
            
            vif.phy_data_rx_phy2link <=  phy_data_rx;
    
            Rsp_in_Flits_queue.delete();
                
            Num_Cycle++;
        end
    
    endtask: drive
    // Test of Drive Task in EDA Playground: https://www.edaplayground.com/x/s3D5  "note: its a private module"
endclass: HMC_Mem_Driver
