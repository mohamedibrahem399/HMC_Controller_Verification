class RF_Test extends uvm_test;
    `uvm_component_utils(RF_Test)

    RF_Env env;
    // Sequences
    Disable_scrambler_Sequence  seq1;
    Set_P_RST_N_Sequence           seq2;
    Set_init_cont_Sequence         seq3;
    Read_Control_Sequence          seq4;
    Read_Status_Init_Sequence      seq5;
    Read_Status_General_Sequence   seq6;


    function new(string name = "RF_Test", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)
    
        env  = RF_Env::type_id::create("env", this);
        seq1 = Disable_scrambler_Sequence::type_id::create("seq1");
        seq2 = Set_P_RST_N_Sequence::type_id::create("seq2");
        seq3 = Set_init_cont_Sequence::type_id::create("seq3");
        seq4 = Read_Control_Sequence::type_id::create("seq4");
        seq5 = Read_Status_Init_Sequence::type_id::create("seq5");
        seq6 = Read_Status_General_Sequence::type_id::create("seq6");
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connect Phase!", UVM_NONE)
    endfunction: connect_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Run Phase!", UVM_NONE)
    
        phase.raise_objection(this);
        repeat(1) begin
                seq1.start(env.agnt.sqr); 
            #10 seq2.start(env.agnt.sqr); 
            #10 seq3.start(env.agnt.sqr); 
            #10 seq4.start(env.agnt.sqr); 
            #10 seq5.start(env.agnt.sqr); 
            #10 seq6.start(env.agnt.sqr); 
        end
        phase.drop_objection(this);
    
    endtask: run_phase
endclass: RF_Test
