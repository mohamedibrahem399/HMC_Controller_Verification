class RF_Monitor #(parameter HMC_RF_WWIDTH= 64, parameter HMC_RF_RWIDTH= 64, parameter HMC_RF_AWIDTH= 4) extends uvm_monitor;
    `uvm_component_param_utils(RF_Monitor#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_RWIDTH))

    virtual RF_IF #(parameter HMC_RF_WWIDTH= 64, parameter HMC_RF_RWIDTH= 64, parameter HMC_RF_AWIDTH= 4)vif;
    RF_Sequence_Item item;

    uvm_analysis_port #(RF_Sequence_Item) monitor_port;

    function new(string name = "RF_Monitor", uvm_component parent);
        super.new(name, parent);
        `uvm_info("MONITOR_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("MONITOR_CLASS", "Build Phase!", UVM_HIGH)
        
        monitor_port = new("monitor_port", this);
        
        if(!(uvm_config_db #(virtual RF_Monitor)::get(this, "*", "vif", vif))) begin
          `uvm_error("MONITOR_CLASS", "Failed to get VIF from config DB!")
        end
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("MONITOR_CLASS", "Connect Phase!", UVM_HIGH)
    endfunction: connect_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("MONITOR_CLASS", "Inside Run Phase!", UVM_HIGH)

        forever begin
            item = RF_Sequence_Item::type_id::create("item");
            
            @(posedge vif.clk_hmc);
                if(!(vif.rf_read_en) && vif.rf_write_en) begin
                    item.rf_write_data  = vif.rf_write_data;
                    item.rf_write_en    = vif.rf_write_en;
                    item.rf_address     = vif.rf_address;
                    @(posedge vif.clk_hmc);
                    item.rf_access_complete= vif.rf_access_complete;
                end
                
                item.rf_invalid_address = vif.rf_invalid_address;

                if(vif.rf_read_en && !(vif.rf_write_en))begin
                    item.rf_read_en     = vif.rf_read_en;
                    item.rf_address     = vif.rf_address;
                    @(posedge vif.clk_hmc);
                    item.rf_read_data = vif.rf_read_data;
                    item.rf_access_complete= vif.rf_access_complete;
                end
           monitor_port.write(item);
        end
        
    endtask: run_phase
endclass: RF_Monitor
