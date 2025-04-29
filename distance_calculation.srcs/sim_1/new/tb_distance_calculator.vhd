library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_distance_calculator is
end tb_distance_calculator;

architecture Behavioral of tb_distance_calculator is
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal echo_time   : unsigned(31 downto 0) := (others => '0');
    signal distance_cm : std_logic_vector(15 downto 0);

    constant clk_period : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.distance_calculator
        port map (
            clk         => clk,
            rst         => rst,
            echo_time   => echo_time,
            distance_cm => distance_cm
        );

    -- Clock generation
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
    stim_proc: process
    begin
        -- Initial reset
        wait for 20 ns;
        rst <= '0';

        -- Test 1: 100 cm
        echo_time <= to_unsigned(580000, 32);
        wait for clk_period * 3;
        report "Test 1 (100 cm): distance_cm = " & integer'image(to_integer(unsigned(distance_cm)));

        -- Test 2: 200 cm
        echo_time <= to_unsigned(1160000, 32);
        wait for clk_period * 3;
        report "Test 2 (200 cm): distance_cm = " & integer'image(to_integer(unsigned(distance_cm)));

        -- Test 3: 50 cm
        echo_time <= to_unsigned(290000, 32);
        wait for clk_period * 3;
        report "Test 3 (50 cm): distance_cm = " & integer'image(to_integer(unsigned(distance_cm)));

        wait;
    end process;
end Behavioral;
