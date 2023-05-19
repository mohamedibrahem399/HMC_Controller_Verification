class HMC_Test extends uvm_test;
    `uvm_component_utils(HMC_Test)

    HMC_Environment hmc_env;
    // sequences instantiation

    function new(string name = "HMC_Test", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_HIGH)
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"build_phase", UVM_HIGH)
        
        hmc_env = HMC_Environment::type_id::create("hmc_env", this);
    endfunction: build_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(),"run_phase", UVM_HIGH)

        phase.raise_objection(this);
        repeat(1000) begin
            // sequences creation
            // start sequences on sequenceres
        end
        phase.drop_objection(this);
    endtask :run_phase
endclass :HMC_Test
