class RF_Monitor extends uvm_monitor;
    `uvm_component_utils(RF_Monitor)

    virtual RF_IF     rf_if;
    RF_Sequence_Item  rf_item;

    function new(string name = "RF_Monitor", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)
        
        if(!(uvm_config_db #(virtual RF_IF)::get(this, "*", "rf_if", rf_if))) begin
            `uvm_error("MONITOR_CLASS", "Failed to get VIF from config DB!")
        end
    endfunction: build_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Run Phase!", UVM_NONE)

        forever begin        
            rf_item = RF_Sequence_Item::type_id::create("rf_item");
            
            @(posedge rf_if.clk_hmc);
                if(!(rf_if.rf_read_en) && rf_if.rf_write_en) begin
                    rf_item.rf_write_data  = rf_if.rf_write_data;
                    rf_item.rf_write_en    = rf_if.rf_write_en;
                    rf_item.rf_address     = rf_if.rf_address;

                    if(rf_item.rf_address == 4'h2 && rf_item.rf_write_en == 1'b1) begin
                        `uvm_info ("Control Write",$sformatf("\n>>> Control Register = %0h \n      p_rst_n = %0h \n      hmc_init_cont_set = %0h \n      set_hmc_sleep = %0h \n      warm_reset = %0h \n      scrambler_disable = %0h \n      run_length_enable = %0h \n      rx_token_count = %0h \n      irtry_received_threshold = %0h \n      irtry_to_send = %0h \n", 
                                    rf_item.rf_write_data, rf_item.rf_write_data[0], rf_item.rf_write_data[1], rf_item.rf_write_data[2], rf_item.rf_write_data[3], rf_item.rf_write_data[4], rf_item.rf_write_data[5], rf_item.rf_write_data[23:16], rf_item.rf_write_data[36:32], rf_item.rf_write_data[44:40]), UVM_NONE);
                    end

                    @(posedge rf_if.clk_hmc);
                    rf_item.rf_access_complete= rf_if.rf_access_complete;
                end
                
                rf_item.rf_invalid_address = rf_if.rf_invalid_address;

                if(rf_if.rf_read_en && !(rf_if.rf_write_en))begin
                    rf_item.rf_read_en     = rf_if.rf_read_en;
                    rf_item.rf_address     = rf_if.rf_address;
                    @(posedge rf_if.clk_hmc);
                    rf_item.rf_read_data = rf_if.rf_read_data;
                    if (rf_item.rf_address == 4'h0 && rf_item.rf_read_en == 1'b1) begin
                        `uvm_info ("Status General",$sformatf("\n>>> Status General Register = %0h \n      link_up = %0h \n      link_training = %0h \n      sleep_mode = %0h \n      FERR_N = %0h \n      lanes_reversed = %0h \n      phy_tx_ready = %0h \n      phy_rx_ready = %0h \n      hmc_tokens_remaining = %0h \n      rx_tokens_remaining = %0h \n      lane _polarity _reversed = %0h \n", 
                                rf_item.rf_read_data, rf_item.rf_read_data[0], rf_item.rf_read_data[1], rf_item.rf_read_data[2], rf_item.rf_read_data[3], rf_item.rf_read_data[4], rf_item.rf_read_data[8], rf_item.rf_read_data[9], rf_item.rf_read_data[25:16], rf_item.rf_read_data[41:32], rf_item.rf_read_data[63:48]), UVM_NONE);
                    end
                    else if (rf_item.rf_address == 4'h1&& rf_item.rf_read_en == 1'b1) begin
                        `uvm_info ("Status Init",$sformatf("\n>>> Status Init Register = %0h \n      lane_descramblers_locked = %0h \n      descrambler_part_aligned = %0h \n      descrambler_aligned = %0h \n      all_descramblers_aligned = %0h \n      status_init_rx_init_state = %0h \n      status_init_tx_init_state = %0h \n", 
                                rf_item.rf_read_data, rf_item.rf_read_data[15:0], rf_item.rf_read_data[31:16], rf_item.rf_read_data[47:32], rf_item.rf_read_data[48], rf_item.rf_read_data[51:49], rf_item.rf_read_data[53:52]), UVM_NONE);
                    end
                    else if(rf_item.rf_address == 4'h2 && rf_item.rf_read_en == 1'b1) begin
                        `uvm_info ("Control Read",$sformatf("\n>>> Control Register = %0h \n      p_rst_n = %0h \n      hmc_init_cont_set = %0h \n      set_hmc_sleep = %0h \n      warm_reset = %0h \n      scrambler_disable = %0h \n      run_length_enable = %0h \n      rx_token_count = %0h \n      irtry_received_threshold = %0h \n      irtry_to_send = %0h \n", 
                                    rf_item.rf_read_data, rf_item.rf_read_data[0], rf_item.rf_read_data[1], rf_item.rf_read_data[2], rf_item.rf_read_data[3], rf_item.rf_read_data[4], rf_item.rf_read_data[5], rf_item.rf_read_data[23:16], rf_item.rf_read_data[36:32], rf_item.rf_read_data[44:40]), UVM_NONE);
                    end
                    else if (rf_item.rf_address == 4'h3&& rf_item.rf_read_en == 1'b1) begin
                        `uvm_info ("sent_p",$sformatf("\n>>> sent_p Counter = %0h", rf_item.rf_read_data), UVM_NONE)
                    end
                    else if (rf_item.rf_address == 4'h4&& rf_item.rf_read_en == 1'b1) begin
                        `uvm_info ("sent_np",$sformatf("\n>>> sent_np Counter = %0h", rf_item.rf_read_data), UVM_NONE)
                    end
                    else if (rf_item.rf_address == 4'h5&& rf_item.rf_read_en == 1'b1) begin
                        `uvm_info ("sent_r",$sformatf("\n>>> sent_r Counter = %0h", rf_item.rf_read_data), UVM_NONE)
                    end
                    else if (rf_item.rf_address == 4'h6&& rf_item.rf_read_en == 1'b1) begin
                        `uvm_info ("poisoned_packets",$sformatf("\n>>> poisoned_packets Counter = %0h", rf_item.rf_read_data), UVM_NONE)
                    end
                    else if (rf_item.rf_address == 4'h7&& rf_item.rf_read_en == 1'b1) begin
                        `uvm_info ("rcvd_rsp",$sformatf("\n>>> rcvd_rsp Counter = %0h", rf_item.rf_read_data), UVM_NONE)
                    end
                    else if (rf_item.rf_address == 4'h8&& rf_item.rf_read_en == 1'b1) begin
                        `uvm_info ("counter_reset",$sformatf("\n>>> counter_reset Counter = %0h", rf_item.rf_read_data), UVM_NONE)
                    end
                    rf_item.rf_access_complete= rf_if.rf_access_complete;
                end
        end
    endtask: run_phase
endclass: RF_Monitor