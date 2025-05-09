-- File: disp_ctrl.vhd
-- Converts a distance value to BCD and drives a 4-digit 7-segment display
library IEEE;                    
use IEEE.STD_LOGIC_1164.ALL;     
use IEEE.NUMERIC_STD.ALL;        

entity disp_ctrl is
    Port (
        clk      : in  STD_LOGIC;  -- Input: 100 MHz clock signal to time everything
        reset    : in  STD_LOGIC;  -- Input: Active-high reset to clear the display
        distance : in  STD_LOGIC_VECTOR(15 downto 0); -- Input: Distance in mm (16-bit binary)
        seg      : out STD_LOGIC_VECTOR(6 downto 0);  -- Output: 7-segment cathodes (a-g patterns)
        an       : out STD_LOGIC_VECTOR(3 downto 0)   -- Output: 4-bit anode control for each digit
    );
end disp_ctrl;

architecture Behavioral of disp_ctrl is
    -- Constants for timing
    constant CLK_FREQ     : integer := 100_000_000; -- Constant: Clock frequency (100 MHz)
    constant REFRESH_RATE : integer := 100_000;     -- Constant: Ticks for 1 ms (100 MHz / 1 kHz)

    -- Signals for BCD conversion and multiplexing
    signal bcd_digits : STD_LOGIC_VECTOR(15 downto 0); -- Signal: Stores 4 BCD digits (4 bits each)
    signal digit_sel  : unsigned(1 downto 0) := "00";  -- Signal: Selects which digit to show (0-3)
    signal refresh_count : unsigned(16 downto 0) := (others => '0'); -- Signal: Counts ticks for refresh

    -- Define 7-segment patterns (active-low, 0 = segment on)
    type seg_array is array (0 to 9) of STD_LOGIC_VECTOR(6 downto 0); -- Type: Array for digit patterns
    constant SEG_PATTERNS : seg_array := (
        "0000001", -- Pattern for 0: All segments except g on
        "1001111", -- Pattern for 1: Only b and c on
        "0010010", -- Pattern for 2: Segments a, b, d, e, g on
        "0000110", -- Pattern for 3: Segments a, b, c, d, g on
        "1001100", -- Pattern for 4: Segments b, c, f, g on
        "0100100", -- Pattern for 5: Segments a, c, d, f, g on
        "0100000", -- Pattern for 6: All except b on
        "0001111", -- Pattern for 7: Segments a, b, c on
        "0000000", -- Pattern for 8: All segments on
        "0000100"  -- Pattern for 9: Segments a, b, c, f, g on
    );

begin
    -- Process for converting binary distance to BCD (double-dabble algorithm)
    process(clk)
        variable distance_var : unsigned(15 downto 0); -- Temp variable: Holds input distance
        variable bcd         : unsigned(15 downto 0) := (others => '0'); -- Temp variable: Builds BCD
        variable i           : integer;              -- Loop counter for 16 bits
    begin
        if rising_edge(clk) then                     -- Run when clock ticks up
            if reset = '1' then                     -- If reset is high
                bcd_digits <= (others => '0');      -- Clear BCD digits to 0000
            else                                    -- Normal operation
                -- Initialize variables
                distance_var := unsigned(distance); -- Convert input to unsigned
                bcd := (others => '0');             -- Start BCD as all zeros
                
                -- Double-dabble conversion
                for i in 0 to 15 loop              -- Loop 16 times for 16-bit distance
                    if bcd(3 downto 0) > 4 then   -- Check first digit
                        bcd(3 downto 0) := bcd(3 downto 0) + 3; -- Adjust if > 4
                    end if;
                    if bcd(7 downto 4) > 4 then   -- Check second digit
                        bcd(7 downto 4) := bcd(7 downto 4) + 3; -- Adjust if > 4
                    end if;
                    if bcd(11 downto 8) > 4 then  -- Check third digit
                        bcd(11 downto 8) := bcd(11 downto 8) + 3; -- Adjust if > 4
                    end if;
                    if bcd(15 downto 12) > 4 then -- Check fourth digit
                        bcd(15 downto 12) := bcd(15 downto 12) + 3; -- Adjust if > 4
                    end if;
                    bcd := bcd sll 1;             -- Shift BCD left by 1
                    bcd(0) := distance_var(15);   -- Add highest bit of distance
                    distance_var := distance_var sll 1; -- Shift distance left
                end loop;
                
                bcd_digits <= STD_LOGIC_VECTOR(bcd); -- Save final BCD value
            end if;
        end if;
    end process;

    -- Process for managing refresh rate and digit selection
    process(clk)
    begin
        if rising_edge(clk) then                     -- Run when clock ticks up
            if reset = '1' then                     -- If reset is high
                refresh_count <= (others => '0');   -- Reset refresh counter
                digit_sel <= "00";                  -- Reset to first digit
            else                                    -- Normal operation
                if refresh_count < REFRESH_RATE - 1 then -- If not at 1 ms yet
                    refresh_count <= refresh_count + 1; -- Increment counter
                else                                -- If 1 ms has passed
                    refresh_count <= (others => '0'); -- Reset counter
                    digit_sel <= digit_sel + 1;     -- Move to next digit
                end if;
            end if;
        end if;
    end process;

    -- Process for multiplexing and driving the display
    process(digit_sel, bcd_digits)
        variable digit : STD_LOGIC_VECTOR(3 downto 0); -- Temp variable: Holds current digit value
    begin
        -- Default state: All digits off
        an <= "1111";                             -- Turn off all anodes (active-low)
        case digit_sel is                         -- Based on current digit selection
            when "00" => an <= "1110"; digit := bcd_digits(3 downto 0);   -- Digit 0 on
            when "01" => an <= "1101"; digit := bcd_digits(7 downto 4);   -- Digit 1 on
            when "10" => an <= "1011"; digit := bcd_digits(11 downto 8);  -- Digit 2 on
            when "11" => an <= "0111"; digit := bcd_digits(15 downto 12); -- Digit 3 on
            when others => an <= "1111"; digit := "0000"; -- Default: All off
        end case;
        
        -- Set segment pattern for the selected digit
        seg <= SEG_PATTERNS(to_integer(unsigned(digit))); -- Convert digit to segment pattern
    end process;

end Behavioral;
