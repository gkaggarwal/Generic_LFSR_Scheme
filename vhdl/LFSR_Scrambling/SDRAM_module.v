`timescale 1ns / 1ps


module SDRAM_module (
    input wire clk,                // Clock input
    input wire sys_rst_l,          // Active-low reset
    // SDRAM connection
    input wire [10:0] sdram_addx,  // Address from controller (row/column multiplexed)
    input wire [32:0] sdram_data_in,  // Data input for writing
    output reg [32:0] sdram_data_out, // Data output for reading
    input wire [1:0] sdram_bank,   // Bank selection
    // Host control side connection
    input wire sdram_wr_l,         // Write enable
    input wire sdram_ras_l,        // Row address strobe
    input wire sdram_cas_l,        // Column address strobe
    input wire [3:0] sdram_dqm,    // Data mask for partial writes
    input wire sdram_cs_l          // Chip select signal
);
    
    // Define the dimensions for the 2D split of the second dimension
    parameter ROWS = 12;   // Number of rows
    parameter COLS = 12;   // Number of columns

    // Define a 3-dimensional SDRAM memory array
    reg [32:0] sdram_mem [0:3][0:ROWS-1][0:COLS-1]; // 4 banks of 5 rows and 5 columns each
    initial begin
      sdram_mem [0][0][0]=33'h012121222;//d0
      sdram_mem [0][1][5]=33'h0dddddddd;//d1044
     sdram_mem [0][2][4]=33'h0aaaaaaaa;//d2064
     sdram_mem [0][3][3]=33'h0cccccccc;//d3084
     sdram_mem [0][4][2]=33'h0ffffffff;//d4104
     sdram_mem [0][5][1]=33'h0eeeeeeee;//d5124
      sdram_mem [0][0][1]=33'h100000001;//d4
       sdram_mem [0][0][2]=33'h100000002;//d8
       sdram_mem [0][0][3]=33'h100000003;//d12
       sdram_mem [0][0][4]=33'h100000004;//d16//h10
        sdram_mem [0][0][5]=33'h100000005;//d20//h14
         sdram_mem [0][0][6]=33'h100000006;//d24//h18
         sdram_mem [0][0][7]=33'h100000007;//d28//h1c
         sdram_mem [0][0][8]=33'h000000008;//d32//h20
         sdram_mem [0][0][9]=33'h000000009;//d36//h24
         sdram_mem [0][0][10]=33'h000000010;//d40//h28
    end
    
    // Internal registers to hold the row and column addresses
    reg [10:0] row_address;
    reg [10:0] col_address;
    reg [1:0] active_bank; // Active bank

    // Reset logic
    always @(posedge clk or negedge sys_rst_l) begin
        if (!sys_rst_l) begin
            sdram_data_out <= 33'bz;
             active_bank <= 2'b0; // Reset active bank
            row_address <= 11'b0;
            col_address <= 11'b0;
        end else if (!sdram_cs_l) begin  // Chip select active
            // Handle RAS and CAS strobes
            active_bank <= sdram_bank;    // Select the active bank
            if (!sdram_ras_l && sdram_cas_l) begin
                row_address <= sdram_addx;  // Set row address
            end else if (sdram_ras_l && !sdram_cas_l) begin
                col_address <= sdram_addx;  // Set column address
            end
            
//            // Write logic
//            if (!sdram_wr_l) begin
//                write_active <= 1'b1;
//            end
            
//            // Read logic
//            if (!sdram_wr_l ) begin
//                read_active <= 1'b1;
//            end
        end
    end

    // Writing data to SDRAM
    always @(posedge clk) begin
        if (~sdram_wr_l) begin
            // Write to the memory only if the data mask permits
            if (sdram_dqm==4'b0) begin
             sdram_mem[active_bank][row_address][col_address] <= sdram_data_in;
             end
            else 
                begin
                             if (sdram_dqm[0] == 1'b0) sdram_mem[active_bank][row_address][ col_address][7:0]   <= sdram_data_in[7:0];
                             if (sdram_dqm[1] == 1'b0) sdram_mem[active_bank][row_address][ col_address][15:8]  <= sdram_data_in[15:8];
                             if (sdram_dqm[2] == 1'b0) sdram_mem[active_bank][row_address][ col_address][23:16] <= sdram_data_in[23:16];
                             if (sdram_dqm[3] == 1'b0) sdram_mem[active_bank][row_address][ col_address][31:24] <= sdram_data_in[31:24];
                end
    
    end            
    end

    // Reading data from SDRAM
    always @(posedge clk) begin
        if (sdram_wr_l) begin
                 if (sdram_dqm==4'b0)begin
            sdram_data_out <= sdram_mem[sdram_bank][row_address][col_address];  // Output the data
           end 
           end
           else 
           begin
                             if (sdram_dqm[0] == 1'b0)  sdram_data_out[7:0] <= sdram_mem[active_bank][row_address][ col_address][7:0];
                             if (sdram_dqm[1] == 1'b0) sdram_data_out[15:8] <= sdram_mem[active_bank][row_address][ col_address][15:8];
                             if (sdram_dqm[2] == 1'b0) sdram_data_out[23:16] <= sdram_mem[active_bank][row_address][ col_address][23:16];
                             if (sdram_dqm[3] == 1'b0) sdram_data_out[31:24] <=  sdram_mem[active_bank][row_address][ col_address][31:24];
           end
    end

endmodule
