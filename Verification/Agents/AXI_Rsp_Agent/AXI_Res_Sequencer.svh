class AXI_Res_Sequencer extends uvm_sequencer;
   
   `uvm_component_utils(AXI_Res_Sequencer)
   ////////////////////////////constructor/////////////////////////
    function new(string name="AXI_Res_Sequencer", uvm_component parent = null);
	    super.new(name,parent);
    endfunction: new 

endclass: AXI_Res_Sequencer
