library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_trigger_generator is
end tb_trigger_generator;

architecture behavior of tb_trigger_generator is
    -- Component Declaration for the Unit Under Test (UUT)
    component trigger_generator
        Port (
            clk     : in std_logic;
            rst     : in std_logic;
            trigger : out std_logic
        );
    end component;

    -- Signals to connect to the UUT
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal trigger : std_logic;

    -- Clock period definition
    constant clk_period : time := 20 ns;  -- 50 MHz clock

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: trigger_generator
        Port map (
            clk => clk,
            rst => rst,
            trigger => trigger
        );

    -- Clock generation process
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize signals
        rst <= '1';
        wait for 40 ns;  -- Assert reset for a few clock cycles

        rst <= '0';
        wait for 200 ns;  -- Wait for a few clock cycles

        -- Add more test cases as needed
        wait for 400 ns;

        -- Apply reset again to see the behavior
        rst <= '1';
        wait for 40 ns;  -- Assert reset for a few clock cycles

        rst <= '0';
        wait for 500 ns;

        -- End the simulation after some time
        wait;
    end process;

end behavior;
