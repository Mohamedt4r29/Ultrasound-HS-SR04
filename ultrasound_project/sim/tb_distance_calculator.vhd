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
    signal valid       : std_logic;

    constant clk_period : time := 10 ns;

begin
    -- Instantiate Unit Under Test
    uut: entity work.distance_calculator
        port map (
            clk         => clk,
            rst         => rst,
            echo_time   => echo_time,
            distance_cm => distance_cm,
            valid       => valid
        );

    -- Clock generator
    clk_process : process
    begin
        while now < 2000 ns loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        wait for 20 ns;
        rst <= '0';

        -- Test 1: 5800 = 1 cm
        echo_time <= to_unsigned(5800, 32);
        wait for clk_period;
        report "Result (should be 1): " & integer'image(to_integer(unsigned(distance_cm)));

        -- Test 2: 58000 = 10 cm
        echo_time <= to_unsigned(58000, 32);
        wait for clk_period;
        report "Result (should be 10): " & integer'image(to_integer(unsigned(distance_cm)));

        -- Test 3: 290000 = 50 cm
        echo_time <= to_unsigned(290000, 32);
        wait for clk_period;
        report "Result (should be 50): " & integer'image(to_integer(unsigned(distance_cm)));

        -- Test 4: 1160000 = 200 cm
        echo_time <= to_unsigned(1160000, 32);
        wait for clk_period;
        report "Result (should be 200): " & integer'image(to_integer(unsigned(distance_cm)));

        wait;
    end process;

end Behavioral;
