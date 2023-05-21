class Sys_Sequencer extends uvm_sequencer#(Sys_Sequence_Item);
   
  `uvm_component_utils(Sys_Sequencer)
  
   ////////////////////////////constructor/////////////////////////
   
  function new(string name="Sys_Sequencer", uvm_component parent = null);
	    super.new(name,parent);
    endfunction: new 

endclass: Sys_Sequencer
