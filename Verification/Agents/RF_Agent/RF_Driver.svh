class RF_Driver extends uvm_driver #(RF_Sequence_Item);
    `uvm_component_utils(RF_Driver)

    virtual RF_IF rf_vif;
    RF_Sequence_Item item;

    //Constructor
    function new(string name = "RF_Driver", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    //Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)

        if(!(uvm_config_db #(virtual RF_IF)::get(this,"*","rf_vif",rf_vif)))
            `uvm_error("DRIVER_CLASS", "Failed to get rf_vif from config DB!")
    endfunction: build_phase

    //run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Run Phase!", UVM_NONE)

        forever begin                               
         	item = RF_Sequence_Item::type_id::create("item");
            seq_item_port.get_next_item(item);
            drive(item);
            seq_item_port.item_done();
        end
    endtask: run_phase

    task reset_rf(); // synchronous reset
        rf_vif.rf_write_data  <= {64{1'bx}};
        rf_vif.rf_address     <= {4{1'bx}};
        rf_vif.rf_read_en     <= 1'b0;
        rf_vif.rf_write_en    <= 1'b0;
        
        while(! rf_vif.res_n_hmc)
            @(posedge rf_vif.clk_hmc);
    endtask: reset_rf
      
    task drive(RF_Sequence_Item item);
        reset_rf();
        @(posedge rf_vif.clk_hmc);
            rf_vif.rf_write_data  <= item.rf_write_data;
            rf_vif.rf_address     <= item.rf_address;
            rf_vif.rf_read_en     <= item.rf_read_en;
            rf_vif.rf_write_en    <= item.rf_write_en;
        @(posedge rf_vif.clk_hmc);
            rf_vif.rf_read_en     <= 1'b0;
            rf_vif.rf_write_en    <= 1'b0;
     		item.print();
        while(! rf_vif.rf_access_complete)
            @(posedge rf_vif.clk_hmc);
        
        @(posedge rf_vif.clk_hmc);
            rf_vif.rf_write_data  <= {64{1'bx}};
            rf_vif.rf_address     <= {4{1'bx}}; 
    endtask: drive
endclass: RF_Driver
