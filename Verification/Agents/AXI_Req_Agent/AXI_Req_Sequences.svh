class AXI_Req_Sequence extends uvm_sequence ;//base sequence
  `uvm_object_utils(AXI_Req_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="AXI_Req_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize());
    finish_item(axi_req_item);
  endtask
endclass: AXI_Req_Sequence
//////////////////////////////////////////////
class Read_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Read_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Read_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {CMD==RD16||RD32||RD48||RD64||RD80||RD96||RD112||RD128||MD_RD ;});
    finish_item(axi_req_item);
  endtask
endclass: Read_Sequence
//////////////////////////////////////////////
class Write_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Write_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Write_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with{CMD== WR16||WR32||WR48||WR64||WR80||WR96||WR112||WR128 ;});
    finish_item(axi_req_item);
  endtask
endclass: Write_Sequence
//////////////////////////////////////////////
class Posted_Write_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Write_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Write_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {CMD== P_WR16||P_WR32||P_WR48||P_WR64||P_WR80||P_WR96||P_WR112||P_WR128;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Write_Sequence
//////////////////////////////////////////////
class Atomic_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Atomic_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Atomic_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {CMD==TWO_ADD8||ADD16;});
    finish_item(axi_req_item);
  endtask
endclass: Atomic_Sequence
//////////////////////////////////////////////
class Posted_Atomic_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Atomic_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Atomic_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {CMD==P_TWO_ADD8||P_ADD16;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Atomic_Sequence
//////////////////////////////////////////////
///////////////////////////////////////////////
class Read16_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Read16_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Read16_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==1; CMD==RD16;});
    finish_item(axi_req_item);
  endtask
endclass: Read16_Sequence
//////////////////////////////////////////////////
class Read32_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Read32_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Read32_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==1; CMD==RD32;});
    finish_item(axi_req_item);
  endtask
endclass: Read32_Sequence
/////////////////////////////////////////////
class Read48_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Read48_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Read48_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==1; CMD==RD48;});
    finish_item(axi_req_item);
  endtask
endclass: Read48_Sequence
///////////////////////////////////////////////
class Read64_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Read64_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Read64_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==1; CMD==RD64;});
    finish_item(axi_req_item);
  endtask
endclass: Read64_Sequence
///////////////////////////////////////////////
class Read80_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Read80_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Read80_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==1; CMD==RD80;});
    finish_item(axi_req_item);
  endtask
endclass: Read80_Sequence
////////////////////////////////////////////////
class Read96_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Read96_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Read96_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==1; CMD==RD96;});
    finish_item(axi_req_item);
  endtask
endclass: Read96_Sequence
///////////////////////////////////////////////
class Read112_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Read112_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Read112_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==1; CMD==RD112;});
    finish_item(axi_req_item);
  endtask
endclass: Read112_Sequence
///////////////////////////////////////////////
class Read128_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Read128_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Read128_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==1; CMD==RD128 ;});
    finish_item(axi_req_item);
  endtask
endclass: Read128_Sequence
///////////////////////////////////////////////
class Mode_Read_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Mode_Read_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Mode_Read_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==1; CMD==MD_RD ;});
    finish_item(axi_req_item);
  endtask
endclass: Mode_Read_Sequence
///////////////////////////////////////////////
class Write16_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Write16_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Write16_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==2; CMD==WR16 ;});
    finish_item(axi_req_item);
  endtask
endclass: Write16_Sequence
///////////////////////////////////////////////
class Dual_8byte_add_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Dual_8byte_add_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Dual_8byte_add_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==2; CMD==TWO_ADD8;});
    finish_item(axi_req_item);
  endtask
endclass: Dual_8byte_add_Sequence
///////////////////////////////////////////////
class add_16byte_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(add_16byte_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="add_16byte_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==2; CMD==ADD16;});
    finish_item(axi_req_item);
  endtask
endclass: add_16byte_Sequence
///////////////////////////////////////////////
class Posted_Write16_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Write16_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Write16_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==2; CMD==P_WR16;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Write16_Sequence
///////////////////////////////////////////////
class Posted_Dual_8byte_add_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Dual_8byte_add_Sequence)
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Dual_8byte_add_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==2; CMD==P_TWO_ADD8;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Dual_8byte_add_Sequence
///////////////////////////////////////////////
class Posted_add_16byte_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_add_16byte_Sequence)
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_add_16byte_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==2; CMD==P_ADD16;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_add_16byte_Sequence
///////////////////////////////////////////////
class Write32_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Write32_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Write32_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==3; CMD==WR32 ;});
    finish_item(axi_req_item);
  endtask
endclass: Write32_Sequence
///////////////////////////////////////////////
class Posted_Write32_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Write32_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Write32_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==3; CMD==P_WR32 ;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Write32_Sequence
///////////////////////////////////////////////
class Write48_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Write48_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Write48_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==4; CMD==WR48 ;});
    finish_item(axi_req_item);
  endtask
endclass: Write48_Sequence
///////////////////////////////////////////////
class Posted_Write48_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Write48_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Write48_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==4; CMD==P_WR48 ;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Write48_Sequence
///////////////////////////////////////////////
class Write64_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Write64_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Write64_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==5; CMD==WR64 ;});
    finish_item(axi_req_item);
  endtask
endclass: Write64_Sequence
///////////////////////////////////////////////
class Posted_Write64_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Write64_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Write64_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==5; CMD==P_WR64 ;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Write64_Sequence
///////////////////////////////////////////////
class Write80_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Write80_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Write80_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==6; CMD==WR80 ;});
    finish_item(axi_req_item);
  endtask
endclass: Write80_Sequence
///////////////////////////////////////////////
class Posted_Write80_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Write80_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Write80_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==6; CMD==P_WR80 ;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Write80_Sequence
///////////////////////////////////////////////
class Write96_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Write96_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Write96_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==7; CMD==WR96 ;});
    finish_item(axi_req_item);
  endtask
endclass: Write96_Sequence
///////////////////////////////////////////////
class Posted_Write96_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Write96_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Write96_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==7; CMD==P_WR96 ;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Write96_Sequence
///////////////////////////////////////////////
class Write112_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Write112_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Write112_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==8; CMD==WR112 ;});
    finish_item(axi_req_item);
  endtask
endclass: Write112_Sequence
///////////////////////////////////////////////
class Posted_Write112_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Write112_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Write112_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==8; CMD==P_WR112 ;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Write112_Sequence
///////////////////////////////////////////////
class Write128_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Write128_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Write128_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==9; CMD==WR128;});
    finish_item(axi_req_item);
  endtask
endclass: Write128_Sequence
///////////////////////////////////////////////
class Posted_Write128_Sequence extends AXI_Req_Sequence ;
  `uvm_object_utils(Posted_Write128_Sequence )
  AXI_Req_Sequence_item axi_req_item;

    function new(string name="Posted_Write128_Sequence");
      super.new(name);
    endfunction

  task body();
    axi_req_item = AXI_Req_Sequence_item::type_id::create("axi_req_item");
    start_item(axi_req_item);
    assert(axi_req_item.randomize()with {LNG==9; CMD==P_WR128 ;});
    finish_item(axi_req_item);
  endtask
endclass: Posted_Write128_Sequence


