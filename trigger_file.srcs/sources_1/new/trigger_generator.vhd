library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity trigger_generator is
    Port (
        clk     : in std_logic;
        rst     : in std_logic;
        trigger : out std_logic
    );
end trigger_generator;

architecture Behavioral of trigger_generator is
    constant PULSE_WIDTH : integer := 10000;    -- 100 µs
    constant PERIOD      : integer := 1_000_000; -- 10 ms

    signal count         : integer range 0 to PERIOD := 0;
    signal trigger_reg   : std_logic := '0';  -- Registered trigger signal
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count <= 0;
                trigger_reg <= '0';
            else
                if count < PERIOD - 1 then
                    count <= count + 1;
                else
                    count <= 0;
                end if;

                if count < PULSE_WIDTH then
                    trigger_reg <= '1';
                else
                    trigger_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Drive the registered output trigger signal
    trigger <= trigger_reg;
end Behavioral;
