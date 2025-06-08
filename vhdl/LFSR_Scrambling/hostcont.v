`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2025 18:12:36
// Design Name: 
// Module Name: hostcont
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "inc.vh"

module hostcont ( 
                    // system connections
                    sys_rst_l,            
                    sys_clk,

                    // microprocessor side connections
                    mp_addx,
                    mp_data_in,
                   DSdata_from_mem,
                    mp_rd_l,
                    mp_wr_l,
                    mp_cs_l,
                    sdram_mode_set_l,
                    sdram_busy_l,
                    mp_size,

                    // SDRAM side connections
                    sd_addx,
                     Sdata_to_mem,
                    sd_data_in,
                    sd_ba,
                    
                   
                    


                    // SDRAMCNT side
                    sd_addx10_mux,
                    sd_addx_mux,
                    sd_rd_ena,
                    do_read,
                    do_write,
                    doing_refresh,
                    do_modeset,
                    modereg_cas_latency,
                    modereg_burst_length,
                    mp_data_mux,
                    decoded_dqm,
                    do_write_ack,
                    do_read_ack,
                    do_modeset_ack,
                    pwrup,
                    next_state,


                    // debug
//                    rd_wr_clk
                    reg_mp_data_mux,
                    reg_mp_addx,
                    reg_sd_data,
                    reg_modeset

             );


// ****************************************
//
//   I/O  DEFINITION
//
// ****************************************

// system connections
input           sys_rst_l;          // asynch active low reset
input           sys_clk;            // clock source to the SDRAM

// microprocessor side connections
input   [22:0]  mp_addx;         // ABW bits for the addx
input   [31:0]  mp_data_in;      // DBW bits of data bus input (see INC.H)
output  [31:0] DSdata_from_mem;
input           mp_rd_l;            // micro bus read , active low
input           mp_wr_l;            // micro bus write, active low
input           mp_cs_l;
input           sdram_mode_set_l;   // acive low request for SDRAM mode set
output          sdram_busy_l;       // active low busy output
input   [1:0]   mp_size;

// SDRAM side connections
output  [10:0]  sd_addx;            // 11 bits of muxed SDRAM addx
input   [32:0]  sd_data_in;
output  [32:0]  Sdata_to_mem;
output  [1:0]   sd_ba;              // bank select output to the SDRAM
input           pwrup;






// SDRAMCNT side
input   [1:0]   sd_addx10_mux;
input   [1:0]   sd_addx_mux;
input           sd_rd_ena;
output          do_write;
output          do_read;
input           doing_refresh;
output          do_modeset;
output  [2:0]   modereg_cas_latency;
output  [2:0]   modereg_burst_length;
input           mp_data_mux;
output  [3:0]   decoded_dqm;        // this is the decoded DQM according to the size. Used during writes
input           do_write_ack;       // acknowledge signal from sdramcont state machine
                                    // saying that it is now ok to clear 'do_write' signal
input           do_read_ack;        // acknowledge signal from sdramcont state machine
                                    // saying that is is now ok to clear 'do_read' signal
input           do_modeset_ack;
input wire [3:0]next_state;

//debug
//output          rd_wr_clk;
output  [31:0]  reg_mp_data_mux;
output  [22:0]  reg_mp_addx;
output  [32:0]  reg_sd_data;
output  [10:0]  reg_modeset;

// ****************************************
//
// Memory Elements 
//
// ****************************************
//
wire    [22:0]  reg_mp_addx;
reg     [31:0]  reg_mp_data;
reg     [32:0]  reg_sd_data;
reg     [3:0]   decoded_dqm;
reg     [10:0]  reg_modeset; 
reg     [10:0]  sd_addx;
reg             do_read;
reg             do_write;
reg     [2:0]   do_state;
reg             do_modeset;
reg     [1:0]   sd_ba;
reg             busy_a_ena;
reg    do_write_flag;

wire  [32:0]  sd_data;
wire    [32:0]  sd_data_buff;
wire    [31:0]  reg_mp_data_mux;
reg     [31:0]  mp_data_out;
wire            busy_a;
wire            mp_data_ena;
wire            do_read_clk;
wire            do_read_rst_clk;
wire            do_write_clk;
wire            do_modeset_clk;
wire            do_modeset_rst_clk;
wire            clock_xx;
wire            modereg_ena;
wire            read_busy;
wire            write_busy;
wire            refresh_busy;
wire            modeset_busy;
wire            do_write_rst;
wire            do_read_rst;
wire            do_modeset_rst;

///////////////////////////////////////////
// Memory array: 32 entries, each 71 bits (sw, Si0, Si1, Ci0, Ci1)
    reg [70:0] memory [31:0];
    reg [70:0] mem;                 // Selected memory entry
    reg [31:0] Si0, Si1;            // Scrambling vectors
    reg [2:0] Ci0, Ci1;             // Age counters
    reg [2:0] Ci1_out;
    reg [2:0] Ci0_out;
    reg vector_refresh;             // Indicates vector refresh
    reg sw_out_age;                 // Updated youth flag
    wire [31:0] new_vector;          // New vector to refresh
    reg new_sw;                     // connected to new vector dmux
    reg sw_out;
    //reg do_read_1;
     parameter ROWS = 6;   // Number of rows
    parameter COLS = 6;   // Number of columns
  //  reg mem_sw_flag[0:3][0:ROWS-1][0:COLS-1];
    wire sw_in_1;
    
    
    

            
//assigning read sigal(active low)from micro p to enable the data
assign mp_data_ena  = ~mp_rd_l;   
//reg mode set is 11 bit signal                          
assign modereg_cas_latency  =  reg_modeset[6:4];
assign modereg_burst_length =  reg_modeset[2:0];
//

//read_busy assign 1 when 
assign read_busy    = do_read  | (~mp_rd_l & busy_a_ena);
assign write_busy   = do_write | (~mp_wr_l & busy_a_ena);
assign modeset_busy = do_modeset;
assign refresh_busy = `LO ; 

