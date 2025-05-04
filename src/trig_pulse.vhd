library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity trig_pulse is
	Generic (
		PULSE_WIDTH : integer := 2000 -- sirka pulzu: clk * PULSE_WIDTH
	); -- 2000 = sirka pulzu 20 us pri clk = 100 MHz

	Port ( 
		start		: in STD_LOGIC;
		trig_out	: out STD_LOGIC; -- := '0';
		clk		: in std_logic;
		rst		: in std_logic
	);
end trig_pulse;

architecture Behavioral of trig_pulse is
	-- vnutorne signaly
	signal sig_count : integer range 0 to 100_000; -- := 0; -- max 1 ms
	signal start_pulse : std_logic; -- := '0';
	
    begin
	pulse : process(clk) is
		begin
			if (start = '1') then -- zaciatok pocitania a generovania pulzu
				start_pulse <= '1';
			end if;
    
			if (rising_edge(clk)) then -- kazdu nabeznu hranu hodinovej periody
				if (rst = '1') then -- reset - vynulovanie "vsetkeho"
					trig_out <= '0';
					start_pulse <= '0';
					sig_count <= 0;
				elsif (start_pulse = '1') then -- generuj pulz sirky PULSE_WIDTH
					if (sig_count = PULSE_WIDTH) then -- koniec generovania
						trig_out <= '0';
						start_pulse <= '0';
						sig_count <= 0;
					else -- pocitanie
						trig_out <= '1';
						sig_count <= sig_count + 1;
					end if;
				end if;
			end if;
		end process;
end Behavioral;
