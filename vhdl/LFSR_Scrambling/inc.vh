// Common definition stuff
`define     HI          1'b1
`define     LO          1'b0
`define     X           1'bx

//***********************************************************
//  U  S  E  R    M  O  D  I  F  I  A  B  L  E  S
//***********************************************************

// The number of refreshses done at power up. 16 by default 
`define power_up_ref_cntr_limit         3       

// The number of refreshes done during normal refresh cycle.
// Set this to be 2048 for "burst"   refreshes, and 
// set this to be 1    for "regular" refreshes
`define auto_ref_cntr_limit             1       

// Refresh Frequency in Hz.
//   For burst  refresh use 33Hz    (30mS)
//   For normal refresh use 66666Hz (15uS)
`define Frefresh                        66666       

// Type of Data Bus
// Unididrectiona:  the top hierachy module SDRAM.V will have seperate 32 bit
//          data buses for reads and writes.  This is useful for embedding the 
//                  core in a larger core.
// Birectional:     the top hierarchy module SDRAM.V will have a biredirectional 32bit
//                  data bus.  This is useful if the SDRAM controller core is to be a 
//                  stand-alone module.
//
// Comment the below for bidirectional bus, and UNcomment for unidirectional
`define    databus_is_unidirectional

// SDRAM DATA BUS TYPE
// 
//
`define      sdram_data_bus_is_unidirectional


// DATA BUS ALIGNING
// With this option enabled (uncomment below) half-word accesses are aligned to lower
// bus DATA[15:0], and byte accesses are aligned to DATA[7:0].  This is ideal when a
// 8 bit micro or host wants to access all of the space of the 16/32 bit SDRAM.

// data bus aligning ON:  (uncomment the below define)
//      a 16 bit write should have the data to the SDRAM controller on D[15:0].
//      a 16 bit read will have the data returned by the SDRAM conroller on D[15:0].
//      a 8  bit write should have the data to the SDRAM controller on D[7:0].
//      a 8  bit read will have the data returned by the SDRAM controller on D[7:0].
//
// data bus aligning OFF: (comment the below define)
//      a 16 bit write should have the data to the SDRAM controller on D[31:16] or
//          D[15:0] depending on the state of A[1] (A[1]=1, on D[31:16], A[1]=0 on 
//          D[15:0].
//      a 16 bit read will have the data returned by the SDRAM controller on D[31:16]
//          or D[15:0], based on the state of A[1].
//      similar thought process for 8 bit write and reads.
//
//`define align_data_bus


// SDRAM clock frequency in Hz.  
//  Set this to whatever the clock rate is
`define Fsystem                          2000000    
//`define Fsystem                         100000000      




// DEFAULT MODE-REGISTER values
// The below is programmed to the mode regsiter at
// powerup
`define default_mode_reg_BURST_LENGHT   3'b000
`define defulat_mode_reg_BURST_TYPE     1'b0
`define default_mode_reg_CAS_LATENCY    3'b010


//***********************************************************
//  D O    N  O  T      M  O  D  I  F  Y
//***********************************************************
// Interval between refreshes in SDRAM clk ticks
`define RC                              `Fsystem/`Frefresh

// Width of the refresh counter. Default 20.  log2(`RC)/log2
// use 8 bits for 15uS interval with 12.5MHz clock
//`define BW                              8
`define BW              20

// The refresh delay counter width
`define     RD          3

// This sets the number of delay cycles right after the refresh command
`define         AUTO_REFRESH_WIDTH  1

// MAin SDRAM controller state machine definition
`define     TS          4
`define     TSn         `TS-1

`define state_idle             `TS'b0001//1
`define state_set_ras          `TS'b0011//3
`define state_ras_dly          `TS'b0010//2
`define state_set_cas          `TS'b0110//6
`define state_cas_latency1     `TS'b0111//7
`define state_cas_latency2     `TS'b0101//5
`define state_write                `TS'b0100//4
`define state_read                 `TS'b1100//12//C
`define state_auto_refresh         `TS'b1101//13//D
`define state_auto_refresh_dly     `TS'b1111//15//F
`define state_precharge        `TS'b1110//14//E
`define state_powerup          `TS'b1010//10//A
`define state_modeset          `TS'b1011//11//B
`define state_delay_Trp        `TS'b0000//0
`define state_delay_Tras1      `TS'b1000//8
`define state_delay_Tras2      `TS'b1001//9

// Fresh timer states
`define   state_count                3'b001
`define   state_halt                 3'b010
`define   state_reset                3'b100



