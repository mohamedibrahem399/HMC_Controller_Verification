class RF_Test extends uvm_test;
    `uvm_component_utils(RF_Test)

    RF_Env env;
    RF_Read_Control_Sequence seq;

    function new(string name = "RF_Test", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), $sformatf("%m"), UVM_NONE)
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf("%m"), UVM_NONE)
    
        env = RF_Env::type_id::create("env", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), $sformatf("%m"), UVM_NONE)
    endfunction: connect_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), $sformatf("%m"), UVM_NONE)
    
        phase.raise_objection(this);

      forever begin
          //seq
          //seq = RF_Read_Control_Sequence::type_id::create("seq");
          //seq.start(env.agnt.sqr); // call body method of sequence
      end

        phase.drop_objection(this);
    
      endtask: run_phase
endclass: RF_Test