// SDRAM BUSY SIGNAL GENERATION
//
// The BUSY signal is NOR'd of READ_BUSY, WRITE_BUSY and DUMB_BUSY.
// READ_BUSY is generated while the SDRAM is performing a read.  This 
// does not necessarily have to he synchronous to the micro's read.  
// The WRITE_BUSY is generated while the SDRAM is performing WRITE.
// Again, due to the "dump-n-run" mode (only in SMART_H=1) the micro's
// write bus cycle does not necessarily align with SDRAM's write cycle.
// DUMB_BUSY is a signal which generates the BUSY at the falling edge of
// micro's SDRAM_CS.  This is used for those microprocessors which 
// require a device BUSY as soon as the address is placed on its bus.  For
// example, most Intel microcontrollers and small processors do have this
// requirement.  This means that one will fofeit on the dump-n-go feature.
// 
assign sdram_busy_l = ~(  read_busy                |
                          write_busy               | 
                         (doing_refresh & ~mp_cs_l)| 
                         (modeset_busy  & ~mp_cs_l) 
                       );


// MP ADDRESS LATCH
// Transparent latch
// Used to hold the addx from the micro. Latch on the falling edge of
// do_write.
// BAsed on the way "do_write" is generated, we only need to latch on the writes
// since the write can be queued, but since all reads are blocked, the latch
// will not latch the addx on reads.  
assign reg_mp_addx = mp_addx;


