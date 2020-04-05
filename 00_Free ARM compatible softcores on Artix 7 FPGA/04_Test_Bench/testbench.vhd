-- #######################################################
-- #     < STORM Core Processor by Stephan Nolting >     #
-- # *************************************************** #
-- #        STORM Core / STORM Demo SoC Testbench        #
-- # *************************************************** #
-- # Last modified: 04.03.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--library work;
--use work.STORM_core_package.all;

entity TOP_STORM_core_TB is
end TOP_STORM_core_TB;

architecture Structure of TOP_STORM_core_TB is

component TOP_STORM_core is
port (
		MAIN_RST        : in STD_LOGIC;
		MAIN_CLK        : in STD_LOGIC;
		START           : in STD_LOGIC;
        STOP            : in STD_LOGIC;
        STEP            : in STD_LOGIC;
--        up            : in STD_LOGIC;
--        down            : in STD_LOGIC;
        lcd_e           : out STD_LOGIC;
        lcd_rs : out std_logic;
        lcd_db : out std_logic_vector(7 downto 4)
	);
end component;

        signal MAIN_RST        : STD_LOGIC;
		signal MAIN_CLK        : STD_LOGIC := '0';
		signal START           : STD_LOGIC;
        signal STOP            : STD_LOGIC;
        signal STEP            : STD_LOGIC;
--        signal up              : STD_LOGIC;
--        signal down            : STD_LOGIC;
        signal lcd_e           : STD_LOGIC;
        signal lcd_rs          : STD_LOGIC;
        signal lcd_db          : std_logic_vector(7 downto 4);


begin

	-- Clock Generator --
		MAIN_CLK <= not MAIN_CLK after 20 ns; -- 50MHz

		-- Reset System --
		MAIN_RST <= '0', '1' after 600 ns; -- '1' after 28000 ns, '0' after 30000 ns;
		
		-- Interrupt Generator --
--		IRQ_I <= '0', '1' after 2000 ns, '0' after 2020 ns;
--		FIQ_I <= '0';
		
		START <= '1','0' after 800 ns;--, '0' after 55000 ns; -- '1' after 30000 ns;
		STOP  <= '1';--,'1' after 55000 ns; -- '0' after 30000 ns;
		STEP <= '0';
--		up <= '1';
--		down <= '0';


STORM_COMPLETE_CORE : TOP_STORM_core port map (
			MAIN_CLK 	=> MAIN_CLK,
			MAIN_RST 	=> MAIN_RST,
            STEP        => STEP,
			START		=> START,
			STOP    	=> STOP,
--			up         => up,
--			down   => down,
			lcd_e       => lcd_e,
			lcd_rs      => lcd_rs,
			lcd_db      => lcd_db
			);

		
end Structure;