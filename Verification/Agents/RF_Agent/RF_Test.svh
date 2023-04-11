class RF_Test #(parameter HMC_RF_WWIDTH= 64, HMC_RF_RWIDTH= 64, HMC_RF_AWIDTH= 4)extends uvm_test;
    //`uvm_component_param_utils(RF_Test#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_RWIDTH))
    `uvm_component_registry(RF_Test#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_RWIDTH), "RF_Test")

    RF_Env env;
    RF_Sequence seq;

    function new(string name = "RF_Test", uvm_component parent);
        super.new(name, parent);
        `uvm_info("TEST_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TEST_CLASS", "Build Phase!", UVM_HIGH)
    
        env = RF_Env#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_AWIDTH)::type_id::create("env", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("TEST_CLASS", "Connect Phase!", UVM_HIGH)
    endfunction: connect_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("TEST_CLASS", "Run Phase!", UVM_HIGH)
    
        phase.raise_objection(this);

        repeat(500) begin
          //seq
          seq = RF_Sequence#(HMC_RF_WWIDTH, HMC_RF_RWIDTH, HMC_RF_AWIDTH)::type_id::create("seq");
          seq.start(env.agnt.sqr); // call body method of sequence
        end

        phase.drop_objection(this);
    
      endtask: run_phase
endclass: RF_Test