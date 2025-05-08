-- File: ultrasonic_top_tb.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ultrasonic_top_tb is
end ultrasonic_top_tb;

architecture Behavioral of ultrasonic_top_tb is
    component ultrasonic_top
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            echo     : in  STD_LOGIC;
            trig     : out STD_LOGIC;
            seg      : out STD_LOGIC_VECTOR(6 downto 0);
            an       : out STD_LOGIC_VECTOR(3 downto 0);
            distance : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal echo     : STD_LOGIC := '0';
    signal trig     : STD_LOGIC;
    signal seg      : STD_LOGIC_VECTOR(6 downto 0);
    signal an       : STD_LOGIC_VECTOR(3 downto 0);
    signal distance : STD_LOGIC_VECTOR(15 downto 0);

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

begin
    uut: ultrasonic_top
        port map (
            clk      => clk,
            reset    => reset,
            echo     => echo,
            trig     => trig,
            seg      => seg,
            an       => an,
            distance => distance
        );

    -- Clock process
    clk_process: process
    begin
        wait for CLK_PERIOD / 2;
        clk <= not clk;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- Wait for first trigger pulse
        wait until trig = '1';
        wait until trig = '0';

        -- Simulate echo pulse for 1m distance (~5820us)
        echo <= '1';
        wait for 5820 us;
        echo <= '0';
        wait for 1 us; -- Wait for distance to update
        -- Verify distance (~1000 mm)
        assert (unsigned(distance) > 990 and unsigned(distance) < 1010)
            report "Distance incorrect for 1m echo pulse, expected ~1000 mm, got " & integer'image(to_integer(unsigned(distance)))
            severity error;
        report "Distance after 1m echo pulse: " & integer'image(to_integer(unsigned(distance)));

        -- Wait for second trigger pulse
        wait until trig = '1';
        wait until trig = '0';

        -- Simulate echo pulse for 0.5m distance (~2910us)
        echo <= '1';
        wait for 2910 us;
        echo <= '0';
        wait for 1 us; -- Wait for distance to update
        -- Verify distance (~500 mm)
        assert (unsigned(distance) > 490 and unsigned(distance) < 510)
            report "Distance incorrect for 0.5m echo pulse, expected ~500 mm, got " & integer'image(to_integer(unsigned(distance)))
            severity error;
        report "Distance after 0.5m echo pulse: " & integer'image(to_integer(unsigned(distance)));

        -- Wait for third trigger pulse to test timeout
        wait until trig = '1';
        wait until trig = '0';
        -- No echo pulse (simulate sensor disconnected)
        wait for 60 ms; -- Should trigger timeout after 50ms
        -- Verify distance resets to 0
        assert (unsigned(distance) = 0)
            report "Distance did not reset to 0 on timeout, got " & integer'image(to_integer(unsigned(distance)))
            severity error;
        report "Distance after timeout (should be 0): " & integer'image(to_integer(unsigned(distance)));

        -- Run for a total of 200ms
        wait for 200 ms - (3 * 60 ms + 5820 us + 2910 us + 40 ns + 2 us);

        -- End simulation
        report "Simulation completed successfully";
        wait;
    end process;

end Behavioral;