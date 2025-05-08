-- File: ultrasonic_top.vhd
-- Top-level entity for HC-SR04 ultrasound sensor controller with distance output
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ultrasonic_top is
    Port (
        clk         : in  STD_LOGIC;  -- 100 MHz board clock
        reset       : in  STD_LOGIC;  -- Active-high reset
        echo        : in  STD_LOGIC;  -- Echo signal from HC-SR04
        trig        : out STD_LOGIC;  -- Trigger signal to HC-SR04
        seg         : out STD_LOGIC_VECTOR(6 downto 0); -- 7-segment cathodes
        an          : out STD_LOGIC_VECTOR(3 downto 0);  -- 7-segment anodes
        distance    : out STD_LOGIC_VECTOR(15 downto 0) -- Distance in mm
    );
end ultrasonic_top;

architecture Behavioral of ultrasonic_top is
    -- Component declarations
    component trigger_gen
        Port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            trig    : out STD_LOGIC
        );
    end component;

    component echo_proc
        Port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            echo    : in  STD_LOGIC;
            distance: out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component disp_ctrl
        Port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            distance: in  STD_LOGIC_VECTOR(15 downto 0);
            seg     : out STD_LOGIC_VECTOR(6 downto 0);
            an      : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Internal signals
    signal distance_int : STD_LOGIC_VECTOR(15 downto 0);

begin
    -- Instantiate components
    TRIG_GEN_INST: trigger_gen
        port map (
            clk   => clk,
            reset => reset,
            trig  => trig
        );

    ECHO_PROC_INST: echo_proc
        port map (
            clk      => clk,
            reset    => reset,
            echo     => echo,
            distance => distance_int
        );

    DISP_CTRL_INST: disp_ctrl
        port map (
            clk      => clk,
            reset    => reset,
            distance => distance_int,
            seg      => seg,
            an       => an
        );

    -- Map internal distance to output port
    distance <= distance_int;

end Behavioral;