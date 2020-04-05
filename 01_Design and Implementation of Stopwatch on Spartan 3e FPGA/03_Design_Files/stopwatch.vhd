--------------------------------------------------------------------------
-- Company: TU Chemnitz
-- Engineer1: Shanmugapriyan Manoharan
-- Engineer2: Sheela Rachel Anthony
-- Module Name: Stopwatch
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stopwatch is

    Port ( 
			clk 		: in  STD_LOGIC;
       	reset		: in  STD_LOGIC;
      	key1 		: in  STD_LOGIC;
      	key2 		: in  STD_LOGIC;
       	hex1 		: out  STD_LOGIC_VECTOR (3 downto 0);
       	hex2 		: out  STD_LOGIC_VECTOR (3 downto 0);
       	hex3 		: out  STD_LOGIC_VECTOR (3 downto 0);
       	hex4 		: out  STD_LOGIC_VECTOR (3 downto 0)
       	);
end stopwatch;


architecture Behavioral of stopwatch is

type states is (init, run, halt);
signal state     : states := init;
signal nextState : states;

signal clk_1sec : std_logic := '0';

signal s0 : integer range 0 to 9;
signal s1 : integer range 0 to 5;
signal m0 : integer range 0 to 9;
signal m1 : integer range 0 to 5;


signal key1Pressed : integer range 0 to 2;
signal initialzero : std_logic;
signal startcounting : std_logic;
signal clk_count : integer range 0 to 10000000 := 0;

begin


clk_div_1sec : process (reset, initialzero, clk)
begin
	if (reset = '0' or initialzero = '1') then
   		clk_count	<= 0;
   		clk_1sec	<= '0';
	elsif (rising_edge(clk)) then
	  if startcounting = '1' then
		if clk_count = 10000000 then -- testbench clk_count = 20 and for hardware clk_count = 10000000
			clk_1sec 	<= NOT clk_1sec;
			clk_count	<= 0;
		else
			clk_count <= clk_count + 1;
		end if;
	end if;
	end if;
end process;


process(reset, key1)
begin
	if(reset = '0') then
		key1Pressed 	<= 0;	
	elsif(rising_edge(key1)) then
		if (key1Pressed = 2) then
			key1Pressed <= 1;
		else
			key1Pressed	<= key1Pressed + 1;
		end if;		
	end if;
end process; 


process(reset, clk_1sec, initialzero)
begin
if (reset = '0' or initialzero = '1') then
	s0 <= 0;
	s1 <= 0;
	m0 <= 0;
	m1 <= 0;
elsif rising_edge(clk_1sec) then
	s0 <= s0 + 1;
	if (s0 = 9) then
		s0 <= 0;
		s1 <=	s1 + 1;
		if (s1 = 5) then
			s1 <= 0;
			m0 <= m0 + 1;
			if (m0 = 9) then
				m0 <= 0;
				m1 <= m1 + 1;
				if (m1 = 5) then
					m1 <= 0;
				end if;
			end if;
		end if;
	end if;
end if;
end process;


state_register: process(reset, clk)
begin
	if(reset = '0') then
		state	<= init;
	elsif(rising_edge(clk)) then
		state	<= nextState;
	end if;
end process;

Transition: process(state, key1Pressed, key2)
begin
	case(state) is
		when init => 
			if (key1Pressed = 1) then
				nextState <= run;
			else
				nextState <= init;
			end if;

		when run =>
			if key1Pressed = 2 then
				nextState <= halt;
			else
				nextState <= run;
			end if;

		when halt => 				
			if key1pressed = 1 then
				nextState <= run;
			else
				nextState <= halt;
			end if;

		when others => nextState <= init; 	

	end case;
end process;

Output: process(reset, clk)
begin
	if (reset = '0') then	
		initialzero <= '1';
		startcounting <= '0';	

	elsif (rising_edge(clk)) then
case (state) is
		when init =>
			initialzero <= '1';
			startcounting <= '0';
		
		when run =>
			if key2 = '1' then
				initialzero <= '1';
				startcounting <= '1';
			else
				initialzero <= '0';
				startcounting <= '1';
			end if;
			
		when halt =>
			if key2 = '1' then
				initialzero <= '1';
				startcounting <= '0';
			else
			initialzero <= '0';
			startcounting <= '0';
			end if;
		when others =>
			initialzero <= '1';
			startcounting <= '0';
		
		end case;
	end if;

end process;


hex1 <= std_logic_vector(to_unsigned(s0, 4));
hex2 <= std_logic_vector(to_unsigned(s1, 4));
hex3 <= std_logic_vector(to_unsigned(m0, 4));
hex4 <=	std_logic_vector(to_unsigned(m1,4));

end Behavioral;

