--------------------------------------------------------------------------
-- Company: TU Chemnitz
-- Engineer1: Shanmugapriyan Manoharan
-- Engineer2: Sheela Rachel Anthony
-- Module Name: Pushbutton Debounce
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY debounce IS
  PORT(
    clk     : IN  STD_LOGIC;  
    button  : IN  STD_LOGIC;  
    result  : OUT STD_LOGIC); 
END debounce;

ARCHITECTURE logic OF debounce IS
  SIGNAL flipflops   : STD_LOGIC_VECTOR(1 DOWNTO 0); 
  SIGNAL counter_set : STD_LOGIC;                    
  SIGNAL counter_out : integer range 0 to 1000000:= 0;
BEGIN

  counter_set <= flipflops(0) xor flipflops(1);   
  
  PROCESS(clk)
  BEGIN
    IF(clk'EVENT and clk = '1') THEN
      flipflops(0) <= button;
      flipflops(1) <= flipflops(0);
      If(counter_set = '1') THEN                  
        counter_out <= 0;
      ELSIF(counter_out = 1000000) THEN  --counter_out = 1000000 (for HW) & counter_out = 5 (for TestBench)
        counter_out <= 0;
		result <= flipflops(1);
	
      ELSE                                        
        counter_out <= counter_out + 1;
      END IF;    
    END IF;
  END PROCESS;
END logic;