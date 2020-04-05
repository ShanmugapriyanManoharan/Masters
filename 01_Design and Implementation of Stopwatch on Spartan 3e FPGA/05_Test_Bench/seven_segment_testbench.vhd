--------------------------------------------------------------------------
-- Company: TU Chemnitz
-- Engineer1: Shanmugapriyan Manoharan
-- Engineer2: Sheela Rachel Anthony
-- Module Name: Seven Segment Testbench
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY seven_segment_selector_testbench IS
END seven_segment_selector_testbench;
 
ARCHITECTURE behavior OF seven_segment_selector_testbench IS 
 
    COMPONENT seven_segment_selector
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         data1 : IN  std_logic_vector(3 downto 0);
         data2 : IN  std_logic_vector(3 downto 0);
         data3 : IN  std_logic_vector(3 downto 0);
         data4 : IN  std_logic_vector(3 downto 0);
         cathode : OUT  std_logic_vector(7 downto 0);
         anode : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal data1 : std_logic_vector(3 downto 0) := (others => '0');
   signal data2 : std_logic_vector(3 downto 0) := (others => '0');
   signal data3 : std_logic_vector(3 downto 0) := (others => '0');
   signal data4 : std_logic_vector(3 downto 0) := (others => '0');

   signal cathode : std_logic_vector(7 downto 0);
   signal anode : std_logic_vector(3 downto 0);

   constant clk_period : time := 10 ns;
 
BEGIN
 
   DUT: seven_segment_selector PORT MAP (
          clk => clk,
          reset => reset,
          data1 => data1,
          data2 => data2,
          data3 => data3,
          data4 => data4,
          cathode => cathode,
          anode => anode
        );

   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   stim_proc: process
   begin		
	
   wait for 100 ns;	

   wait for clk_period*10;
	
	reset <= '0';
	wait for 200 ns;	
	reset <= '1';
	wait for 200 ns;
	
	data1 <= "0010";
	data2 <= "0000";
	data3 <= "0000";
	data4 <= "0000";
	
	wait for 200 ns;
	
	data1 <= "0000";
	data2 <= "0010";
	data3 <= "0000";
	data4 <= "0000";
      wait;
   end process;

END;
