library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity echo_detector is
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        echo        : in std_logic;
        echo_start  : out std_logic;
        echo_end    : out std_logic;
        echo_time   : out unsigned(31 downto 0)
    );
end echo_detector;

architecture Behavioral of echo_detector is
    signal prev_echo  : std_logic := '0';
    signal counting   : std_logic := '0';
    signal counter    : unsigned(31 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            echo_start <= '0';
            echo_end <= '0';
            echo_time <= (others => '0');
            prev_echo <= '0';
            counter <= (others => '0');
            counting <= '0';
        elsif rising_edge(clk) then
            prev_echo <= echo;
            echo_start <= '0';
            echo_end <= '0';

            if prev_echo = '0' and echo = '1' then  -- rising edge
                echo_start <= '1';
                counter <= (others => '0');
                counting <= '1';
            elsif prev_echo = '1' and echo = '0' then -- falling edge
                echo_end <= '1';
                echo_time <= counter;
                counting <= '0';
            elsif counting = '1' then
                counter <= counter + 1;
            end if;
        end if;
    end process;

end Behavioral;
