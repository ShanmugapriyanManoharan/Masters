--------------------------------------------------------------------------
-- Company: TU Chemnitz
-- Engineer1: Shanmugapriyan Manoharan
-- Engineer2: Sheela Rachel Anthony
-- Module Name: Stopwatch Top
--------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity SW is
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    key1     : in  std_logic;
    key2     : in  std_logic;
	 sseg_sel : out std_logic_vector (3 downto 0);
    sseg     : out std_logic_vector(7 downto 0));
end entity SW;


architecture struct of SW is
  
 component Stopwatch is
    port (
      clk    : in  std_logic;
		reset  : in  std_logic;
      key1   : in  std_logic;
      key2   : in  std_logic;
      hex1   : out std_logic_vector(3 downto 0);
      hex2   : out std_logic_vector(3 downto 0);
      hex3   : out std_logic_vector(3 downto 0);
      hex4   : out std_logic_vector(3 downto 0)
      );
  end component;

 component debounce is
  port(
    clk     : IN  STD_LOGIC;  
    button  : IN  STD_LOGIC;  
    result  : OUT STD_LOGIC); 
end component;

component seven_segment_selector is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC; -- reset
			  data1 : in std_logic_vector(3 downto 0);
			  data2 : in std_logic_vector(3 downto 0);
			  data3 : in std_logic_vector(3 downto 0);
			  data4 : in std_logic_vector(3 downto 0);
           anode : out STD_LOGIC_VECTOR (3 downto 0);
           cathode : out STD_LOGIC_VECTOR (7 downto 0));
end component;

  signal hex1_s, hex2_s, hex3_s, hex4_s : std_logic_vector(3 downto 0);
  signal key1_s, key2_s : std_logic;
  

begin  

	stopwatch1 : stopwatch
	port map(
				clk   => clk,
				reset => reset,
				key1  => key1_s,
				key2  => key2_s,
				hex1  => hex1_s,
				hex2  => hex2_s,
				hex3  => hex3_s,
				hex4  => hex4_s);
	
	pushbutton_debounce_key1 : debounce
	port map(clk, key1, key1_s);

	pushbutton_debounce_key2 : debounce
	port map(clk, key2, key2_s);	
	
	seven_seg_selector :seven_segment_selector
    Port map ( clk => clk,
					reset => reset,
					data1 => hex1_s,
					data2 => hex2_s,
					data3 => hex3_s,
					data4 => hex4_s,
					anode => sseg_sel,
					cathode => sseg);

end struct;