class Sys_Driver extends uvm_driver #(Sys_Sequence_Item);
    `uvm_component_utils(Sys_Driver)

    virtual Sys_IF sys_if;
    Sys_Sequence_Item sys_item;

    //Constructor
    function new(string name = "Sys_Driver", uvm_component parent);
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

        forever begin
            sys_item = Sys_Sequence_Item::type_id::create("sys_item");
            seq_item_port.get_next_item(sys_item);
            drive(sys_item);
            seq_item_port.item_done();
        end
    endtask :run_phase
    
    task drive(Sys_Sequence_Item sys_item);
        sys_if.clk_user   <= sys_item.clk_user;
        sys_if.clk_hmc    <= sys_item.clk_hmc;
        sys_if.res_n_user <= sys_item.res_n_user;
        sys_if.res_n_hmc  <= sys_item.res_n_hmc;
        fork
            begin
                #0ns;
                sys_if.clk_user <= 1'b1;
                sys_if.clk_hmc  <= 1'b1;
                forever begin
                    #5ns;
                    sys_if.clk_user <= ~sys_if.clk_user;
                    sys_if.clk_hmc  <= ~sys_if.clk_hmc;
                end
            end
            begin
                // active low reset
                #0ns;
                sys_if.res_n_user <= 1'b0;
                sys_if.res_n_hmc  <= 1'b0;
                #30ns;
                sys_if.res_n_user <= 1'b1;
                sys_if.res_n_hmc  <= 1'b1;
            end
        join;
    endtask :drive
endclass :Sys_Driver