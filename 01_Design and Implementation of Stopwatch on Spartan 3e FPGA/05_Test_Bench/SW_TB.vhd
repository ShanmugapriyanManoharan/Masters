 --------------------------------------------------------------------------
-- Company: TU Chemnitz
-- Engineer1: Shanmugapriyan Manoharan
-- Engineer2: Sheela Rachel Anthony
-- Module Name: Stopwatch Top Test Bench
--------------------------------------------------------------------------
  
 library ieee;
 use ieee.std_logic_1164.all;
 use ieee.numeric_std.all;
 
 entity SW_tb is
 
 end SW_tb;

 
 architecture behaviour of SW_tb is
     
	component SW  is
		port (
			clk      : in  std_logic;
			key1     : in  std_logic;
			key2     : in  std_logic;
			reset    : in  std_logic;
			sseg_sel : out std_logic_vector(3 downto 0);
			sseg     : out std_logic_vector(7 downto 0)
			);
	end component;

	signal clk_s : std_logic   := '0';
   signal reset_s : std_logic := '0';
   signal key1_s : std_logic  := '0';
   signal key2_s : std_logic  := '0';
	signal sseg_sel_s : std_logic_vector(3 downto 0);
	signal sseg_s  : std_logic_vector(7 downto 0);
 
 
 begin
 
   DUT : SW
	port map(
			clk => clk_s,
			reset => reset_s,
			key1 => key1_s,
			key2 => key2_s,
			sseg_sel => sseg_sel_s,
			sseg => sseg_s);
 
 
   
process
begin
	clk_s <= not clk_s;
	wait for 50 ns;
end process;

process
begin
 
		 
	reset_s <= '0';
	wait for 2000 ms;	
	reset_s <= '1';
	wait for 2000 ms;

	key1_s <= '1';
	wait for 20 ms;
	key1_s <= '0';

	wait for 5000 ms;

	key1_s <= '1';
	wait for 20 ms;
	key1_s <= '0';

	wait for 2000 ms;

	key1_s <= '1';
	wait for 20 ms;
	key1_s <= '0';

	wait for 6000 ms;

	key2_s <= '1';
	wait for 20 ms;
	key2_s <= '0';

	wait for 2000 ms;

	key1_s <= '1';
	wait for 20 ms;
	key1_s <= '0';

	wait for 6000 ms;

	key2_s <= '1';
	wait for 20 ms;
	key2_s <= '0';

	wait for 6000 ms;

	key1_s <= '1';
	wait for 20 ms;
	key1_s <= '0';

	wait;
end process;

end behaviour;
 
 -------------------------------------------------------------------------------
 
 configuration SW_tb_test_cfg of SW_tb is
   for behaviour
   end for;
 end SW_tb_test_cfg;
 
 -------------------------------------------------------------------------------
 