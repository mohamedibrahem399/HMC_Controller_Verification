class RF_Test extends uvm_test;
    `uvm_component_utils(RF_Test)

    RF_Env env;
    RF_Sequence seq;

    function new(string name = "RF_Test", uvm_component parent);
        super.new(name, parent);
        `uvm_info("TEST_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TEST_CLASS", "Build Phase!", UVM_HIGH)
    
        env = RF_Env::type_id::create("env", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("TEST_CLASS", "Connect Phase!", UVM_HIGH)
    endfunction: connect_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("TEST_CLASS", "Run Phase!", UVM_HIGH)
    
        phase.raise_objection(this);

        repeat(100) begin
          //seq
          seq = RF_Sequence::type_id::create("seq");
          seq.start(env.agnt.seqr);
        end

        phase.drop_objection(this);
    
      endtask: run_phase
endclass: RF_Test