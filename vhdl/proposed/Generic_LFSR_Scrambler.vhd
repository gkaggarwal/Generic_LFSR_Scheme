----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.07.2025 14:35:10
-- Design Name: 
-- Module Name: Generic_LFSR_Scrambler - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Generic_LFSR_Scrambler is
    generic (
        SEED_WIDTH  : integer := 256;  -- Width of the LFSR and seed
        DATA_WIDTH  : integer := 32    -- Width of the data to be scrambled
    );
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        enable         : in  std_logic;  -- Enable scrambling
        seed           : in  std_logic_vector(SEED_WIDTH - 1 downto 0);
        addr           : in  std_logic_vector(31 downto 0);  -- Input address
        data_in        : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- Data to scramble
        scrambled_out  : out std_logic_vector(DATA_WIDTH - 1 downto 0)   -- Scrambled data
    );
end Generic_LFSR_Scrambler;

architecture Behavioral of Generic_LFSR_Scrambler is

    -- Internal signals
    signal lfsr_reg  : std_logic_vector(SEED_WIDTH - 1 downto 0);
    signal xor_bit   : std_logic;
    signal lfsr_out  : std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- Constant tap points (example: primitive polynomial for 256-bit LFSR)
    constant TAP1 : integer := SEED_WIDTH - 1;
    constant TAP2 : integer := SEED_WIDTH - 2;
    constant TAP3 : integer := SEED_WIDTH - 3;
    constant TAP4 : integer := SEED_WIDTH - 5;

begin

    -- LFSR Update Process
    process(clk, rst)
    begin
        if rst = '1' then
            -- Seed initialization: Combine seed with memory address
            lfsr_reg <= seed xor std_logic_vector(resize(unsigned(addr), SEED_WIDTH));
        elsif rising_edge(clk) then
            if enable = '1' then
                -- Linear feedback function with predefined taps
                xor_bit <= lfsr_reg(TAP1) xor lfsr_reg(TAP2) xor lfsr_reg(TAP3) xor lfsr_reg(TAP4);
                -- Shift register with feedback
                lfsr_reg <= xor_bit & lfsr_reg(SEED_WIDTH - 1 downto 1);
            end if;
        end if;
    end process;

    -- Use the lower DATA_WIDTH bits of the LFSR as keystream
    lfsr_out <= lfsr_reg(DATA_WIDTH - 1 downto 0);

    -- Scrambling using XOR operation
    scrambled_out <= data_in xor lfsr_out;

end Behavioral;

