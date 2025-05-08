library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity trigger_gen_tb is
end trigger_gen_tb;

architecture Behavioral of trigger_gen_tb is
    component trigger_gen
        Port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            trig  : out STD_LOGIC
        );
    end component;

    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal trig  : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

begin
    uut: trigger_gen
        port map (
            clk   => clk,
            reset => reset,
            trig  => trig
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

        -- Check first trigger pulse
        wait until trig = '1';
        wait for 5 ns;
        assert trig = '1' report "Trigger should be high for 10us" severity error;
        wait until trig = '0';
        assert now >= 10 us report "Trigger pulse width should be ~10us" severity error;

        -- Wait for next trigger 60ms
        wait for 59 ms;
        wait until trig = '1';
        wait for 5 ns;
        assert trig = '1' report "Trigger should be high" severity error;
        wait until trig = '0';
        assert now >= 60 ms report "Trigger period should be ~60ms" severity error;

        -- End simulation
        report "Trigger_gen_tb completed";
        wait;
    end process;

end Behavioral;