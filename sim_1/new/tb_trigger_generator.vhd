library ieee;
use ieee.std_logic_1164.all;

entity tb_trig_pulse is
end tb_trig_pulse;

architecture tb of tb_trig_pulse is

    component trig_pulse
        generic (
            PULSE_WIDTH_CYCLES : integer := 200
        );
        port (
            clk       : in std_logic;
            rst       : in std_logic;
            start     : in std_logic;
            trig_p  : out std_logic
        );
    end component;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal start     : std_logic := '0';
    signal trig_p  : std_logic;

    constant TbPeriod : time := 10 ns; -- 100MHz clock
    signal TbSimEnded : std_logic := '0';

begin

    -- DUT instantiation
    dut: trig_pulse
        generic map (
            PULSE_WIDTH_CYCLES => 2000
        )
        port map (
            clk      => clk,
            rst      => rst,
            start    => start,
            trig_p => trig_p
        );

    -- Clock generation
    clk <= not clk after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- Stimulus process
    stim_proc: process
    begin
        -- Apply reset
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;

        -- Trigger first pulse
        start <= '1';
        wait for 10 ns;
        start <= '0';

        wait for 500 us;

        -- Trigger second pulse
        start <= '1';
        wait for 10 ns;
        start <= '0';

        wait for 1 ms;

        -- End simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
