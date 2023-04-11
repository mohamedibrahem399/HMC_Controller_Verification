`ifndef CMD_DATA_TYPES_RES_SVH
`define CMD_DATA_TYPES_RES_SVH


typedef enum bit [5:0]{
    
    NULL = 6'b000000,
    PRET = 6'b000001,
    TRET = 6'b000010,
    IRTRY = 6'b000011,

    RD_RS = 6'b111000,
    WR_RS = 6'b111001,
    MD_RD_RS = 6'b111010,
    MD_WR_RS =  6'b111011,
    ERROR = 6'b111110
    
}Res_Command;


/*
Command   	LNG
RD_RS       1 + data FLITs
WR_RS 	    1
MD_RD_RS 	2
MD_WR_RS 	1
ERROR 	    1
*/
  

  
                  

`endif 
