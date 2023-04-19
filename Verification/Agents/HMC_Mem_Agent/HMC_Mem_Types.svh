//Power-On and Initialization states in RX
typedef enum {
	RESET, INIT, PRBS, NULL_1, TS1, NULL__2, INITIAL_TRETS, LINK_UP 
} state_t;

// Commandes
typedef enum bit [5:0] {
    /*
    // Flow Commands
    NULL		= 6'b000000, // Null
	PRET		= 6'b000001, // Retry pointer return
	TRET		= 6'b000010, // Token return
	IRTRY		= 6'b000011, // Init retry

    */
    // Response Commands
    RD_RS       = 6'b111000, // READ response
    WR_RS       = 6'b111001, // WRITE response
    ERROR       = 6'b111110  // ERROR response
} CMD_Rsp_t;

typedef enum bit [5:0] {
    // Request Commands
    // WRITE requests
    WR16  = 6'b001000, WR32  = 6'b001001, WR48 = 6'b001010,
    WR64  = 6'b001011, WR80  = 6'b001100, WR96 = 6'b001101,
    WR112 = 6'b001110, WR128 = 6'b001111,
    // ATOMIC Requests
    TWO_ADD8= 6'b010010, ADD16 = 6'b010011,
    // Posted Write Request
    P_WR16  = 6'b011000, P_WR32  = 6'b011001, P_WR48 = 6'b011010,
    P_WR64  = 6'b011011, P_WR80  = 6'b011100, P_WR96 = 6'b011101,
    P_WR112 = 6'b011110, P_WR128 = 6'b011111,
    //POSTED ATOMIC Requests
    P_TWO_ADD8 = 6'b100010, P_ADD16 = 6'b100011,
    //READ Requests
    RD16  = 6'b110000, RD32  = 6'b110001, RD48 = 6'b110010,
    RD64  = 6'b110011, RD80  = 6'b110100, RD96 = 6'b110101,
    RD112 = 6'b110110, RD128 = 6'b110111,
    //Mode Read Requests
    MD_RD = 6'b101000 
} CMD_Req_t;
