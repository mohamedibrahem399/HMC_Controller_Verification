`include "HMC_Mem_Types.svh"
    
class HMC_Mem_Driver #(parameter DWIDTH = 256, NUM_LANES = 8) extends uvm_driver #(HMC_Rsp_Sequence_item);
    `uvm_component_param_utils(HMC_Mem_Driver#(DWIDTH, NUM_LANES))

    virtual HMC_Mem_IF #(DWIDTH, NUM_LANES)vif;
    HMC_Rsp_Sequence_item item;
    HMC_Rsp_Sequence_item packet_queue [$];

    

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
            if(! vif.P_RST_N)
                next_state = RESET;
             
                forever begin
                    state = next_state;
                    last_state = state;
        
                    case(state)
                        RESET:              reset();
                        INIT:               init();
                        PRBS:               prbs();
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
        vif.phy_data_rx_phy2link = {DWIDTH{1'bz}};
        vif.LXTXPS = 1'bz;
        vif.FERR_N = 1'bz;
        
        @(posedge vif.P_RST_N)
        next_state = INIT;
    endtask: reset
    //===========================================================================
    task init();
        while($time< vif.tINIT)
            @(posedge vif.clk_hmc);
            
        vif.LXTXPS = 1'b1;  
        next_state = PRBS;
    endtask: init
    //===========================================================================
    task prbs(); //non NULL pseudo random binary sequence
        //send prbs along tRESP1
        while($time< vif.tRESP1)begin
            for (int i=1; i < 4; i++)
                vif.phy_data_rx_phy2link= {DWIDTH{i[1:0]}};
        end
        next_state = NULL_1;
    endtask: prbs
    //===========================================================================
    task null_1();
        //wait for Requester to send TS1
        while(!(HMC_Mem_Monitor.next_state > NULL_1))
            vif.phy_data_rx_phy2link = {DWIDTH{1'b0}}; //add CRC
        
        //wait at most tRESP2
        while($time< vif.tRESP2)
            vif.phy_data_rx_phy2link = {DWIDTH{1'b0}}; //add CRC
        
        vif.phy_rx_ready  = 1'b1;
        next_state = TS1;
    endtask:null_1
    //===========================================================================
    task ts1();
        //wait for Requester to send NULL FLITs
        while(!(HMC_Mem_Monitor.next_state > TS1))
            //sending training sequences "incomplete"
        
        next_state = NULL_2;
    endtask:ts1
    //===========================================================================
    task null_2();
        int null_count;
        assert (std::randomize(null_count) with {null_count >= 16 && null_count < 64;});
        //send number of NULL FLITs between 16:64 null flit
        for (int i=0; i < null_flit_count; i++)
            vif.phy_data_rx_phy2link = {DWIDTH{1'b0}};
    
        next_state = INITIAL_TRETS;
    endtask:null_2
    //================= Transaction Layer Initialization =========================
    task initial_trets();
        //send TRET FLITs "incomplete"
        
        next_state = LINK_UP;
    endtask: initial_trets
    //===========================================================================      
    task link_up();
        item = HMC_Rsp_Sequence_item::type_id::create("item");

        if( packet_queue.size() == 0) begin
            seq_item_port.get_next_item(item);
            packet_queue.push_back(item);
            seq_item_port.item_done();
        end
        if (packet_queue.size() > 0)begin
            item = packet_queue.pop_front();
        end
        @(posedge clk_hmc)
            vif.phy_data_rx_phy2link <= item;
    endtask: link_up

endclass: HMC_Mem_Driver
