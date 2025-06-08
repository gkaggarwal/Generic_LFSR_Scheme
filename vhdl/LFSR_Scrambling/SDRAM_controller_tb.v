`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2025 18:13:59
// Design Name: 
// Module Name: SDRAM_controller_tb
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


module sdram_controller_tb;

    // Testbench Signal Declarations
    reg sys_clk = 0;
    reg sys_rst_l = 0;
    reg mp_wr_l = 1;
    reg mp_rd_l = 1;
    reg mp_cs_l = 1;
    reg sdram_mode_set_l = 1;
    reg [31:0] mp_data_in ;
    reg [22:0] mp_addx = 0;         // Address bus for SDRAM
    reg [1:0] mp_size = 2'b00;      // Assuming 32-bit mode (00=32bits)

   // wire [31:0] DSdata_from_mem;
    wire [31:0] mp_data_out;
    wire [1:0] sd_ba;
    wire [3:0] next_state;

    // Clock period definition
    localparam CLOCK_PERIOD = 100;

    // Instantiate the SDRAM Controller (Unit Under Test, UUT)
    sdram uut(
        .sys_clk(sys_clk),
        .sys_rst_l(sys_rst_l),
        .mp_wr_l(mp_wr_l),
        .mp_rd_l(mp_rd_l),
        .mp_cs_l(mp_cs_l),
        .sdram_mode_set_l(sdram_mode_set_l),
        .mp_data_in(mp_data_in),
        .mp_addx(mp_addx),
        .mp_size(mp_size),
        .mp_data_out( mp_data_out),
        .sd_ba(sd_ba),
        .next_state(next_state)
    );

    // Clock generation
    always #(CLOCK_PERIOD / 2) sys_clk = ~sys_clk;

    // Test Sequence
    initial begin
        // Step 1: Assert reset for 2 cycles
        sys_rst_l = 0;
        # (2 * CLOCK_PERIOD);
        sys_rst_l = 1;

        // Step 2: Wait for 3 cycles to reach auto-refresh state
        # (4 * CLOCK_PERIOD);

        // Step 3: Perform auto-refresh for 6 cycles, repeated twice
        repeat (3) begin
            # (8 * CLOCK_PERIOD);
        end

//        // Step 4: Write sequence
        mp_cs_l = 0;    // Enable chip select
       mp_wr_l = 0;    // Enable write
        mp_addx = 23'd0;
        mp_data_in = 32'h22222222;
          # (2* CLOCK_PERIOD);
        mp_cs_l = 1;    // Enable chip select
             mp_wr_l = 1; 
           # (6 * CLOCK_PERIOD);
              # (9 * CLOCK_PERIOD);
               # (7 * CLOCK_PERIOD);
        mp_cs_l = 0;    // Enable chip select
      mp_wr_l = 0;    // Enable write
         mp_addx = 23'h4;
        mp_data_in = 32'h33333333;
         # (2* CLOCK_PERIOD);
        mp_cs_l = 1;    // Enable chip select
      mp_wr_l = 1;    // Enable write
         # (13 * CLOCK_PERIOD);
        mp_cs_l = 0;    // Enable chip select
       mp_wr_l = 0;    // Enable write
        mp_addx = 23'h8;
        mp_data_in = 32'h44444444;
          # (2* CLOCK_PERIOD);
        mp_cs_l = 1;    // Enable chip select
             mp_wr_l = 1; 
       # (22 * CLOCK_PERIOD);
       mp_cs_l = 0;    // Enable chip select
       mp_wr_l = 0;    // Enable write
        mp_addx = 23'hc;
        mp_data_in = 32'h55555555;
          # (2* CLOCK_PERIOD);
             mp_cs_l = 1;    // Enable chip select
           mp_wr_l = 1; 
         # (13* CLOCK_PERIOD);
             mp_cs_l = 0;    // Enable chip select
             mp_wr_l = 0;    // Enable write
       mp_addx = 23'h10;
        mp_data_in = 32'h66666666;
         # (2* CLOCK_PERIOD);
         mp_cs_l = 1;    // Enable chip select
             mp_wr_l = 1; 
             # (22* CLOCK_PERIOD);
             mp_cs_l = 0;    // Enable chip select
             mp_wr_l = 0;    // Enable write
       mp_addx = 23'h14;
        mp_data_in = 32'h77777777;
         # (2* CLOCK_PERIOD);
         mp_cs_l = 1;    // Enable chip select
             mp_wr_l = 1; 
             # (13* CLOCK_PERIOD);
             mp_cs_l = 0;    // Enable chip select
             mp_wr_l = 0;    // Enable write
       mp_addx = 23'h18;
        mp_data_in = 32'h88888888;
         # (2* CLOCK_PERIOD);
         mp_cs_l = 1;    // Enable chip select
             mp_wr_l = 1; 
             # (22* CLOCK_PERIOD);
             mp_cs_l = 0;    // Enable chip select
             mp_wr_l = 0;    // Enable write
       mp_addx = 23'h1c;
        mp_data_in = 32'h99999999;
         # (2* CLOCK_PERIOD);
         mp_cs_l = 1;    // Enable chip select
             mp_wr_l = 1; 
             # (13* CLOCK_PERIOD);
             mp_cs_l = 0;    // Enable chip select
             mp_wr_l = 0;    // Enable write
       mp_addx = 23'h20;
        mp_data_in = 32'h11111111;
         # (2* CLOCK_PERIOD);
         mp_cs_l = 1;    // Enable chip select
             mp_wr_l = 1; 
             
    #(22* CLOCK_PERIOD);         
//////////////////////////////////READ//////////////////////////////////////////////////////After 23 cycles of auto cntr 6
        mp_cs_l = 0;    // Enable chip select
       mp_rd_l = 0;    // Enable write
       mp_addx = 23'h0;
       # (2* CLOCK_PERIOD);
       mp_cs_l = 1;    // Enable chip select
          mp_rd_l = 1;    // Enable write
             # (6* CLOCK_PERIOD);
              mp_cs_l = 0;    // Enable chip select
       mp_rd_l = 0;    // Enable write
       mp_addx = 23'h4;
       # (2* CLOCK_PERIOD);
       mp_cs_l = 1;    // Enable chip select
          mp_rd_l = 1;    // Enable write
           # (14* CLOCK_PERIOD);
            mp_cs_l = 0;    // Enable chip select
       mp_rd_l = 0;    // Enable write
       mp_addx = 23'h8;
       # (2* CLOCK_PERIOD);
       mp_cs_l = 1;    // Enable chip select
          mp_rd_l = 1;    // Enable write
             # (7* CLOCK_PERIOD);
             mp_rd_l = 0;    // Enable write
              mp_cs_l = 0;    // Enable chip select
       mp_addx = 23'hc;
       # (2* CLOCK_PERIOD);
       mp_cs_l = 1;    // Enable chip select
          mp_rd_l = 1;    // Enable write
             # (7* CLOCK_PERIOD);
             mp_rd_l = 0;    // Enable write
              mp_cs_l = 0;    // Enable chip select
       mp_addx = 23'h10;
       # (2* CLOCK_PERIOD);
       mp_cs_l = 1;    // Enable chip select
          mp_rd_l = 1;    // Enable write
           # (14* CLOCK_PERIOD);
             mp_rd_l = 0;    // Enable write
              mp_cs_l = 0;    // Enable chip select
       mp_addx = 23'h14;
       # (2* CLOCK_PERIOD);
       mp_cs_l = 1;    // Enable chip select
          mp_rd_l = 1;    // Enable write
            # (7* CLOCK_PERIOD);
          mp_rd_l = 0;    // Enable write
              mp_cs_l = 0;    // Enable chip select
       mp_addx = 23'h1c;
       # (2* CLOCK_PERIOD);
       mp_cs_l = 1;        // Enable chip select
          mp_rd_l = 1;    // Enable write
          # (7* CLOCK_PERIOD);
          mp_rd_l = 0;    // Enable write
              mp_cs_l = 0;    // Enable chip select
       mp_addx = 23'h18;
       # (2* CLOCK_PERIOD);
       mp_cs_l = 1;        // Enable chip select
          mp_rd_l = 1;    
          # (7* CLOCK_PERIOD);
          mp_rd_l = 0;    // Enable write
              mp_cs_l = 0;    // Enable chip select
       mp_addx = 23'h20;
       # (2* CLOCK_PERIOD);
       mp_cs_l = 1;        // Enable chip select
          mp_rd_l = 1;    
        // Finish the simulation
        $display("End of simulation");
        $stop;
    end

endmodule

