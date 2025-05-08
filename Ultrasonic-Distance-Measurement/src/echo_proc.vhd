-- File: echo_proc.vhd
-- Measures echo pulse width and converts to distance in mm, with timeout
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity echo_proc is
    Port (
        clk      : in  STD_LOGIC;  -- 100 MHz clock
        reset    : in  STD_LOGIC;  -- Active-high reset
        echo     : in  STD_LOGIC;  -- Echo signal
        distance : out STD_LOGIC_VECTOR(15 downto 0) -- Distance in mm
    );
end echo_proc;

architecture Behavioral of echo_proc is
    constant CLK_FREQ    : integer := 100_000_000; -- 100 MHz
    constant TIMEOUT     : integer := 5_000_000;   -- 50ms timeout (max range ~8.5m)
    signal echo_prev    : STD_LOGIC := '0';
    signal count        : unsigned(31 downto 0) := (others => '0');
    signal timeout_count: unsigned(22 downto 0) := (others => '0'); -- For 50ms
    signal distance_reg : unsigned(15 downto 0) := (others => '0');
    signal measuring    : STD_LOGIC := '0';

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count <= (others => '0');
                timeout_count <= (others => '0');
                distance_reg <= (others => '0');
                measuring <= '0';
                echo_prev <= '0';
            else
                echo_prev <= echo;

                -- Start measuring on echo rising edge
                if echo = '1' and echo_prev = '0' then
                    count <= (others => '0');
                    timeout_count <= (others => '0');
                    measuring <= '1';
                end if;

                -- Stop measuring on echo falling edge or timeout
                if (echo = '0' and echo_prev = '1') or (timeout_count >= TIMEOUT) then
                    measuring <= '0';
                    if timeout_count >= TIMEOUT then
                        distance_reg <= (others => '0'); -- Reset distance on timeout
                    else
                        -- Convert echo pulse width to distance
                        -- Distance (mm) = (pulse width in us) * 0.1715
                        -- For 100 MHz clock, 1 us = 100 ticks
                        -- Approximation: distance = count / 583 (derived from speed of sound)
                        distance_reg <= resize(count / 583, 16);
                    end if;
                end if;

                -- Count while echo is high
                if measuring = '1' then
                    count <= count + 1;
                    timeout_count <= timeout_count + 1;
                end if;
            end if;
        end if;
    end process;

    distance <= STD_LOGIC_VECTOR(distance_reg);

end Behavioral;