class RF_Driver extends uvm_driver #(RF_Sequence_Item);
    `uvm_component_utils(RF_Driver)

    virtual RF_IF     rf_if;
    RF_Sequence_Item  rf_item;

    //Constructor
    function new(string name = "RF_Driver", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    //Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)

        if(!(uvm_config_db #(virtual RF_IF)::get(this, "*", "rf_if", rf_if)))
            `uvm_error("DRIVER_CLASS", "Failed to get rf_if from config DB!")
    endfunction: build_phase

    //run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Run Phase!", UVM_NONE)

        forever begin                               
            rf_item = RF_Sequence_Item::type_id::create("rf_item");
            seq_item_port.get_next_item(rf_item);
            drive(rf_item);
            seq_item_port.item_done();
        end
    endtask: run_phase

    task reset_rf(); // synchronous reset
        rf_if.rf_write_data  <= {64{1'bx}};
        rf_if.rf_address     <= {4{1'bx}};
        rf_if.rf_read_en     <= 1'b0;
        rf_if.rf_write_en    <= 1'b0;
        
        while(! rf_if.res_n_hmc)
            @(posedge rf_if.clk_hmc);
    endtask: reset_rf
      
    task drive(RF_Sequence_Item rf_item);
        reset_rf();
        @(posedge rf_if.clk_hmc);
            rf_if.rf_write_data  <= rf_item.rf_write_data;
            rf_if.rf_address     <= rf_item.rf_address;
            rf_if.rf_read_en     <= rf_item.rf_read_en;
            rf_if.rf_write_en    <= rf_item.rf_write_en;


        @(posedge rf_if.clk_hmc);
            rf_if.rf_read_en     <= 1'b0;
            rf_if.rf_write_en    <= 1'b0;
     		rf_item.print(); 
       
        @(posedge rf_if.clk_hmc);    
        while(! rf_if.rf_access_complete)
            @(posedge rf_if.clk_hmc);
        
        @(posedge rf_if.clk_hmc);
            rf_if.rf_write_data  <= {64{1'bx}};
            rf_if.rf_address     <= {4{1'bx}}; 
    endtask: drive
endclass: RF_Driver