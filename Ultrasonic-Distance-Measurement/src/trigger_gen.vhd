-- File: trigger_gen.vhd
-- This file makes a trigger pulse for the HC-SR04 sensor
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity trigger_gen is
    generic (
        TRIG_PERIOD : integer := 6_000_000  -- Default 60ms period 
    );
    Port (
        clk     : in  STD_LOGIC;  -- This is the 100 MHz clock from the FPGA
        reset   : in  STD_LOGIC;  
        trig    : out STD_LOGIC   -- This sends a 10us pulse to the sensor
    );
end trigger_gen;

architecture Behavioral of trigger_gen is
    constant CLK_FREQ     : integer := 100_000_000; -- Clock is 100 MHz
    constant TRIG_WIDTH  : integer := 1_000;       -- Pulse length (10us)
    signal count         : unsigned(22 downto 0) := (others => '0'); -- Counts cycles
    signal trig_int      : STD_LOGIC := '0'; -- Internal signal for the pulse

begin
    process(clk) -- run every clock tick
    begin
        if rising_edge(clk) then -- Check when clock goes high
            if reset = '1' then -- If reset button is pressed
                count <= (others => '0'); -- Reset the counter to 0
                trig_int <= '0'; -- Turn off the pulse
            else
                if count < TRIG_PERIOD - 1 then -- If not time for new pulse
                    count <= count + 1; -- Add 1 to the counter
                else
                    count <= (others => '0'); -- Reset counter after TRIG_PERIOD
                end if;

                if count < TRIG_WIDTH then -- If within 10us
                    trig_int <= '1'; -- Turn on the pulse
                else
                    trig_int <= '0'; -- Turn off the pulse
                end if;
            end if;
        end if;
    end process;

    trig <= trig_int; -- Send the pulse to the output

end Behavioral;