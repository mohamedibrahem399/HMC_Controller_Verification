class Sys_Monitor extends uvm_monitor;
  `uvm_component_utils(Sys_Monitor)
 Sys_Sequence_Item  item;
  virtual Sys_IF vif;
  uvm_analysis_port #(Sys_Sequence_Item ) Sys_Mon_Port;

  function new ( string name = "Sys_Monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create an instance of the declared analysis port
    Sys_Mon_Port = new("Sys_Mon_Port", this);

    // Get virtual interface handle from the configuration db
    if(!uvm_config_db #(virtual Sys_IF)::get(this, "*", "vif", vif)) begin
      `uvm_error(get_type_name(), "Interface Not Found!")
    end

  endfunction: build_phase

   task run_phase (uvm_phase phase);
     super.run_phase(phase);


     forever begin
       @(posedge vif.clk_user);
       item = Sys_Sequence_Item ::type_id::create("item",this);
       item.clk_user = 1;
       item.res_n_user = vif.res_n_user;
       Sys_Mon_Port.write(item);
       @(negedge vif.clk_user);
       item = Sys_Sequence_Item ::type_id::create("item",this);
       item.clk_user = 0;
       item.res_n_user = vif.res_n_user;
       Sys_Mon_Port.write(item);
     end

     forever begin
       @(posedge vif.clk_hmc);
       item = Sys_Sequence_Item ::type_id::create("item",this);
       item.clk_hmc = 1;
       item.res_n_hmc = vif.res_n_hmc;
       Sys_Mon_Port.write(item);
       @(negedge vif.clk_hmc);
       item = Sys_Sequence_Item ::type_id::create("item",this);
       item.clk_hmc = 0;
       item.res_n_hmc = vif.res_n_hmc;
       Sys_Mon_Port.write(item);
     end    

   endtask:run_phase



endclass: Sys_Monitor
