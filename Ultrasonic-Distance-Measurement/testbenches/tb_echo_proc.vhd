library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity echo_proc_tb is
end echo_proc_tb;

architecture Behavioral of echo_proc_tb is
    component echo_proc
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            echo     : in  STD_LOGIC;
            distance : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal echo     : STD_LOGIC := '0';
    signal distance : STD_LOGIC_VECTOR(15 downto 0);

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

begin
    uut: echo_proc
        port map (
            clk      => clk,
            reset    => reset,
            echo     => echo,
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

        -- Test 1m distance (5820us echo pulse)
        echo <= '1';
        wait for 5820 us;
        echo <= '0';
        wait for 1 us;
        assert (unsigned(distance) > 990 and unsigned(distance) < 1010)
            report "Distance incorrect for 1m, expected ~1000mm, got " & integer'image(to_integer(unsigned(distance)))
            severity error;

        -- Test 0.5m distance (2910us echo pulse)
        echo <= '1';
        wait for 2910 us;
        echo <= '0';
        wait for 1 us;
        assert (unsigned(distance) > 490 and unsigned(distance) < 510)
            report "Distance incorrect for 0.5m, expected ~500mm, got " & integer'image(to_integer(unsigned(distance)))
            severity error;

        -- Test timeout (no echo for 60ms)
        wait for 60 ms;
        assert unsigned(distance) = 0
            report "Distance should be 0 on timeout, got " & integer'image(to_integer(unsigned(distance)))
            severity error;

        -- End simulation
        report "Echo_proc_tb completed";
        wait;
    end process;

end Behavioral;