library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity trig_pulse is
    generic (
        PULSE_WIDTH_CYCLES : integer := 20000 -- 20us pulse for 100MHz clock (10ns period)
    );
    Port ( 
        clk       : in  std_logic;
        rst       : in  std_logic;
        start     : in  std_logic;
        trig_p  : out std_logic
    );
end trig_pulse;

architecture Behavioral of trig_pulse is

    type state_type is (IDLE, PULSE_ACTIVE);
    signal state : state_type := IDLE;
    signal counter : integer range 0 to PULSE_WIDTH_CYCLES := 0;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            trig_p <= '0';
            counter <= 0;
            state <= IDLE;
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    trig_p <= '0';
                    if start = '1' then
                        state <= PULSE_ACTIVE;
                        counter <= 0;
                    end if;

                when PULSE_ACTIVE =>
                    trig_p <= '1';
                    if counter = PULSE_WIDTH_CYCLES - 1 then
                        state <= IDLE;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
