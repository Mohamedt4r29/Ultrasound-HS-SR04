library ieee;
use ieee.std_logic_1164.all;

entity tb_trig_pulse is
end tb_trig_pulse;

architecture tb of tb_trig_pulse is

    component trig_pulse
	generic (
		PULSE_WIDTH : integer
        );
        port (start    : in std_logic;
              trig_out : out std_logic;
              clk      : in std_logic;
              rst      : in std_logic);
    end component;

	--constant C_PULSE_WIDTH : integer := 10;

    signal start    : std_logic;
    signal trig_out : std_logic;
    signal clk      : std_logic;
    signal rst      : std_logic;

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : trig_pulse
    generic map (
	PULSE_WIDTH => 10
    )
    port map (start    => start,
              trig_out => trig_out,
              clk      => clk,
              rst      => rst);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        start <= '0';

         -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 2 * TbPeriod;
        rst <= '0';
        wait for 2 * TbPeriod;
        -- EDIT Add stimuli here
        start <= '1';
        wait for 0.5 * TbPeriod;
        start <= '0';
        wait for 30 * TbPeriod;
        start <= '1';
        wait for 0.5 * TbPeriod;
        start <= '0';
        wait for 5 * TbPeriod;
        rst <= '1';	-- reset test
        wait for 2 * TbPeriod;
        rst <= '0';
        wait for 30 * TbPeriod;
        start <= '1';
        wait for 0.5 * TbPeriod;
        start <= '0';
        wait for 30 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_trig_pulse of tb_trig_pulse is
    for tb
    end for;
end cfg_tb_trig_pulse;