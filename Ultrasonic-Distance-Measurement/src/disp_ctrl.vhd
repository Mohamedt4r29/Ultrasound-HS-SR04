-- File: disp_ctrl.vhd
-- Converts distance to BCD and drives 7-segment display
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp_ctrl is
    Port (
        clk      : in  STD_LOGIC;  -- 100 MHz clock
        reset    : in  STD_LOGIC;  -- Active-high reset
        distance : in  STD_LOGIC_VECTOR(15 downto 0); -- Distance in mm
        seg      : out STD_LOGIC_VECTOR(6 downto 0);  -- 7-segment cathodes (a-g)
        an       : out STD_LOGIC_VECTOR(3 downto 0)   -- 7-segment anodes
    );
end disp_ctrl;

architecture Behavioral of disp_ctrl is
    -- Constants
    constant CLK_FREQ     : integer := 100_000_000; -- 100 MHz
    constant REFRESH_RATE : integer := 100_000;     -- 1ms per digit (1kHz refresh)
    
    -- Signals for BCD conversion
    signal bcd_digits : STD_LOGIC_VECTOR(15 downto 0); -- 4 BCD digits (4 bits each)
    signal digit_sel  : unsigned(1 downto 0) := "00";  -- Selects current digit
    signal refresh_count : unsigned(16 downto 0) := (others => '0'); -- Refresh counter
    
    -- 7-segment patterns (active-low)
    type seg_array is array (0 to 9) of STD_LOGIC_VECTOR(6 downto 0);
    constant SEG_PATTERNS : seg_array := (
        "0000001", -- 0
        "1001111", -- 1
        "0010010", -- 2
        "0000110", -- 3
        "1001100", -- 4
        "0100100", -- 5
        "0100000", -- 6
        "0001111", -- 7
        "0000000", -- 8
        "0000100"  -- 9
    );

begin
    -- Binary to BCD conversion (double-dabble algorithm)
    process(clk)
        variable distance_var : unsigned(15 downto 0);
        variable bcd         : unsigned(15 downto 0) := (others => '0');
        variable i           : integer;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                bcd_digits <= (others => '0');
            else
                -- Initialize
                distance_var := unsigned(distance);
                bcd := (others => '0');
                
                -- Double-dabble algorithm
                for i in 0 to 15 loop
                    if bcd(3 downto 0) > 4 then
                        bcd(3 downto 0) := bcd(3 downto 0) + 3;
                    end if;
                    if bcd(7 downto 4) > 4 then
                        bcd(7 downto 4) := bcd(7 downto 4) + 3;
                    end if;
                    if bcd(11 downto 8) > 4 then
                        bcd(11 downto 8) := bcd(11 downto 8) + 3;
                    end if;
                    if bcd(15 downto 12) > 4 then
                        bcd(15 downto 12) := bcd(15 downto 12) + 3;
                    end if;
                    bcd := bcd sll 1;
                    bcd(0) := distance_var(15);
                    distance_var := distance_var sll 1;
                end loop;
                
                bcd_digits <= STD_LOGIC_VECTOR(bcd);
            end if;
        end if;
    end process;

    -- Refresh counter for multiplexing
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                refresh_count <= (others => '0');
                digit_sel <= "00";
            else
                if refresh_count < REFRESH_RATE - 1 then
                    refresh_count <= refresh_count + 1;
                else
                    refresh_count <= (others => '0');
                    digit_sel <= digit_sel + 1;
                end if;
            end if;
        end if;
    end process;

    -- Multiplexing and segment driving
    process(digit_sel, bcd_digits)
        variable digit : STD_LOGIC_VECTOR(3 downto 0);
    begin
        -- Select anode (active-low)
        an <= "1111"; -- Default: all digits off
        case digit_sel is
            when "00" => an <= "1110"; digit := bcd_digits(3 downto 0);   -- Digit 0
            when "01" => an <= "1101"; digit := bcd_digits(7 downto 4);   -- Digit 1
            when "10" => an <= "1011"; digit := bcd_digits(11 downto 8);  -- Digit 2
            when "11" => an <= "0111"; digit := bcd_digits(15 downto 12); -- Digit 3
            when others => an <= "1111"; digit := "0000";
        end case;
        
        -- Drive segments based on BCD digit
        seg <= SEG_PATTERNS(to_integer(unsigned(digit)));
    end process;

end Behavioral;