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
    MD_RD_RS    = 6'b111010, // MODE READ response
    MD_WR_RS    = 6'b111011, // MODE WRITE response
    ERROR       = 6'b111110  // ERROR response
} CMD_Rsp_t;