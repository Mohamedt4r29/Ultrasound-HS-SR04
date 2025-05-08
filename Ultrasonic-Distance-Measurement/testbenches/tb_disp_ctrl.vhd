library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp_ctrl_tb is
end disp_ctrl_tb;

architecture Behavioral of disp_ctrl_tb is
    component disp_ctrl
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            distance : in  STD_LOGIC_VECTOR(15 downto 0);
            seg      : out STD_LOGIC_VECTOR(6 downto 0);
            an       : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal distance : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal seg      : STD_LOGIC_VECTOR(6 downto 0);
    signal an       : STD_LOGIC_VECTOR(3 downto 0);

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

begin
    uut: disp_ctrl
        port map (
            clk      => clk,
            reset    => reset,
            distance => distance,
            seg      => seg,
            an       => an
        );

    -- Clock process
    clk_process: process
    begin
        wait for CLK_PERIOD / 2;
        clk <= not clk;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- Test 1: Distance = 1234 mm 
        distance <= STD_LOGIC_VECTOR(to_unsigned(1234, 16));
        wait for 5 ms; -- Allow multiplexing to cycle
        -- Check digit 0 (4)
        assert an = "1110" and seg = "1001100" report "Digit 0 incorrect for 1234, expected 4" severity error;
        wait for 1 ms;
        -- Check digit 1 (3)
        assert an = "1101" and seg = "0000110" report "Digit 1 incorrect for 1234, expected 3" severity error;
        wait for 1 ms;
        -- Check digit 2 (2)
        assert an = "1011" and seg = "0010010" report "Digit 2 incorrect for 1234, expected 2" severity error;
        wait for 1 ms;
        -- Check digit 3 (1)
        assert an = "0111" and seg = "1001111" report "Digit 3 incorrect for 1234, expected 1" severity error;

        -- Test 2: Distance = 0 mm 
        distance <= (others => '0');
        wait for 5 ms;
        -- Check digit 0 (0)
        assert an = "1110" and seg = "0000001" report "Digit 0 incorrect for 0, expected 0" severity error;
        wait for 1 ms;
        -- Check digit 1 (0)
        assert an = "1101" and seg = "0000001" report "Digit 1 incorrect for 0, expected 0" severity error;

        -- Test 3: Maximum displayable distance = 9999 mm
        distance <= STD_LOGIC_VECTOR(to_unsigned(9999, 16));
        wait for 5 ms;
        -- Check digit 0 (9)
        assert an = "1110" and seg = "0000100" report "Digit 0 incorrect for 9999, expected 9" severity error;
        wait for 1 ms;
        -- Check digit 1 (9)
        assert an = "1101" and seg = "0000100" report "Digit 1 incorrect for 9999, expected 9" severity error;
        wait for 1 ms;
        -- Check digit 2 (9)
        assert an = "1011" and seg = "0000100" report "Digit 2 incorrect for 9999, expected 9" severity error;
        wait for 1 ms;
        -- Check digit 3 (9)
        assert an = "0111" and seg = "0000100" report "Digit 3 incorrect for 9999, expected 9" severity error;

        -- Test 4: Single-digit distance = 5 mm 
        distance <= STD_LOGIC_VECTOR(to_unsigned(5, 16));
        wait for 5 ms;
        -- Check digit 0 (5)
        assert an = "1110" and seg = "0100100" report "Digit 0 incorrect for 5, expected 5" severity error;
        wait for 1 ms;
        -- Check digit 1 (0)
        assert an = "1101" and seg = "0000001" report "Digit 1 incorrect for 5, expected 0" severity error;
        wait for 1 ms;
        -- Check digit 2 (0)
        assert an = "1011" and seg = "0000001" report "Digit 2 incorrect for 5, expected 0" severity error;
        wait for 1 ms;
        -- Check digit 3 (0)
        assert an = "0111" and seg = "0000001" report "Digit 3 incorrect for 5, expected 0" severity error;

        -- Test 5: Mid-range distance = 2500 mm
        distance <= STD_LOGIC_VECTOR(to_unsigned(2500, 16));
        wait for 5 ms;
        -- Check digit 0 (0)
        assert an = "1110" and seg = "0000001" report "Digit 0 incorrect for 2500, expected 0" severity error;
        wait for 1 ms;
        -- Check digit 1 (0)
        assert an = "1101" and seg = "0000001" report "Digit 1 incorrect for 2500, expected 0" severity error;
        wait for 1 ms;
        -- Check digit 2 (5)
        assert an = "1011" and seg = "0100100" report "Digit 2 incorrect for 2500, expected 5" severity error;
        wait for 1 ms;
        -- Check digit 3 (2)
        assert an = "0111" and seg = "0010010" report "Digit 3 incorrect for 2500, expected 2" severity error;

        -- Test 6: Overflow distance = 15000 mm (beyond 9999 mm, should truncate to 5000 mm due to 4-digit limit)
        distance <= STD_LOGIC_VECTOR(to_unsigned(15000, 16));
        wait for 5 ms;
        -- Check digit 0 (0)
        assert an = "1110" and seg = "0000001" report "Digit 0 incorrect for 15000, expected 0 (truncate to 5000)" severity error;
        wait for 1 ms;
        -- Check digit 1 (0)
        assert an = "1101" and seg = "0000001" report "Digit 1 incorrect for 15000, expected 0 (truncate to 5000)" severity error;
        wait for 1 ms;
        -- Check digit 2 (0)
        assert an = "1011" and seg = "0000001" report "Digit 2 incorrect for 15000, expected 0 (truncate to 5000)" severity error;
        wait for 1 ms;
        -- Check digit 3 (5)
        assert an = "0111" and seg = "0100100" report "Digit 3 incorrect for 15000, expected 5 (truncate to 5000)" severity error;

        -- End simulation after 40 ms
        wait for 40 ms - (6 * 5 ms + 8 * 1 ms + 40 ns);
        report "Disp_ctrl_tb completed";
        wait;
    end process;

end Behavioral;