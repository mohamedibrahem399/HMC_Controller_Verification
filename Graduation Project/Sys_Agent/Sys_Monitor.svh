class Sys_Monitor extends uvm_monitor;
    `uvm_component_utils(Sys_Monitor)

    virtual Sys_IF sys_if;
    Sys_Sequence_Item sys_item;

    //uvm_analysis_port #(Sys_Sequence_Item ) Sys_Mon_Port;

    //Constructor
    function new(string name = "Sys_Monitor", uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction: new

    //Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build Phase!", UVM_NONE)

        if(!(uvm_config_db #(virtual Sys_IF)::get(this,"*","sys_if",sys_if)))
            `uvm_error("DRIVER_CLASS", "Failed to get sys_if from config DB!")
    endfunction: build_phase

    // Run Phase
    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Run Phase!", UVM_NONE)

        sys_item = Sys_Sequence_Item::type_id::create("sys_item");
        forever begin
            sys_item.clk_user   = sys_if.clk_user;
            sys_item.clk_hmc    = sys_if.clk_hmc;
            sys_item.res_n_user = sys_if.res_n_user;
            sys_item.res_n_hmc  = sys_if.res_n_hmc;
            #5ns;
            //Sys_Mon_Port.write(sys_item);
        end
    endtask :run_phase
endclass :Sys_Monitor