class RF_Monitor extends uvm_monitor;
    `uvm_component_utils(RF_Monitor)

    virtual RF_IF rf_vif;
    RF_Sequence_Item item;

    function new(string name = "RF_Monitor", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)
        
        if(!(uvm_config_db #(virtual RF_IF)::get(this, "*", "rf_vif", rf_vif))) begin
            `uvm_error("MONITOR_CLASS", "Failed to get VIF from config DB!")
        end
    endfunction: build_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Run Phase!", UVM_NONE)

        forever begin        
            item = RF_Sequence_Item::type_id::create("item");
            
            @(posedge rf_vif.clk_hmc);
                if(!(rf_vif.rf_read_en) && rf_vif.rf_write_en) begin
                    item.rf_write_data  = rf_vif.rf_write_data;
                    item.rf_write_en    = rf_vif.rf_write_en;
                    item.rf_address     = rf_vif.rf_address;
                    @(posedge rf_vif.clk_hmc);
                    item.rf_access_complete= rf_vif.rf_access_complete;
                end
                
                item.rf_invalid_address = rf_vif.rf_invalid_address;

                if(rf_vif.rf_read_en && !(rf_vif.rf_write_en))begin
                    item.rf_read_en     = rf_vif.rf_read_en;
                    item.rf_address     = rf_vif.rf_address;
                    @(posedge rf_vif.clk_hmc);
                    item.rf_read_data = rf_vif.rf_read_data;
                    item.rf_access_complete= rf_vif.rf_access_complete;
                end
        end
    endtask: run_phase
endclass: RF_Monitor
