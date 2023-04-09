  class AXI_Req_Test extends uvm_test;
    `uvm_component_utils(AXI_Req_Test);
    AXI_Req_Env AXI_env;
    AXI_Req_Seq AXI_seq;
    
    function new(string name = "AXI_Req_Test", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      AXI_env = env::type_id::create("AXI_env", this);
    endfunction
    
    
    // We should implement Run Phase and Connect Phase here
    
    
  endclass:AXI_Req_Test
