class RF_Base_Sequence extends uvm_sequence;
    `uvm_object_utils(RF_Base_Sequence)

    RF_Sequence_Item rf_item;

    function new(string name= "RF_Base_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        rf_item = RF_Sequence_Item::type_id::create("rf_item");
        start_item(rf_item);
        assert(rf_item.randomize());
        finish_item(rf_item);
        //`uvm_do(rf_item)
    endtask: body
endclass: RF_Base_Sequence
//****************************************************************************
class RF_No_Operation_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_No_Operation_Sequence)

    RF_Sequence_Item rf_item;

    function new(string name= "RF_No_Operation_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        rf_item = RF_Sequence_Item::type_id::create("rf_item");
        start_item(rf_item);
        assert(rf_item.randomize()with {
               rf_write_en   == 1'b0; 
               rf_read_en    == 1'b0; 
               rf_address    == 4'h0; 
               rf_write_data == 64'h0;}
              );
        finish_item(rf_item);
    endtask: body
endclass :RF_No_Operation_Sequence
//****************************************************************************
class RF_Disable_scrambler_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Disable_scrambler_Sequence)

    RF_Sequence_Item rf_item;

    function new(string name= "RF_Disable_scrambler_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        rf_item = RF_Sequence_Item::type_id::create("rf_item");
        start_item(rf_item);
        assert(rf_item.randomize()with {
               rf_write_en   == 1'b1; 
               rf_read_en    == 1'b0; 
               rf_address    == 4'h2; 
               rf_write_data == 64'h181000FF0030;}
              );
        finish_item(rf_item);
    endtask: body
endclass :RF_Disable_scrambler_Sequence
//****************************************************************************
class RF_Set_P_RST_N_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Set_P_RST_N_Sequence)

    RF_Sequence_Item rf_item;

    function new(string name= "RF_Set_P_RST_N_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        rf_item = RF_Sequence_Item::type_id::create("rf_item");
        start_item(rf_item);
        assert(rf_item.randomize()with {
               rf_write_en   == 1'b1; 
               rf_read_en    == 1'b0; 
               rf_address    == 4'h2; 
               rf_write_data == 64'h181000FF0031;}
              );
        finish_item(rf_item);
    endtask: body
endclass :RF_Set_P_RST_N_Sequence
//****************************************************************************
class RF_Set_init_cont_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Set_init_cont_Sequence)

    RF_Sequence_Item rf_item;

    function new(string name= "RF_Set_init_cont_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        rf_item = RF_Sequence_Item::type_id::create("rf_item");
        start_item(rf_item);
        assert(rf_item.randomize()with {
               rf_write_en   == 1'b1; 
               rf_read_en    == 1'b0; 
               rf_address    == 4'h2; 
               rf_write_data == 64'h181000FF0033;}
              );
        finish_item(rf_item);
    endtask: body
endclass :RF_Set_init_cont_Sequence
//****************************************************************************
class RF_Read_Control_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_Control_Sequence)

    RF_Sequence_Item item_R_C;

    function new(string name= "RF_Read_Control_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_C = RF_Sequence_Item::type_id::create("item_R_C");
        start_item(item_R_C);
        assert(item_R_C.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==2;});
        finish_item(item_R_C);
    endtask: body
endclass: RF_Read_Control_Sequence
//****************************************************************************
class RF_Read_Status_Init_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_Status_Init_Sequence)

    RF_Sequence_Item item_R_SI;

    function new(string name= "RF_Read_Status_Init_Sequence");
        super.new(name);
      `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_SI = RF_Sequence_Item::type_id::create("item_R_SI");
        start_item(item_R_SI);
        assert(item_R_SI.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==1;});
        finish_item(item_R_SI);
    endtask: body
endclass: RF_Read_Status_Init_Sequence
//****************************************************************************
class RF_Read_Status_General_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_Status_General_Sequence)

    RF_Sequence_Item item_R_SG;

    function new(string name= "RF_Read_Status_General_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_SG = RF_Sequence_Item::type_id::create("item_R_SG");
        start_item(item_R_SG);
        assert(item_R_SG.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==0;});
        finish_item(item_R_SG);
    endtask: body
endclass: RF_Read_Status_General_Sequence
//****************************************************************************
class RF_Read_Sent_P_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_Sent_P_Sequence)

    RF_Sequence_Item item_R_SP;

    function new(string name= "RF_Read_Sent_P_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_SP = RF_Sequence_Item::type_id::create("item_R_SP");
        start_item(item_R_SP);
        assert(item_R_SP.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==3;});
        finish_item(item_R_SP);
    endtask: body
endclass: RF_Read_Sent_P_Sequence
//****************************************************************************
class RF_Read_Sent_nP_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_Sent_nP_Sequence)

    RF_Sequence_Item item_R_SnP;

    function new(string name= "RF_Read_Sent_nP_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_SnP = RF_Sequence_Item::type_id::create("item_R_SnP");
        start_item(item_R_SnP);
        assert(item_R_SnP.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==4;});
        finish_item(item_R_SnP);
    endtask: body
endclass: RF_Read_Sent_nP_Sequence
//****************************************************************************
class RF_Read_Sent_r_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_Sent_r_Sequence)

    RF_Sequence_Item item_R_Sr;

    function new(string name= "RF_Read_Sent_r_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_Sr = RF_Sequence_Item::type_id::create("item_R_Sr");
        start_item(item_R_Sr);
        assert(item_R_Sr.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==5;});
        finish_item(item_R_Sr);
    endtask: body
endclass: RF_Read_Sent_r_Sequence
//****************************************************************************
class RF_Read_poisoned_packets_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_poisoned_packets_Sequence)

    RF_Sequence_Item item_R_PP;

    function new(string name= "RF_Read_poisoned_packets_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_PP = RF_Sequence_Item::type_id::create("item_R_PP");
        start_item(item_R_PP);
        assert(item_R_PP.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==6;});
        finish_item(item_R_PP);
    endtask: body
endclass: RF_Read_poisoned_packets_Sequence
//****************************************************************************
class RF_Read_rcvd_rsp_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_rcvd_rsp_Sequence)

    RF_Sequence_Item item_R_Rrsp;

    function new(string name= "RF_Read_rcvd_rsp_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_Rrsp = RF_Sequence_Item::type_id::create("item_R_Rrsp");
        start_item(item_R_Rrsp);
        assert(item_R_Rrsp.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==7;});
        finish_item(item_R_Rrsp);
    endtask: body
endclass: RF_Read_rcvd_rsp_Sequence
//****************************************************************************
class RF_Read_counter_reset_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_counter_reset_Sequence)

    RF_Sequence_Item item_R_CR;

    function new(string name= "RF_Read_counter_reset_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_CR = RF_Sequence_Item::type_id::create("item_R_CR");
        start_item(item_R_CR);
        assert(item_R_CR.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==8;});
        finish_item(item_R_CR);
    endtask: body
endclass: RF_Read_counter_reset_Sequence
//****************************************************************************
class RF_Read_tx_link_retries_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_tx_link_retries_Sequence)

    RF_Sequence_Item item_R_txlr;

    function new(string name= "RF_Read_tx_link_retries_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_txlr = RF_Sequence_Item::type_id::create("item_R_txlr");
        start_item(item_R_txlr);
        assert(item_R_txlr.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==9;});
        finish_item(item_R_txlr);
    endtask: body
endclass: RF_Read_tx_link_retries_Sequence
//****************************************************************************
class RF_Read_errors_on_rx_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_errors_on_rx_Sequence)

    RF_Sequence_Item item_R_Eor;

    function new(string name= "RF_Read_errors_on_rx_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_Eor = RF_Sequence_Item::type_id::create("item_R_Eor");
        start_item(item_R_Eor);
        assert(item_R_Eor.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==10;});
        finish_item(item_R_Eor);
    endtask: body
endclass: RF_Read_errors_on_rx_Sequence
//****************************************************************************
class RF_Read_run_length_bit_flip_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_run_length_bit_flip_Sequence)

    RF_Sequence_Item item_R_Rlbf;

    function new(string name= "RF_Read_run_length_bit_flip_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_Rlbf = RF_Sequence_Item::type_id::create("item_R_Rlbf");
        start_item(item_R_Rlbf);
        assert(item_R_Rlbf.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==11;});
        finish_item(item_R_Rlbf);
    endtask: body
endclass: RF_Read_run_length_bit_flip_Sequence
//****************************************************************************
class RF_Read_error_abort_not_cleared_Sequence extends RF_Base_Sequence;
    `uvm_object_utils(RF_Read_error_abort_not_cleared_Sequence)

    RF_Sequence_Item item_R_Eanc;

    function new(string name= "RF_Read_error_abort_not_cleared_Sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Inside Constructor!", UVM_NONE)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Inside body task!", UVM_NONE)
        item_R_Eanc = RF_Sequence_Item::type_id::create("item_R_Eanc");
        start_item(item_R_Eanc);
        assert(item_R_Eanc.randomize()with{rf_write_en==0; rf_read_en==1; rf_address==12;});
        finish_item(item_R_Eanc);
    endtask: body
endclass: RF_Read_error_abort_not_cleared_Sequence