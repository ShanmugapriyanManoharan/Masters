--------------------------------------------------------------------------
-- Company: TU Chemnitz
-- Engineer1: Shanmugapriyan Manoharan
-- Engineer2: Sheela Rachel Anthony
-- Module Name: Pushbutton Debounce Testbench
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_debounce IS
END tb_debounce;
 
ARCHITECTURE behavior OF tb_debounce IS 
 
component debounce IS
  PORT(
    clk     : IN  STD_LOGIC;  
    button  : IN  STD_LOGIC;  
    result  : OUT STD_LOGIC); 
END component;

   signal clk : std_logic := '0';
   signal button : std_logic := '0';
   signal result : std_logic;

   constant clk_period : time := 10 ns;
 
BEGIN
 
   DUT: DeBounce PORT MAP (
          clk => clk,
          button => button,
          result => result
        );

process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
end process;
 
process
   begin        

  wait for clk_period*10;
  button <= '0';
  wait for 10 ns; 
  button <= '1';
  wait for 20 ns; 
  button <= '0';
  wait for 10 ns; 
  button <= '1';
  wait for 30 ns; 
  button <= '0';
  wait for 10 ns; 
  button <= '1';
  wait for 40 ns; 
  button <= '0';
  wait for 10 ns; 
  button <= '1';
  wait for 30 ns;  
  button <= '0';
  wait for 10 ns; 
  button <= '1';
  wait for 400 ns;  
  button <= '0';
  wait for 10 ns; 
  button <= '1';
  wait for 20 ns; 
  button <= '0';
  wait for 10 ns; 
  button <= '1';
  wait for 30 ns; 
  button <= '0';
      wait;
   end process;

END;