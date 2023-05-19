class HMC_Scoreboard extends uvm_scoreboard;
    `uvm_component_utils(HMC_Scoreboard)
  
    AXI_Req_Sequence_Item axi_req_item;
    AXI_Req_Sequence_Item axi_req_trans[$];
    AXI_Rsp_Sequence_Item axi_rsp_item;
    AXI_Rsp_Sequence_Item axi_rsp_trans[$];
    HMC_Req_Sequence_item hmc_req_item;
    HMC_Req_Sequence_item hmc_req_trans[$];
    HMC_Rsp_Sequence_item hmc_rsp_item;
    HMC_Rsp_Sequence_item hmc_rsp_trans[$];

    `uvm_analysis_imp_decl(_Axi_Req)
    `uvm_analysis_imp_decl(_Axi_Rsp)
    `uvm_analysis_imp_decl(_Hmc_Req)
    `uvm_analysis_imp_decl(_Hmc_Rsp)

    uvm_analysis_imp_Axi_Req #(AXI_Req_Sequence_Item, HMC_Scoreboard) AXI_Req_Imp;
    uvm_analysis_imp_Axi_Rsp #(AXI_Rsp_Sequence_Item, HMC_Scoreboard) AXI_Rsp_Imp;
    uvm_analysis_imp_Hmc_req #(HMC_Req_Sequence_item, HMC_Scoreboard) Hmc_Req_Imp;
    uvm_analysis_imp_Hmc_rsp #(HMC_Rsp_Sequence_item, HMC_Scoreboard) Hmc_Rsp_Imp;

    function new (string name = "HMC_Scoreboard", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(),"Inside Constructor!", UVM_NONE)
    endfunction :new

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"Build Phase!", UVM_NONE)

        AXI_Req_Imp = new("AXI_Req_Imp", this);
        AXI_Rsp_Imp = new("AXI_Rsp_Imp", this);
        Hmc_Req_Imp = new("Hmc_Req_Imp", this);
        Hmc_Rsp_Imp = new("Hmc_Rsp_Imp", this);
    endfunction :build_phase

    function void write_Axi_Req(AXI_Req_Sequence_Item item_axi_req);
        `uvm_info(get_type_name(),"Inside write_Axi_Req function!", UVM_NONE)
        if (item_axi_req == null) 
            `uvm_error(get_type_name(), $psprintf("Axi Req Packet is null"))

        axi_req_trans.push_back(item_axi_req);
    endfunction :write_Axi_Req

    function void write_Axi_Rsp(AXI_Rsp_Sequence_Item item_axi_rsp);
        `uvm_info(get_type_name(),"Inside write_Axi_Rsp function!", UVM_NONE)
        if (item_axi_rsp == null) 
            `uvm_error(get_type_name(), $psprintf("Axi Rsp Packet is null"))

        axi_rsp_trans.push_back(item_axi_rsp);
    endfunction :write_Axi_Rsp

    function void write_Hmc_Req(HMC_Req_Sequence_item item_hmc_req);
        `uvm_info(get_type_name(),"Inside write_Hmc_Req function!", UVM_NONE)
        if (item_hmc_req == null) 
            `uvm_error(get_type_name(), $psprintf("Hmc Req Packet is null"))

        hmc_req_trans.push_back(item_hmc_req);
    endfunction :write_Hmc_Req
 
    function void write_Hmc_Rsp(HMC_Rsp_Sequence_item item_hmc_rsp);
        `uvm_info(get_type_name(),"Inside write_Hmc_Rsp function!", UVM_NONE)
        if (item_hmc_rsp == null) 
            `uvm_error(get_type_name(), $psprintf("Hmc Rsp Packet is null"))

        hmc_rsp_trans.push_back(item_hmc_rsp);
    endfunction :write_Hmc_Rsp

    task run_phase (uvm_phase phase);
        `uvm_info(get_type_name(),"Inside Run Phase!", UVM_NONE)
        super.run_phase(phase);

        forever begin
            fork
                begin
                    AXI_Req_Sequence_Item current_axi_req_trans;
                    HMC_Req_Sequence_item current_hmc_req_trans;
                    wait((axi_req_trans.size != 0) && (hmc_req_trans.size != 0));
                    current_axi_req_trans = axi_req_trans.pop_front();
                    current_hmc_req_trans = hmc_req_trans.pop_front();
                    Compare_Req (current_axi_req_trans, current_hmc_req_trans);
                end
                begin
                    AXI_Rsp_Sequence_Item current_axi_rsp_trans;
                    HMC_Rsp_Sequence_item current_hmc_rsp_trans;
                    wait((axi_rsp_trans.size != 0) && (hmc_rsp_trans.size != 0));
                    current_axi_rsp_trans = axi_rsp_trans.pop_front();
                    current_hmc_rsp_trans = hmc_rsp_trans.pop_front();
                    Compare_Rsp (current_axi_rsp_trans, current_hmc_rsp_trans);
                end
            join
        end
    endtask :run_phase

    task Compare_Req (AXI_Req_Sequence_Item current_axi_req_trans, HMC_Req_Sequence_item current_hmc_req_trans);
        /* 
            CUB          // Cube ID               
            ADRS         // Address           
            TAG          // Tag              
            DLN          // Duplicate length   
            LNG          // Packet length        
            CMD          // Command            
            data.size()  // data in the req packet
        */
        if(current_axi_req_trans.CMD != current_hmc_req_trans.CMD) begin
            `uvm_error("CMD_Req_Compare", $sformatf("FAILED @%5t: Axi_Req_CMD = %6b  & Hmc_Req_CMD = %6b", $time, current_axi_req_trans.CMD, current_hmc_req_trans.CMD))
        end
        else begin
            `uvm_info ("CMD_Req_Compare", $sformatf("PASSED @%5t: Axi_Req_CMD = %6b  & Hmc_Req_CMD = %6b", $time, current_axi_req_trans.CMD, current_hmc_req_trans.CMD), UVM_LOW)
        end

        if((current_axi_req_trans.LNG != current_hmc_req_trans.LNG) && (current_axi_req_trans.DLN != current_hmc_req_trans.DLN)) begin
            `uvm_error("LNG_Req_Compare", $sformatf("FAILED @%5t: Axi_Req_LNG = %4b  & Hmc_Req_LNG = %4b", $time, current_axi_req_trans.LNG, current_hmc_req_trans.LNG))
            `uvm_error("DLN_Req_Compare", $sformatf("FAILED @%5t: Axi_Req_DLN = %4b  & Hmc_Req_DLN = %4b", $time, current_axi_req_trans.DLN, current_hmc_req_trans.DLN))
        end
        else begin
            `uvm_info ("LNG_Req_Compare", $sformatf("PASSED @%5t: Axi_Req_LNG = %4b  & Hmc_Req_LNG = %4b", $time, current_axi_req_trans.LNG, current_hmc_req_trans.LNG), UVM_LOW)
            `uvm_info ("DLN_Req_Compare", $sformatf("PASSED @%5t: Axi_Req_DLN = %4b  & Hmc_Req_DLN = %4b", $time, current_axi_req_trans.DLN, current_hmc_req_trans.DLN), UVM_LOW)
        end

        if(current_axi_req_trans.TAG != current_hmc_req_trans.TAG)begin
            `uvm_error("TAG_Req_Compare", $sformatf("FAILED @%5t: Axi_Req_TAG = %9b  & Hmc_Req_TAG = %9b", $time, current_axi_req_trans.TAG, current_hmc_req_trans.TAG))
        end
        else begin
            `uvm_info ("TAG_Req_Compare", $sformatf("PASSED @%5t: Axi_Req_TAG = %9b  & Hmc_Req_TAG = %9b", $time, current_axi_req_trans.TAG, current_hmc_req_trans.TAG), UVM_LOW)
        end

        if(current_axi_req_trans.ADRS != current_hmc_req_trans.ADRS)begin
            `uvm_error("ADRS_Req_Compare", $sformatf("FAILED @%5t: Axi_Req_ADRS = %34b  & Hmc_Req_ADRS = %34b", $time, current_axi_req_trans.ADRS, current_hmc_req_trans.ADRS))
        end
        else begin
            `uvm_info ("ADRS_Req_Compare", $sformatf("PASSED @%5t: Axi_Req_ADRS = %34b  & Hmc_Req_ADRS = %34b", $time, current_axi_req_trans.ADRS, current_hmc_req_trans.ADRS), UVM_LOW)
        end      
        
        if(current_axi_req_trans.CUB != current_hmc_req_trans.CUB)begin
            `uvm_error("CUB_Req_Compare", $sformatf("FAILED @%5t: Axi_Req_CUB = %3b  & Hmc_Req_CUB = %3b", $time, current_axi_req_trans.ADRS, current_hmc_req_trans.ADRS))
        end
        else begin
            `uvm_info ("CUB_Req_Compare", $sformatf("PASSED @%5t: Axi_Req_CUB = %3b  & Hmc_Req_CUB = %3b", $time, current_axi_req_trans.ADRS, current_hmc_req_trans.ADRS), UVM_LOW)
        end 

        if(current_axi_req_trans.data.size() != current_hmc_req_trans.data.size())begin
            `uvm_error("Data_Size_Req_Compare", $sformatf("FAILED @%5t: Axi_Req_Data_Size = %4b  & Hmc_Req_Data_Size = %4b", $time, current_axi_req_trans.data.size(), current_hmc_req_trans.data.size()))
        end
        else begin
            `uvm_info ("Data_Size_Req_Compare", $sformatf("PASSED @%5t: Axi_Req_Data_Size = %4b  & Hmc_Req_Data_Size = %4b", $time, current_axi_req_trans.data.size(), current_hmc_req_trans.data.size()), UVM_LOW)
        end 
    endtask :Compare_Req

    task Compare_Rsp (AXI_Rsp_Sequence_Item current_axi_rsp_trans, HMC_Rsp_Sequence_item current_hmc_rsp_trans);
        /*       
            TAG          // Tag              
            DLN          // Duplicate length   
            LNG          // Packet length        
            CMD          // Command            
            data.size()  // data in the rsp packet
        */
        if(current_axi_rsp_trans.TAG != current_hmc_rsp_trans.TAG)begin
            `uvm_error("TAG_Rsp_Compare", $sformatf("FAILED @%5t: Axi_Rsp_TAG = %9b  & Hmc_Rsp_TAG = %9b", $time, current_axi_rsp_trans.TAG, current_hmc_rsp_trans.TAG))
        end
        else begin
            `uvm_info ("TAG_Rsp_Compare", $sformatf("PASSED @%5t: Axi_Rsp_TAG = %9b  & Hmc_Rsp_TAG = %9b", $time, current_axi_rsp_trans.TAG, current_hmc_rsp_trans.TAG), UVM_LOW)
        end

        if((current_axi_rsp_trans.LNG != current_hmc_rsp_trans.LNG) && (current_axi_rsp_trans.DLN != current_hmc_rsp_trans.DLN)) begin
            `uvm_error("LNG_Rsp_Compare", $sformatf("FAILED @%5t: Axi_Rsp_LNG = %4b  & Hmc_Rsp_LNG = %4b", $time, current_axi_rsp_trans.LNG, current_hmc_rsp_trans.LNG))
            `uvm_error("DLN_Rsp_Compare", $sformatf("FAILED @%5t: Axi_Rsp_DLN = %4b  & Hmc_Rsp_DLN = %4b", $time, current_axi_rsp_trans.DLN, current_hmc_rsp_trans.DLN))
        end
        else begin
            `uvm_info ("LNG_Rsp_Compare", $sformatf("PASSED @%5t: Axi_Rsp_LNG = %4b  & Hmc_Rsp_LNG = %4b", $time, current_axi_rsp_trans.LNG, current_hmc_rsp_trans.LNG), UVM_LOW)
            `uvm_info ("DLN_Rsp_Compare", $sformatf("PASSED @%5t: Axi_Rsp_DLN = %4b  & Hmc_Rsp_DLN = %4b", $time, current_axi_rsp_trans.DLN, current_hmc_rsp_trans.DLN), UVM_LOW)
        end

        if(current_axi_rsp_trans.CMD != current_hmc_rsp_trans.CMD) begin
            `uvm_error("CMD_Rsp_Compare", $sformatf("FAILED @%5t: Axi_Rsp_CMD = %6b  & Hmc_Rsp_CMD = %6b", $time, current_axi_rsp_trans.CMD, current_hmc_rsp_trans.CMD))
        end
        else begin
            `uvm_info ("CMD_Rsp_Compare", $sformatf("PASSED @%5t: Axi_Rsp_CMD = %6b  & Hmc_Rsp_CMD = %6b", $time, current_axi_rsp_trans.CMD, current_hmc_rsp_trans.CMD), UVM_LOW)
        end

        if(current_axi_rsp_trans.data.size() != current_hmc_rsp_trans.data.size())begin
            `uvm_error("Data_Size_Rsp_Compare", $sformatf("FAILED @%5t: Axi_Rsp_Data_Size = %4b  & Hmc_Rsp_Data_Size = %4b", $time, current_axi_rsp_trans.data.size(), current_hmc_rsp_trans.data.size()))
        end
        else begin
            `uvm_info ("Data_Size_Rsp_Compare", $sformatf("PASSED @%5t: Axi_Rsp_Data_Size = %4b  & Hmc_Rsp_Data_Size = %4b", $time, current_axi_rsp_trans.data.size(), current_hmc_rsp_trans.data.size()), UVM_LOW)
        end 
    endtask :Compare_Rsp
endclass: HMC_Scoreboard
