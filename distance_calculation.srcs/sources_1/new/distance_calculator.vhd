library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity distance_calculator is
    Port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        echo_time     : in  unsigned(31 downto 0);
        distance_cm   : out std_logic_vector(15 downto 0)
    );
end distance_calculator;

architecture Behavioral of distance_calculator is
    signal temp_distance : unsigned(31 downto 0);  -- intermediate for division
begin
    process(clk, rst)
           variable temp_distance : unsigned(31 downto 0);
    begin
        if rst = '1' then
            distance_cm <= (others => '0');
        elsif rising_edge(clk) then
            temp_distance := echo_time / to_unsigned(5800, echo_time'length);
            distance_cm <= std_logic_vector(temp_distance(15 downto 0));
        end if;
    end process;
end Behavioral;
