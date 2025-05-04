library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity distance_calculator is
    Port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        echo_time     : in  unsigned(31 downto 0);
        distance_cm   : out std_logic_vector(15 downto 0);
        valid         : out std_logic  -- one-cycle pulse when new distance is ready
    );
end distance_calculator;

architecture Behavioral of distance_calculator is
    signal result    : unsigned(15 downto 0) := (others => '0');
    signal valid_reg : std_logic := '0';
begin
    process(clk)
        variable temp_distance : unsigned(31 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                result    <= (others => '0');
                valid_reg <= '0';
            else
                temp_distance := echo_time / to_unsigned(5800, 32);
                result        <= temp_distance(15 downto 0);
                valid_reg     <= '1';
            end if;
        end if;
    end process;

    distance_cm <= std_logic_vector(result);
    valid       <= valid_reg;
end Behavioral;
