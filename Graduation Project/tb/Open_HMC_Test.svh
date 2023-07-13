class Open_HMC_Test extends uvm_test;
    `uvm_component_utils(Open_HMC_Test)

    Open_HMC_Env       opn_hmc_env;
    // Sequences
    Sys_Sequence                      sys_seq1;

    RF_No_Operation_Sequence          rf_seq0;
    RF_Disable_scrambler_Sequence     rf_seq1;
    RF_Set_P_RST_N_Sequence           rf_seq2;
    RF_Set_init_cont_Sequence         rf_seq3;
    RF_Read_Control_Sequence          rf_seq4;
    RF_Read_Status_Init_Sequence      rf_seq5;
    RF_Read_Status_General_Sequence   rf_seq6;

    Write16_Sequence                  axi_req_seq0;
    Write80_Sequence                  axi_req_seq1;

    HMC_Mem_Init_Sequence             hmc_seq0;
    HMC_Mem_Base_Sequence             hmc_seq1;

    function new(string name = "Open_HMC_Test", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)
    
        opn_hmc_env  = Open_HMC_Env::type_id::create("opn_hmc_env", this);

        sys_seq1 = Sys_Sequence::type_id::create("sys_seq1");

        rf_seq0  = RF_No_Operation_Sequence::type_id::create("rf_seq0");
        rf_seq1  = RF_Disable_scrambler_Sequence::type_id::create("rf_seq1");
        rf_seq2  = RF_Set_P_RST_N_Sequence::type_id::create("rf_seq2");
        rf_seq3  = RF_Set_init_cont_Sequence::type_id::create("rf_seq3");

        rf_seq4  = RF_Read_Control_Sequence::type_id::create("rf_seq4");
        rf_seq5  = RF_Read_Status_Init_Sequence::type_id::create("rf_seq5");
        rf_seq6  = RF_Read_Status_General_Sequence::type_id::create("rf_seq6");
        
        axi_req_seq0 = Write16_Sequence::type_id::create("axi_req_seq0");
        axi_req_seq1 = Write80_Sequence::type_id::create("axi_req_seq1");

        hmc_seq0 = HMC_Mem_Init_Sequence::type_id::create("hmc_seq0");
        hmc_seq1 = HMC_Mem_Base_Sequence::type_id::create("hmc_seq1");

    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connect Phase!", UVM_NONE)
    endfunction: connect_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Run Phase!", UVM_NONE)
    
        phase.raise_objection(this);
        fork
            begin
                repeat(1000) begin
                sys_seq1.start(opn_hmc_env.sys_agnt.sys_sqr);
                end
            end
            begin
                #20ns;
                @(posedge opn_hmc_env.sys_agnt.sys_drv.sys_if.clk_hmc);
                    rf_seq1.start(opn_hmc_env.rf_agnt.rf_sqr); 
                
                @(posedge opn_hmc_env.sys_agnt.sys_drv.sys_if.clk_hmc); 
                    rf_seq2.start(opn_hmc_env.rf_agnt.rf_sqr); 
                
                repeat(7) @(posedge opn_hmc_env.sys_agnt.sys_drv.sys_if.clk_hmc);
                    rf_seq3.start(opn_hmc_env.rf_agnt.rf_sqr); 

                repeat(300) begin
                    @(posedge opn_hmc_env.sys_agnt.sys_drv.sys_if.clk_hmc);
                        rf_seq3.start(opn_hmc_env.rf_agnt.rf_sqr); 

                    @(posedge opn_hmc_env.sys_agnt.sys_drv.sys_if.clk_hmc);
                        rf_seq4.start(opn_hmc_env.rf_agnt.rf_sqr); 

                    @(posedge opn_hmc_env.sys_agnt.sys_drv.sys_if.clk_hmc);
                        rf_seq5.start(opn_hmc_env.rf_agnt.rf_sqr); 
                        
                    @(posedge opn_hmc_env.sys_agnt.sys_drv.sys_if.clk_hmc);
                        rf_seq6.start(opn_hmc_env.rf_agnt.rf_sqr); 
                end
            end

            begin
                #7540ns;
                axi_req_seq0.start(opn_hmc_env.axi_req_agnt.axi_req_sqr);
                repeat(5) @(posedge opn_hmc_env.sys_agnt.sys_drv.sys_if.clk_hmc);
                axi_req_seq1.start(opn_hmc_env.axi_req_agnt.axi_req_sqr);
            end

            begin
                hmc_seq0.start(opn_hmc_env.hmc_mem_agnt.hmc_mem_sqr);
                #7540ns;
                hmc_seq1.start(opn_hmc_env.hmc_mem_agnt.hmc_mem_sqr);
            end

        join
        phase.drop_objection(this);
    
    endtask: run_phase
endclass: Open_HMC_Test    