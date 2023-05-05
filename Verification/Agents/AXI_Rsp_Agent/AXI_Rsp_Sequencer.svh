class AXI_Rsp_Sequencer extends uvm_sequencer;
   
  `uvm_component_utils(AXI_Rsp_Sequencer)
  
   ////////////////////////////constructor/////////////////////////
   
  function new(string name="AXI_Rsp_Sequencer", uvm_component parent = null);
	    super.new(name,parent);
    endfunction: new 

endclass: AXI_Rsp_Sequencer
