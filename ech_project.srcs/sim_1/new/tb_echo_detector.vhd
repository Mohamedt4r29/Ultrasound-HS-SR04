library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_echo_detector is
end tb_echo_detector;

architecture Behavioral of tb_echo_detector is

    -- DUT signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal echo        : std_logic := '0';
    signal echo_start  : std_logic;
    signal echo_end    : std_logic;
    signal echo_time   : unsigned(31 downto 0);

    constant clk_period : time := 10 ns; -- 100 MHz clock

begin

    -- Instantiate the DUT
    uut: entity work.echo_detector
        port map (
            clk        => clk,
            rst        => rst,
            echo       => echo,
            echo_start => echo_start,
            echo_end   => echo_end,
            echo_time  => echo_time
        );

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        wait for 50 ns;
        rst <= '0';

        wait for 100 ns;
        echo <= '1';              -- simulate echo rising edge
        wait for 500 ns;          -- echo high duration
        echo <= '0';              -- simulate echo falling edge

        wait for 500 ns;
        echo <= '1';              -- another echo pulse
        wait for 300 ns;
        echo <= '0';

        wait for 1 us;
        assert false report "Simulation finished" severity failure;
    end process;

end Behavioral;