//
// DECODED DQM LATCH
// generate the proper DQM[3:0] masks based on the address and on the mp_size 
//
always @(do_write or sys_rst_l or mp_addx or mp_size)
    // 32 bit masks
    // all masks are enabled (LOW)
    if (mp_size==2'b00)
       decoded_dqm <= 4'h0;
    // 16 bit masks
    // enable the masks accorsing to the half-word selected
    else if (mp_size==2'b10)
       case (mp_addx[1])
          `LO:      decoded_dqm <= 4'b1100;     // lower half-word enabled
           default: decoded_dqm <= 4'b0011;     // upper half-word enabled
       endcase
    // 8 bit masks
    // enablethe masks according to the byte specified.
    else if (mp_size==2'b01)
       case (mp_addx[1:0])
       2'b00:   decoded_dqm <= 4'b1110;
       2'b01:   decoded_dqm <= 4'b1101;
       2'b10:   decoded_dqm <= 4'b1011;
           default: decoded_dqm <= 4'b0111;
       endcase
    else
        decoded_dqm <= 4'bxxxx;


// MP DATA LATCH
// Used to hold the data from the micro.  Latch on the rising edge
// of mp_wr_l
//
`ifdef align_data_bus
always @(mp_data_in or reg_mp_addx)
    // 32 bit writes
    if (mp_size==2'b00)
       reg_mp_data <= mp_data_in;
    // 16 bit writes
    else if (mp_size==2'b10) 
       case(reg_mp_addx[1]) 
            `LO:     reg_mp_data[15:0] <= mp_data_in[15:0];
            default: reg_mp_data[31:16] <= mp_data_in[15:0];
       endcase
    // 8 bit writes
    else if (mp_size==2'b01)
       case(reg_mp_addx[1:0])
            2'b00:   reg_mp_data[7:0]   <= mp_data_in[7:0];
            2'b01:   reg_mp_data[15:8]  <= mp_data_in[7:0];
            2'b10:   reg_mp_data[23:16] <= mp_data_in[7:0];
            default: reg_mp_data[31:24] <= mp_data_in[7:0];
       endcase
//---------------------------------- if data aligning is not desired -------------------
`else
always @(mp_data_in)
     reg_mp_data <= mp_data_in;
`endif


//
// MODE REG REG
//
`define default_mode_reg {4'b0000,`default_mode_reg_CAS_LATENCY,`defulat_mode_reg_BURST_TYPE,`default_mode_reg_BURST_LENGHT}
always @(posedge sys_clk or negedge sys_rst_l)
    if (~sys_rst_l)
        reg_modeset <= 10'h000;
    else
    if (pwrup)
        reg_modeset <= `default_mode_reg;
    else 
    if (~sdram_mode_set_l & ~mp_cs_l & ~mp_wr_l)
        reg_modeset <= mp_data_in[10:0];

// SD DATA REGISTER
// This register holds in the data from the SDRAM
//
//always @(posedge sys_clk or negedge sys_rst_l)
always @(*)
  if (~sys_rst_l)
    reg_sd_data <= 33'hzzzzzzzz;
  else if (sd_rd_ena)
    reg_sd_data <= sd_data_buff;


//
// SD DATA BUS BUFFERS
//
//assign Sdata_to_mem  = reg_mp_data;
assign sd_data_buff = sd_data_in;



// SDRAM SIDE ADDX
always @(sd_addx10_mux or reg_mp_data or reg_mp_addx or reg_modeset)
  case (sd_addx10_mux)
    2'b00:   sd_addx[10] <= reg_mp_addx[20];
    2'b01:   sd_addx[10] <= 1'b0;
    2'b10:   sd_addx[10] <= reg_modeset[10];
    default: sd_addx[10] <= 1'b1;
  endcase

always @(sd_addx_mux or reg_modeset or reg_mp_addx)
  case (sd_addx_mux)
    2'b00:   sd_addx[9:0] <= reg_mp_addx[19:10];               // ROW
    2'b01:   sd_addx[9:0] <= {2'b00, reg_mp_addx[9:2]};        // COLUMN
    2'b10:   sd_addx[9:0] <= reg_modeset[9:0];
    default: sd_addx[9:0] <= 10'h000;
  endcase


// SD_BA
always @(sd_addx_mux or reg_mp_addx)
  case (sd_addx_mux)
    2'b00:    sd_ba <= reg_mp_addx[22:21];     
    2'b01:    sd_ba <= reg_mp_addx[22:21]; 
    default:  sd_ba <= 2'b00;
  endcase



// Micro data mux
//assign reg_mp_data_mux = mp_data_mux ? 32'h00000000 : reg_mp_data;

// MP_DATA_OUT mux
 //------------------------------- do this only if the DATA aligning is desired -------
`ifdef align_data_bus
always @(mp_size or reg_sd_data or mp_addx)
  case (mp_size)
     // 32 bit reads
     2'b00:  
         mp_data_out <= reg_sd_data;
     // 16 bit reads
     2'b10:
         if (mp_addx[1])
            DSdata_to_mem[15:0] <= reg_sd_data[31:16];
         else
            DSdata_to_mem[15:0] <= reg_sd_data[15:0];
     // 8 bit reads
     default:
         case (mp_addx[1:0])
             2'b00:   DSdata_from_mem[7:0] <= reg_sd_data[7:0];
             2'b01:   DSdata_from_mem[7:0] <= reg_sd_data[15:0];
             2'b10:   DSdata_from_mem[7:0] <= reg_sd_data[23:16];
             default: DSdata_from_mem[7:0] <= reg_sd_data[31:24];
         endcase
  endcase       
`else
//---------------------------------- if data aligning is not desired -------------------

`endif

//
// DO_READ   DO_WRITE   DO_MODESET
// signal generation
//

always @(posedge sys_clk or negedge sys_rst_l)
  if (~sys_rst_l) begin
    do_read  <= `LO;
    do_write <= `LO;
    do_modeset <= `LO;
    do_state <= 3'b000;
    busy_a_ena <= `HI; 
  end
  else 
    case (do_state)
        // hang in here until a read or write is requested 
        // (mp_rd_l = 1'b0) or (mp_wr_l = 1'b0)
        3'b000: begin
            // a read request
            if (~mp_rd_l & ~mp_cs_l) begin          
                do_read <= `HI;
                do_state <= 3'b001;
            end
            // a write request
            else if (~mp_wr_l & ~mp_cs_l & sdram_mode_set_l) begin
               do_write_flag <= `HI;
               do_read <= `HI;
                do_state <= 3'b001;
            end
            // a mode set request
            else if (~mp_wr_l & ~mp_cs_l & ~sdram_mode_set_l) begin
                do_modeset <= `HI;
                do_state <= 3'b001;
            end
            else
                do_state <= 3'b000;         
        end
        
        // This cycle is dummy cycle.  Just to extend 'busy_ena_a' 
        // to a total of 2 cycles 
        3'b001:
            begin
                busy_a_ena <= `LO;      // disable busy_a generation
                if (do_write_flag)
                   do_state <= 3'b010;
                else if (do_read)
              
                   do_state <= 3'b010;
                else if (do_modeset)
                   do_state <= 3'b110;
                else 
                   do_state <= 3'b001;
            end

        // hang in here until the sdramcnt has acknowledged the
        // read
        3'b010:
           
    if (do_read_ack) begin
        do_read <= `LO;
        if (do_write_flag == 1'b1) begin
            do_write <= `HI;
            do_state <= 3'b011;
        end else
            do_state <= 3'b100;
    end else
        do_state <= 3'b010;


        // hang in here until the sdramcnt has acknowledged the 
        // write
        3'b011:
            if (do_write_ack) begin
                do_write <= `LO;
                do_write_flag<=`LO;
                do_state <= 3'b101;
            end
            else
                do_state <= 3'b011;

        // wait in here until the host has read the data
        // (i.e. has raised its mp_rd_l high)
        3'b100:
            if (mp_rd_l) begin
                busy_a_ena <= `HI;      // re-enable busy_a generation
                do_state <= 3'b000;
            end
            else
                do_state <= 3'b100;
                
        // wait in here until the host has relinquieshed the write bus
        // (i.e. has raised its mp_wr_l high)
        3'b101:
            if (mp_wr_l) begin
                busy_a_ena <= `HI;      // re-enable busy_a generation
                do_state <= 3'b000;
            end
            else
                do_state <= 3'b101;

        // hang in here until the sdramcnt has acknowledged the 
        // mode set
        3'b110:
            if (do_modeset_ack) begin
                do_modeset <= `LO;
                do_state <= 3'b101;
            end else
                do_state <= 3'b110;


    endcase
   // assign sw_in_1 = mem_sw_flag[mp_addx[0:1]][mp_addx[10:20]][mp_addx[2:9]];
    
    
                
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SCFRAMBLING MODULE CIRCUIT 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 reg [32:0] Sdata_to_mem;     // Data input (host data)
 reg [31:0] DSdata_from_mem; 
 //wire do_write,                // Write enable signal
 //wire do_read,                 // Read enable signal
// wire [3:0]next_state,     // next state 

  
///////////////////////////////////////////////////////////////////////
    // Internal signals
    wire [31:0] scrambling_vector;      // Scrambling vector from memory array
    wire [31:0] random_vector;          // Random number for refreshing vector
    wire [31:0] vector;                   // Vector output from the Scrambler Table
    //wire sw_out;                          // Youth flag output
    wire sw_in;                            // Youth flag input
   wire  [4:0]address_to_ST;
    
    ////////////////////////////////////////////////////////////////////////
   //reg case4_triggered_out;            // Case 4 triggered flag
  // wire case4_triggered_in;
   
//   always@(*)begin
//   if(do_read)
//     do_read_1=1'b1;
//      if(next_state==4'he)
   
//   else
//    do_read_1=1'b0;
     
//   end
   

    
    ///////////////////////////////////////////////////////////////////////////
    // XOR Scrambling and Descrambling Logic

//assign Sdata_to_mem = (do_write && (next_state == 4'd1)) ? {sw_out, vector ^ reg_mp_data} : 33'bz;
//assign DSdata_from_mem = (do_read && (next_state == 4'd1)) ? (vector ^ sd_data_in[31:0]) : 32'bz; 
always@(posedge sys_clk) begin
if(do_write && (next_state == 4'd3 || next_state == 4'hd )) begin
   Sdata_to_mem<={sw_out, vector ^ reg_mp_data};
   end
else if( sd_rd_ena && (next_state == 4'hc )) begin
        DSdata_from_mem<=(vector ^ reg_sd_data[31:0]);
end 
end 

 ///////////////////////////////////

  assign  sw_in= sd_data_buff[32];
    
    

////////////////////////////////////////////////////////////////////////////////

            assign address_to_ST = reg_mp_addx[14:10]; // Use lower 5 bits of reg_mp_addx
      
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    

    // Initialize memory (example only)
    initial begin
        memory[0] = 71'b1_00000000000000000000000000000001_11111111111111111111111111111111_001_110;
        memory[1] = 71'b0_11111111111111111111111111111110_00000000000000000000000000000010_001_010;
        memory[2] = 71'b1_10101010101010101010101010101010_01010101010101010101010101010101_011_000;
        memory[3] = 71'b0_00000000000000000000000000000000_11111111111111111111111111111111_100_001; 
    end

    // Read operation: Select the memory entry based on the address
    always@(*) begin
   
    mem = memory[address_to_ST];  // Read memory at the address
    sw_out = mem[70];             // Extract youth flag
    Si0 = mem[69:38];             // Extract young scrambling vector
    Si1 = mem[37:6];              // Extract old scrambling vector
    Ci0 = mem[5:3];               // Extract age counter for young
    Ci1 = mem[2:0];               // Extract age counter for old
end

    // Write operation: Update the youth flag and age counters
//   always @(*) begin //posedge sys_clk or negedge sys_rst_l
//    if (!sys_rst_l) begin
//        vector_refresh <= 1'b0;
//        sw_out_age <= sw_out;
//        new_sw <= sw_out;
//        case4_triggered <= 1'b0; // sys_rst_l the flag
      
//    end else if (do_write && (next_state == 4'h1 || next_state == 4'h8) ) begin  /////////&& next_state == 4'h1
    
//       if (sw_in == sw_out) begin
//            // If `sw_in` matches `sw_out`, no refresh is needed
//            vector_refresh <= 1'b0;
//            new_sw <= sw_out;
//           case4_triggered <= 1'b0; // sys_rst_l the flag
//           end 
//       else begin
//            if (sw_out == 1'b1) begin
//                // Case for sw_out = 1
//                 Ci1 <= Ci1 + 1;
//                 Ci0 <= (Ci0 == 0) ? Ci0 : Ci0 - 1; // Prevent underflow
                
//                if ((Ci1 == 3'b111) && (Ci0 != 3'b000)) begin
//                    // Case 1: C1 full and C0 not 0
//                    sw_out_age <= 1'b0;
//                    vector_refresh <= 1'b0;
//                    new_sw <= 1'b1;
//                end else if ((Ci1 != 3'b111) && (Ci0 != 3'b000)) begin
//                    // Case 2: C1 not full and C0 not 0
//                    sw_out_age <= 1'b1;
//                    vector_refresh <= 1'b0;
//                    new_sw <= 1'b1;
//                end else if ((Ci1 == 3'b111) && (Ci0 == 3'b000)) begin
//                    // Case 3: C1 full and C0 is 0
//                    sw_out_age <= 1'b0;
//                    new_sw <= 1'b0;
//                    if(case4_triggered == 1'b0) begin
//                         vector_refresh <= 1'b1;
//                        case4_triggered <= 1'b1;
//                           end
//                      else begin
//                            vector_refresh <= 1'b0;
//                           end
                    
//                end else if ((Ci1 != 3'b111) && (Ci0 == 3'b000)) begin
//                    // Case 4: C1 not full and C0 is 0 (execute only once)
//                sw_out_age <= 1'b1;
//                     new_sw <= 1'b0;
//                    if(case4_triggered == 1'b0) begin
//                         vector_refresh <= 1'b1;
//                         case4_triggered <= 1'b1;
//                           end
//                      else begin
//                            vector_refresh <= 1'b0;
//                           end
//                end
//            end 
//          else if (sw_out == 1'b0) begin
//                // Current flag is young
//                Ci0 <= Ci0 + 1;
//                Ci1 <= (Ci1 == 0) ? Ci1 : Ci1 - 1; // Prevent underflow
                
//                // Case for sw_out = 0
//                if ((Ci0 == 3'b111) && (Ci1 != 3'b000)) begin
//                    // Case 1: C0 full and C1 not 0
//                    sw_out_age <= 1'b1;
//                    vector_refresh <= 1'b0;
//                    new_sw <= 1'b0;
//                end else if ((Ci0 != 3'b111) && (Ci1 != 3'b000)) begin
//                    // Case 2: C0 not full and C1 not 0
//                    sw_out_age <= 1'b0;
//                    vector_refresh <= 1'b0;
//                    new_sw <= 1'b0;
//                end else if ((Ci0 == 3'b111) && (Ci1 == 3'b000)) begin
//                    // Case 3: C0 full and C1 is 0
//                    sw_out_age <= 1'b1;
                  
//                    new_sw <= 1'b1;
//                     if(case4_triggered == 1'b0) begin
//                         vector_refresh <= 1'b1;
//                       case4_triggered <= 1'b1;
//                           end
//                      else begin
//                            vector_refresh <= 1'b0;
//                           end
//                end else if ((Ci0 != 3'b111) && (Ci1 == 3'b000)) begin
//                    // Case 4: C0 not full and C1 is 0 (execute only once)
//                    sw_out_age <= 1'b0;
//                    new_sw <= 1'b0;
//                   if(case4_triggered == 1'b1) begin
//                          vector_refresh <= 1'b0;
//                         case4_triggered <= 1'b1;
//                          end
//                    else  begin
//                     vector_refresh <= 1'b1;
//                         end
//                end
//            end
//        end
           
//       end
//    end
always @(*) begin
        // Default assignments
        vector_refresh = 1'b0;
        //sw_out_age = sw_out;
        //new_sw = sw_out;
       // Ci1_out = Ci1;
       // Ci0_out = Ci0;
       // case4_triggered_out = case4_triggered_in;

        // Handle reset condition
        if (!sys_rst_l) begin
            vector_refresh = 1'b0;
            sw_out_age = sw_out;
            new_sw = sw_out;
            //Ci1 = 3'b000;
            //Ci0_out = 3'b000;
           // case4_triggered_out = 1'b0;
        end 
        // Handle logic when write is enabled and specific states are active
        else if (do_write  ) begin//&& (next_state == 4'h1 )
            if (sw_in == sw_out) begin
                // No refresh needed if `sw_in` matches `sw_out`
                vector_refresh = 1'b0;
                new_sw = sw_out;
               // case4_triggered_out = 1'b0;
            end else begin
                if (sw_out == 1'b1) begin
                    // Logic for `sw_out = 1`
                    Ci1 = (Ci1 == 3'b111) ? Ci1 : Ci1 + 1;//Ci1_out
                    Ci0 = (Ci0 == 0) ? Ci0 : Ci0 - 1;//Ci0_out

                    if (Ci1 == 3'b111 && Ci0 != 3'b000) begin
                        sw_out_age = 1'b0;
                        vector_refresh = 1'b0;
                        new_sw = 1'b1;
                    end else if (Ci1 != 3'b111 && Ci0 != 3'b000) begin
                        sw_out_age = 1'b1;
                        vector_refresh = 1'b0;
                        new_sw = 1'b1;
                    end else if (Ci1 == 3'b111 && Ci0 == 3'b000) begin
                        sw_out_age = 1'b0;
                        new_sw = 1'b0;
                        //if (!case4_triggered_in) begin
                            vector_refresh = 1'b1;
                        //    case4_triggered_out = 1'b1;
                        //end
                    end else if (Ci1 != 3'b111 && Ci0 == 3'b000) begin
                        sw_out_age = 1'b1;
                        new_sw = 1'b0;
                        //if (!case4_triggered_in) begin
                            vector_refresh = 1'b1;
                         //   case4_triggered_out = 1'b1;
                        //end
                    end
                end else if (sw_out == 1'b0) begin
                    // Logic for `sw_out = 0`
                    Ci0 = (Ci0 == 3'b111) ? Ci0 : Ci0 + 1;
                    Ci1 = (Ci1 == 0) ? Ci1 : Ci1 - 1;

                    if (Ci0 == 3'b111 && Ci1 != 3'b000) begin
                        sw_out_age = 1'b1;
                        vector_refresh = 1'b0;
                        new_sw = 1'b0;
                    end else if (Ci0 != 3'b111 && Ci1 != 3'b000) begin
                        sw_out_age = 1'b0;
                        vector_refresh = 1'b0;
                        new_sw = 1'b0;
                    end else if (Ci0 == 3'b111 && Ci1 == 3'b000) begin
                        sw_out_age = 1'b1;
                        new_sw = 1'b1;
                        //if (!case4_triggered_in) begin
                            vector_refresh = 1'b1;
                           // case4_triggered_out = 1'b1;
                        //end
                    end else if (Ci0 != 3'b111 && Ci1 == 3'b000) begin
                        sw_out_age = 1'b0;
                        new_sw = 1'b0;
                        //if (!case4_triggered_in) begin
                            vector_refresh = 1'b1;
                            //case4_triggered_out = 1'b1;
                        //end
                    end
                end
            end
        end
    end



//                                    
                                    always@(posedge sys_clk)
                                        begin 
                                        if(do_write && next_state==4'he) begin
                                          // Write updated counters and youth flag back to memory
                                          memory[address_to_ST][70] <= sw_out_age; // Update youth flag
                                          memory[address_to_ST][5:3] <= Ci0;      // Update C0 counter//Ci0_out
                                          memory[address_to_ST][2:0] <= Ci1;      // Update C1 counter 
                                          end
        
                                        end
   // Select Scrambling Vector
    // Wire declaration for vector

// Combinational logic using assign
assign vector = (do_write) ? (sw_out == 1'b0 ? Si0 : Si1) : 
 (sd_rd_ena)  ? (sw_in == 1'b0 ? Si0 : Si1) : 32'b0; // Default to zero if neither read nor write

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    // Random Number Generator Logic//
//    module RAND_GEN (
//    output reg [31:0] rnd,   // Output: 32-bit random number
//    input clock,             // Input: clock signal
//    input sys_rst_l,             // Input: sys_rst_l signal
//    input vector_refresh     // Input: vector refresh signal
//);
    reg [31:0] random, random_next;   // LFSR registers to hold the current and next random values
    reg [5:0] count, count_next;      // Counter to track the number of shifts (5 bits for up to 32)

    // XOR feedback logic for the LFSR (taps: 31, 21, 1, 0)
    wire feedback = random[31] ^ random[21] ^ random[1] ^ random[0];

    // Sequential logic to update random number and count on clock or sys_rst_l
    always @(posedge sys_clk or  negedge sys_rst_l) begin
        if (!sys_rst_l) begin
            random <= 32'hABCDE123;  // Initialize LFSR to non-zero value (cannot start at 0)
            count <= 0;              // sys_rst_l shift counter
        end else begin
            random <= random_next;   // Update LFSR value
            count <= count_next;     // Update shift counter
           
        end
    end

    // Combinational logic to determine next state of LFSR and counter
    always @(*) begin
        random_next = random;    // Default: retain current LFSR value
        count_next = count;      // Default: retain current count

        // Shift LFSR left by 1 and insert feedback at LSB
        if(vector_refresh==1 && next_state==4'he) begin
        random_next = {random[30:0], feedback};
        end

        // Increment shift counter
        count_next = count + 1;

        // After 32 shifts, sys_rst_l the shift counter
        if (count == 32) begin
            count_next = 0;      // sys_rst_l shift counter
        end
    end
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   // Write operation: Update the scrambling vector on vector refresh
    always @(*) begin
        if (vector_refresh && do_write && next_state==4'he) begin
            if (new_sw == 1'b0) begin
                memory[address_to_ST][69:38] <= random; // Update young vector
            end else if(new_sw == 1'b1) begin
                memory[address_to_ST][37:6] <= random;  // Update old vector
            end
        end
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
