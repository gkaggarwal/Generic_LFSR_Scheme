----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.07.2025 14:38:22
-- Design Name: 
-- Module Name: tb_lfsr_scrambler - Behavioral
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

entity tb_lfsr_scrambler is
end tb_lfsr_scrambler;

architecture Behavioral of tb_lfsr_scrambler is

    -- Component declaration
    component Generic_LFSR_Scrambler is
        generic (
            SEED_WIDTH  : integer := 256;
            DATA_WIDTH  : integer := 32
        );
        port (
            clk            : in  std_logic;
            rst            : in  std_logic;
            enable         : in  std_logic;
            seed           : in  std_logic_vector(SEED_WIDTH - 1 downto 0);
            addr           : in  std_logic_vector(31 downto 0);
            data_in        : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            scrambled_out  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    -- Constants
    constant SEED_WIDTH : integer := 256;
    constant DATA_WIDTH : integer := 32;

    -- Signals
    signal clk           : std_logic := '0';
    signal rst           : std_logic := '1';
    signal enable        : std_logic := '0';
    signal seed          : std_logic_vector(SEED_WIDTH - 1 downto 0);
    signal addr          : std_logic_vector(31 downto 0);
    signal data_in       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal scrambled_out : std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- Clock generation: 10 ns period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the DUT
    DUT: Generic_LFSR_Scrambler
        generic map (
            SEED_WIDTH => SEED_WIDTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk            => clk,
            rst            => rst,
            enable         => enable,
            seed           => seed,
            addr           => addr,
            data_in        => data_in,
            scrambled_out  => scrambled_out
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Initialize inputs
        seed    <= (others => '0');
        addr    <= x"1000_0000";
        data_in <= x"DEADBEEF";
        wait for 20 ns;

        -- Apply reset
        rst <= '0';
        seed(SEED_WIDTH - 1 downto 0) <= x"123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0";
        wait for 20 ns;

        -- Enable scrambling
        enable <= '1';

        -- Run for 10 clock cycles
        wait for 100 ns;

        -- Stop scrambling
        enable <= '0';
        wait;

    end process;

end Behavioral;

