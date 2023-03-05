class RA_sequencer extends uvm_sequencer#(RA_seq_item);

  `uvm_component_utils(RA_sequencer) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass
