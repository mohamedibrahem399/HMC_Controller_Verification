class RF_Driver #(parameter HMC_RF_WWIDTH= 64, HMC_RF_RWIDTH= 64, HMC_RF_AWIDTH= 4) extends uvm_driver #(RF_Sequence_Item);
    `uvm_component_param_utils(RF_Driver#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_RWIDTH))

    virtual RF_IF #(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_AWIDTH)vif;
    RF_Sequence_Item item;

    //Constructor
    function new(string name = "RF_Driver", uvm_component parent);
        super.new(name, parent);
        `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new

    //Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)

        if(!(uvm_config_db #(virtual RF_IF)::get(this,"*","vif",vif)))
            `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!")
    endfunction: build_phase

    //run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("DRIVER_CLASS", "Inside Run Phase!", UVM_HIGH)

        reset_rf();
        forever begin
            if(!vif.res_n_hmc)
                reset_rf();
         	item = RF_Sequence_Item #(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_AWIDTH)::type_id::create("item", item);
            seq_item_port.get_next_item(item);
            drive(item);
            seq_item_port.item_done();
        end
    endtask: run_phase


    task reset_rf(); // synchronous reset
        vif.rf_write_data  <= {HMC_RF_WWIDTH{1'b0}};
        vif.rf_address     <= {HMC_RF_AWIDTH{1'b0}};
        vif.rf_read_en     <= 1'b0;
        vif.rf_write_en    <= 1'b0;
        
        while(! vif.res_n_hmc)
            @(posedge vif.clk_hmc);
    endtask: reset_rf


    task drive(RF_Sequence_Item item);
        @(posedge vif.clk_hmc);
            vif.rf_write_data  <= item.rf_write_data;
            vif.rf_address     <= item.rf_address;
            vif.rf_read_en     <= item.rf_read_en;
            vif.rf_write_en    <= item.rf_write_en;
        @(posedge vif.clk_hmc);
            vif.rf_read_en     <= 1'b0;
            vif.rf_write_en    <= 1'b0;
        
        while(! vif.rf_access_complete)
            @(posedge vif.clk_hmc);
        
        @(posedge vif.clk_hmc);
            vif.rf_write_data  <= {HMC_RF_WWIDTH{1'b0}};
            vif.rf_address     <= {HMC_RF_AWIDTH{1'b0}};
    endtask: drive
endclass: RF_Driver