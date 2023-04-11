class RF_Scoreboard extends uvm_scoreboard;
    `uvm_component_utils(RF_Scoreboard)
  
    uvm_analysis_imp #(RF_Sequence_Item, RF_Scoreboard) scoreboard_port;
  
    RF_Sequence_Item transactions[$];

    function new(string name = "RF_Scoreboard", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SCB_CLASS", "Inside Constructor!", UVM_HIGH)
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SCB_CLASS", "Build Phase!", UVM_HIGH)
       
        scoreboard_port = new("scoreboard_port", this);
        
    endfunction: build_phase

    function void write(RF_Sequence_Item item);
        transactions.push_back(item);
    endfunction: write

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("SCB_CLASS", "Run Phase!", UVM_HIGH)
       
        forever begin
        /*
        // get the packet
        // generate expected value
        // compare it with actual value
        // score the transactions accordingly
        */
        end
    endtask: run_phase
endclass: RF_Scoreboard