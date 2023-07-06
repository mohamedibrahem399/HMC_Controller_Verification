
class AXI_Req_Rand_Test extends AXI_Req_Base_Test;
  `uvm_component_utils(AXI_Req_Rand_Test)

  Write16_Sequence  w16_seq;
  Read16_Sequence   read16_seq;
  Write32_Sequence  w32_seq;
  Read32_Sequence   read32_seq;
  Write48_Sequence  w48_seq;
  Read48_Sequence   read48_seq;
  Write64_Sequence  w64_seq;
  Read64_Sequence   read64_seq;
  
  function new (string name="AXI_Req_Rand_Test", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
       w16_seq=Write16_Sequence::type_id::create("w16_seq");
    read16_seq=Read16_Sequence::type_id::create("read16_seq");
     w32_seq=Write32_Sequence::type_id::create("w32_seq");
    read32_seq=Read32_Sequence::type_id::create("read32_seq");
	w48_seq=Write48_Sequence::type_id::create("w48_seq");
    read48_seq=Read48_Sequence::type_id::create("read48_seq");
     w64_seq=Write64_Sequence::type_id::create("w64_seq");
    read64_seq=Read64_Sequence::type_id::create("read64_seq");

	`uvm_info("AXI_Req_Rand_Test", "build_phase", UVM_NONE) 
  endfunction : build_phase

  task run_phase(uvm_phase phase);
   //noofrepetition=1;
    super.run_phase(phase);
	phase.raise_objection(this);
     #50ns;
   
	    repeat(5)begin
		w16_seq.start(axi_env.axi_req_agnt.axi_req_sqr);
	   #200 read16_seq.start(axi_env.axi_req_agnt.axi_req_sqr); 
		#200 w32_seq.start(axi_env.axi_req_agnt.axi_req_sqr);
		#200 read32_seq.start(axi_env.axi_req_agnt.axi_req_sqr);
		#200 w48_seq.start(axi_env.axi_req_agnt.axi_req_sqr);
		#200 read48_seq.start(axi_env.axi_req_agnt.axi_req_sqr);
		#200 w64_seq.start(axi_env.axi_req_agnt.axi_req_sqr);
		#200 read64_seq.start(axi_env.axi_req_agnt.axi_req_sqr);

		 
	    end
		

    phase.drop_objection(this);
  endtask : run_phase


endclass : AXI_Req_Rand_Test
