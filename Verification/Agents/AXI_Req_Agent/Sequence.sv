typedef enum bit[1:0] { FIXED, INCR, WRAP } trans_type;
class my_sequence extends uvm_sequence #(transaction);
`uvm_object_utils(my_sequence)
 bit [10:0]  identier;
const int no_of_Wtrans;
trans_type trans ;
function new(string name="my_sequence");
super.new(name);
endfunction
task body();
 repeat(no_of_Wtrans) begin
    identier++;
     trans = transaction::type_id::create("trans");
     start_item(trans);
        if(trans_type == 0)
            assert(trans.randomize() with { trans_type == FIXED; });
        else if(trans_type == 1)
            assert(trans.randomize() with { trans_type == INCR; });
        else if(trans_type == 2)
            assert(trans.randomize() with { trans_type == WRAP; });
        else
            assert(trans.randomize());
     finish_item(trans);
trans.TAG = {1'b0, identier};
 #10;
  end
   endtask
endclass
