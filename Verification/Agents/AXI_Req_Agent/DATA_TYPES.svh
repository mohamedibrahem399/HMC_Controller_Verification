 

`ifndef CMD_DATA_TYPES_SVH
`define CMD_DATA_TYPES_SVH


typedef enum bit [6:0]{
    
    // Write Request
    
    WR16 = 7'b0001000,   //16-byte WRITE request
    WR32 = 7'b0001001,
    WR48 = 7'b0001010,
    WR64 = 7'b0001011,
    WR80 = 7'b0001100,
    WR96 = 7'b0001101,
    WR112 = 7'b0001110,
    WR128 = 7'b0001111,
    WR256 = 7'b1001111,
    MD_WR = 7'b0010000,  //MODE WRITE request


    // Posted Write Request
    P_WR16 = 7'b0011000,   //16-byte POSTED WRITErequest
    P_WR32 = 7'b0011001,
    P_WR48 = 7'b0011010,
    P_WR64 = 7'b0011011,
    P_WR80 = 7'b0011100,
    P_WR96 = 7'b0011101,
    P_WR112 = 7'b0011110,
    P_WR128 = 7'b0011111,
    P_WR256 = 7'b1011111,

    //READ Requests
    RD16 = 7'b0110000,   //16-byte READ request
    RD32 = 7'b0110001,
    RD48 = 7'b0110010,
    RD64 = 7'b0110011,
    RD80 = 7'b0110100,
    RD96 = 7'b0110101,
    RD112 = 7'b0110110,
    RD128 = 7'b0110111,
    RD256 = 7'b1110111,
    MD_RD = 7'b0101000,  //MODE READ request

    //ARITHMETIC ATOMICS
    Dual_ADD8 = 7'b0010010,   //Dual 8-byte signed add immediate
    ADD16    = 7'b0010011,   //Single 16-byte signed add immediate
    P_2ADD8  = 7'b0100010,   //Posted dual 8-byte signed add immediate
    P_ADD16  = 7'b0100011,   //Posted single 16-byte signed add immediate
    Dual_ADDS8R = 7'b1010010, //Dual 8-byte signed add immediate and return
    ADDS16R = 7'b1010011,    //Single 16-byte signed add immediate and return
    INC8 = 7'b1010000,       //8-byte increment
    P_INC8 = 7'b1010100,     //Posted 8-byte increment

    //BOOLEAN ATOMICS
    XOR16 = 7'b1000000,
    OR16 = 7'b1000001,
    NOR16 = 7'b1000010,
    AND16 = 7'b1000011,
    NAND16 = 7'b1000100,

    //COMPARISON ATOMICS
    CASGT8 = 7'b1100000, //8-byte compare and swap if greater than
    CASGT16 = 7'b1100010, //16-byte compare and swap if greater than
    CASLT8 = 7'b1100001, //8-byte compare and swap if less than
    CASLT16 = 7'b1100011, //16-byte compare and swap less than
    CASEQ8 = 7'b1100100,  //8-byte compare and swap if equal
    CASZERO16 = 7'b1100101, //16-byte compare and swap if zero
    EQ8 = 7'b1101001,  //8-byte equal 
    EQ16 = 7'b1101000, //16-byte equal 

    //BITWISE ATOMICS
    BWR = 7'b0010001, //8-byte bit write 
    P_BWR = 7'b0100001, //Posted 8-byte bit write 
    BWR8R = 7'b1010001, //8-byte bit write with return
    SWAP16 = 7'b1101010 //16-byte swap or ex change
 
             } REQ_Command;


`endif 
