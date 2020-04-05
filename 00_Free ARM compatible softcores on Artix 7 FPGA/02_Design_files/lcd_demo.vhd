library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.arraypackage.all;
-------------------------------------------------------------------------------

entity lcd16x2_ctrl_demo is
  port (
    clk    : in  std_logic;
    rst    : in std_logic;
--    up     : in std_logic;
--    down   : in std_logic;
    lcd_e  : out std_logic;
    lcd_rs : out std_logic;
    lcd_db : out std_logic_vector(7 downto 4);
    data_tx : in Memory_Array);


end entity lcd16x2_ctrl_demo;

-------------------------------------------------------------------------------

architecture behavior of lcd16x2_ctrl_demo is

type state is (idle, s1, s2, s3, s4, s5, s6, s7, s8);
signal current_state : state := idle;
signal next_state : state;

  signal set_count : STD_LOGIC;
  signal count : integer range 0 to 100000000;
   
  signal line1_buffer_O : std_logic_vector(159 downto 0);
  signal line2_buffer_O : std_logic_vector(159 downto 0);
  signal line3_buffer_O : std_logic_vector(159 downto 0);
  signal line4_buffer_O : std_logic_vector(159 downto 0);
  
  signal line1_buffer_O_S : std_logic_vector(159 downto 0) := (others => '0');-- := X"20"&X"20"&X"20"&X"41"&X"52"&X"4D"&X"20"&X"53"&X"4F"&X"46"&X"54"&X"20"&X"43"&X"4F"&X"52"&X"45"&X"20"&X"20"&X"20"&X"20";
  signal line2_buffer_O_S : std_logic_vector(159 downto 0) := (others => '0');-- := X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"4F"&X"55"&X"54"&X"50"&X"55"&X"54"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
  signal line3_buffer_O_S : std_logic_vector(159 downto 0) := (others => '0');-- :-= X"20"&X"20"&X"20"&X"20"&X"20"&X"46"&X"49"&X"42"&X"4F"&X"4E"&X"41"&X"43"&X"43"&X"49"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
  signal line4_buffer_O_S : std_logic_vector(159 downto 0) := (others => '0');-- := X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"53"&X"45"&X"52"&X"49"&X"45"&X"53"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";

  -- component generics
  constant CLK_PERIOD_NS : positive := 10;  -- 100 Mhz
  
   function BIT_ASCII (
         data    : in std_logic_vector(3 downto 0))
         return std_logic_vector is
        variable out1 : std_logic_vector(7 downto 0);
       begin
        case data is
         when "0000" =>
         out1:=X"30"; 
        when "0001" =>
         out1:=X"31";
         when "0010" =>
         out1:=X"32";
         when "0011" =>
             out1:=X"33";
         when "0100" =>
             out1:=X"34";
         when "0101" =>
             out1:=X"35";
         when "0110" =>
             out1:=X"36";
         when "0111" =>
             out1:=X"37";
         when "1000" =>
             out1:=X"38";
         when "1001" =>
             out1:=X"39";
         when "1010" =>
             out1:=X"41";
         when "1011" =>
             out1:=X"42";
         when "1100" =>
             out1:=X"43";
         when "1101" =>
             out1:=X"44";
         when "1110" =>
             out1:=X"45";
         when "1111" =>
             out1:=X"46";
         when others =>
             out1:=X"2D";
         end case;
         return out1;
          
       end function BIT_ASCII;

component lcd_ctr is
  
  generic (
    CLK_PERIOD_NS : positive := 20);    -- 50MHz

  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    lcd_e        : out std_logic;
    lcd_rs       : out std_logic;
    lcd_db       : out std_logic_vector(7 downto 4);
    line1_buffer : in  std_logic_vector(159 downto 0);  -- 16x8bit
    line2_buffer : in  std_logic_vector(159 downto 0);
    line3_buffer : in  std_logic_vector(159 downto 0);  -- 16x8bit
    line4_buffer : in  std_logic_vector(159 downto 0));	 

end component;

begin  -- architecture behavior

  -- component instantiation
   DUT : lcd_ctr
    generic map (
      CLK_PERIOD_NS => 20)
    port map (
      clk          => clk,
      rst          => rst,
      lcd_e        => lcd_e,
      lcd_rs       => lcd_rs,
      lcd_db       => lcd_db,
      line1_buffer => line1_buffer_O,
      line2_buffer => line2_buffer_O,
      line3_buffer => line3_buffer_O,
      line4_buffer => line4_buffer_O);

 
  process(clk, rst, current_state, count, data_tx)
    variable line1_buffer : std_logic_vector(159 downto 0);
    variable Memory_D     : std_logic_vector(31 downto 0) := x"00000001";

  begin
  
  set_count <= '0';
 next_state <= current_state;
line1_buffer_O_S <= X"20"&X"20"&X"20"&X"41"&X"52"&X"4D"&X"20"&X"53"&X"4F"&X"46"&X"54"&X"20"&X"43"&X"4F"&X"52"&X"45"&X"20"&X"20"&X"20"&X"20";
line2_buffer_O_S <= X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"4F"&X"55"&X"54"&X"50"&X"55"&X"54"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
line3_buffer_O_S <= X"20"&X"20"&X"20"&X"20"&X"20"&X"46"&X"49"&X"42"&X"4F"&X"4E"&X"41"&X"43"&X"43"&X"49"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
line4_buffer_O_S <= X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"53"&X"45"&X"52"&X"49"&X"45"&X"53"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
 case current_state is
	when idle => if count = 100000000 then
					set_count <= '1';
					next_state <= s1;
				
				 else
					line1_buffer_O_S <= X"20"&X"20"&X"20"&X"41"&X"52"&X"4D"&X"20"&X"53"&X"4F"&X"46"&X"54"&X"20"&X"43"&X"4F"&X"52"&X"45"&X"20"&X"20"&X"20"&X"20";
					line2_buffer_O_S <= X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"4F"&X"55"&X"54"&X"50"&X"55"&X"54"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
					line3_buffer_O_S <= X"20"&X"20"&X"20"&X"20"&X"20"&X"46"&X"49"&X"42"&X"4F"&X"4E"&X"41"&X"43"&X"43"&X"49"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
					line4_buffer_O_S <= X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"53"&X"45"&X"52"&X"49"&X"45"&X"53"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				 end if;
	
	when s1 =>  if count = 100000000 then
	               set_count <= '1';
                   next_state <= s2;
                else 
				line1_buffer_O_S <= BIT_ASCII(data_tx(0)(31 downto 28))&BIT_ASCII(data_tx(0)(27 downto 24))&BIT_ASCII(data_tx(0)(23 downto 20))&BIT_ASCII(data_tx(0)(19 downto 16))&BIT_ASCII(data_tx(0)(15 downto 12))&BIT_ASCII(data_tx(0)(11 downto 8))&BIT_ASCII(data_tx(0)(7 downto 4))&BIT_ASCII(data_tx(0)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
			    line2_buffer_O_S <= BIT_ASCII(data_tx(1)(31 downto 28))&BIT_ASCII(data_tx(1)(27 downto 24))&BIT_ASCII(data_tx(1)(23 downto 20))&BIT_ASCII(data_tx(1)(19 downto 16))&BIT_ASCII(data_tx(1)(15 downto 12))&BIT_ASCII(data_tx(1)(11 downto 8))&BIT_ASCII(data_tx(1)(7 downto 4))&BIT_ASCII(data_tx(1)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				 line3_buffer_O_S <= BIT_ASCII(Memory_D(31 downto 28))&BIT_ASCII(Memory_D(27 downto 24))&BIT_ASCII(Memory_D(23 downto 20))&BIT_ASCII(Memory_D(19 downto 16))&BIT_ASCII(Memory_D(15 downto 12))&BIT_ASCII(Memory_D(11 downto 8))&BIT_ASCII(Memory_D(7 downto 4))&BIT_ASCII(Memory_D(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
                 line4_buffer_O_S <= BIT_ASCII(data_tx(2)(31 downto 28))&BIT_ASCII(data_tx(2)(27 downto 24))&BIT_ASCII(data_tx(2)(23 downto 20))&BIT_ASCII(data_tx(2)(19 downto 16))&BIT_ASCII(data_tx(2)(15 downto 12))&BIT_ASCII(data_tx(2)(11 downto 8))&BIT_ASCII(data_tx(2)(7 downto 4))&BIT_ASCII(data_tx(2)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";

				end if;
				
	when s2 =>  if count = 100000000 then
                   set_count <= '1';
	             
	               next_state <= s3;
					
                else
				line1_buffer_O_S <= BIT_ASCII(data_tx(3)(31 downto 28))&BIT_ASCII(data_tx(3)(27 downto 24))&BIT_ASCII(data_tx(3)(23 downto 20))&BIT_ASCII(data_tx(3)(19 downto 16))&BIT_ASCII(data_tx(3)(15 downto 12))&BIT_ASCII(data_tx(3)(11 downto 8))&BIT_ASCII(data_tx(3)(7 downto 4))&BIT_ASCII(data_tx(3)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
			    line2_buffer_O_S <= BIT_ASCII(data_tx(4)(31 downto 28))&BIT_ASCII(data_tx(4)(27 downto 24))&BIT_ASCII(data_tx(4)(23 downto 20))&BIT_ASCII(data_tx(4)(19 downto 16))&BIT_ASCII(data_tx(4)(15 downto 12))&BIT_ASCII(data_tx(4)(11 downto 8))&BIT_ASCII(data_tx(4)(7 downto 4))&BIT_ASCII(data_tx(4)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				line3_buffer_O_S <= BIT_ASCII(data_tx(5)(31 downto 28))&BIT_ASCII(data_tx(5)(27 downto 24))&BIT_ASCII(data_tx(5)(23 downto 20))&BIT_ASCII(data_tx(5)(19 downto 16))&BIT_ASCII(data_tx(5)(15 downto 12))&BIT_ASCII(data_tx(5)(11 downto 8))&BIT_ASCII(data_tx(5)(7 downto 4))&BIT_ASCII(data_tx(5)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
                line4_buffer_O_S <= BIT_ASCII(data_tx(6)(31 downto 28))&BIT_ASCII(data_tx(6)(27 downto 24))&BIT_ASCII(data_tx(6)(23 downto 20))&BIT_ASCII(data_tx(6)(19 downto 16))&BIT_ASCII(data_tx(6)(15 downto 12))&BIT_ASCII(data_tx(6)(11 downto 8))&BIT_ASCII(data_tx(6)(7 downto 4))&BIT_ASCII(data_tx(6)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";

				end if;
				
	when s3 =>  if count = 100000000 then
                   set_count <= '1';
	               next_state <= s4;

					
                else
				line1_buffer_O_S <= BIT_ASCII(data_tx(7)(31 downto 28))&BIT_ASCII(data_tx(7)(27 downto 24))&BIT_ASCII(data_tx(7)(23 downto 20))&BIT_ASCII(data_tx(7)(19 downto 16))&BIT_ASCII(data_tx(7)(15 downto 12))&BIT_ASCII(data_tx(7)(11 downto 8))&BIT_ASCII(data_tx(7)(7 downto 4))&BIT_ASCII(data_tx(7)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
			    line2_buffer_O_S <= BIT_ASCII(data_tx(8)(31 downto 28))&BIT_ASCII(data_tx(8)(27 downto 24))&BIT_ASCII(data_tx(8)(23 downto 20))&BIT_ASCII(data_tx(8)(19 downto 16))&BIT_ASCII(data_tx(8)(15 downto 12))&BIT_ASCII(data_tx(8)(11 downto 8))&BIT_ASCII(data_tx(8)(7 downto 4))&BIT_ASCII(data_tx(8)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				line3_buffer_O_S <= BIT_ASCII(data_tx(9)(31 downto 28))&BIT_ASCII(data_tx(9)(27 downto 24))&BIT_ASCII(data_tx(9)(23 downto 20))&BIT_ASCII(data_tx(9)(19 downto 16))&BIT_ASCII(data_tx(9)(15 downto 12))&BIT_ASCII(data_tx(9)(11 downto 8))&BIT_ASCII(data_tx(9)(7 downto 4))&BIT_ASCII(data_tx(9)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
                line4_buffer_O_S <= BIT_ASCII(data_tx(10)(31 downto 28))&BIT_ASCII(data_tx(10)(27 downto 24))&BIT_ASCII(data_tx(10)(23 downto 20))&BIT_ASCII(data_tx(10)(19 downto 16))&BIT_ASCII(data_tx(10)(15 downto 12))&BIT_ASCII(data_tx(10)(11 downto 8))&BIT_ASCII(data_tx(10)(7 downto 4))&BIT_ASCII(data_tx(10)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";

				end if;
				
				
	when s4 =>  if count = 100000000 then
                   set_count <= '1';
	               next_state <= s5;

					
                else
				line1_buffer_O_S <= BIT_ASCII(data_tx(11)(31 downto 28))&BIT_ASCII(data_tx(11)(27 downto 24))&BIT_ASCII(data_tx(11)(23 downto 20))&BIT_ASCII(data_tx(11)(19 downto 16))&BIT_ASCII(data_tx(11)(15 downto 12))&BIT_ASCII(data_tx(11)(11 downto 8))&BIT_ASCII(data_tx(11)(7 downto 4))&BIT_ASCII(data_tx(11)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
			    line2_buffer_O_S <= BIT_ASCII(data_tx(12)(31 downto 28))&BIT_ASCII(data_tx(12)(27 downto 24))&BIT_ASCII(data_tx(12)(23 downto 20))&BIT_ASCII(data_tx(12)(19 downto 16))&BIT_ASCII(data_tx(12)(15 downto 12))&BIT_ASCII(data_tx(12)(11 downto 8))&BIT_ASCII(data_tx(12)(7 downto 4))&BIT_ASCII(data_tx(12)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				line3_buffer_O_S <= BIT_ASCII(data_tx(13)(31 downto 28))&BIT_ASCII(data_tx(13)(27 downto 24))&BIT_ASCII(data_tx(13)(23 downto 20))&BIT_ASCII(data_tx(13)(19 downto 16))&BIT_ASCII(data_tx(13)(15 downto 12))&BIT_ASCII(data_tx(13)(11 downto 8))&BIT_ASCII(data_tx(13)(7 downto 4))&BIT_ASCII(data_tx(13)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
                line4_buffer_O_S <= BIT_ASCII(data_tx(14)(31 downto 28))&BIT_ASCII(data_tx(14)(27 downto 24))&BIT_ASCII(data_tx(14)(23 downto 20))&BIT_ASCII(data_tx(14)(19 downto 16))&BIT_ASCII(data_tx(14)(15 downto 12))&BIT_ASCII(data_tx(14)(11 downto 8))&BIT_ASCII(data_tx(14)(7 downto 4))&BIT_ASCII(data_tx(14)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";

				end if;
				
	when s5 =>  if count = 100000000 then
                   set_count <= '1';
	               next_state <= s6;

					
                else
				line1_buffer_O_S <= BIT_ASCII(data_tx(15)(31 downto 28))&BIT_ASCII(data_tx(15)(27 downto 24))&BIT_ASCII(data_tx(15)(23 downto 20))&BIT_ASCII(data_tx(15)(19 downto 16))&BIT_ASCII(data_tx(15)(15 downto 12))&BIT_ASCII(data_tx(15)(11 downto 8))&BIT_ASCII(data_tx(15)(7 downto 4))&BIT_ASCII(data_tx(15)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
			    line2_buffer_O_S <= BIT_ASCII(data_tx(16)(31 downto 28))&BIT_ASCII(data_tx(16)(27 downto 24))&BIT_ASCII(data_tx(16)(23 downto 20))&BIT_ASCII(data_tx(16)(19 downto 16))&BIT_ASCII(data_tx(16)(15 downto 12))&BIT_ASCII(data_tx(16)(11 downto 8))&BIT_ASCII(data_tx(16)(7 downto 4))&BIT_ASCII(data_tx(16)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				line3_buffer_O_S <= BIT_ASCII(data_tx(17)(31 downto 28))&BIT_ASCII(data_tx(17)(27 downto 24))&BIT_ASCII(data_tx(17)(23 downto 20))&BIT_ASCII(data_tx(17)(19 downto 16))&BIT_ASCII(data_tx(17)(15 downto 12))&BIT_ASCII(data_tx(17)(11 downto 8))&BIT_ASCII(data_tx(17)(7 downto 4))&BIT_ASCII(data_tx(17)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
                line4_buffer_O_S <= BIT_ASCII(data_tx(18)(31 downto 28))&BIT_ASCII(data_tx(18)(27 downto 24))&BIT_ASCII(data_tx(18)(23 downto 20))&BIT_ASCII(data_tx(18)(19 downto 16))&BIT_ASCII(data_tx(18)(15 downto 12))&BIT_ASCII(data_tx(18)(11 downto 8))&BIT_ASCII(data_tx(18)(7 downto 4))&BIT_ASCII(data_tx(18)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";

				end if;
				
	when s6 =>  if count = 100000000 then
                   set_count <= '1';
	               next_state <= s7;
					
                else
				line1_buffer_O_S <= BIT_ASCII(data_tx(19)(31 downto 28))&BIT_ASCII(data_tx(19)(27 downto 24))&BIT_ASCII(data_tx(19)(23 downto 20))&BIT_ASCII(data_tx(19)(19 downto 16))&BIT_ASCII(data_tx(19)(15 downto 12))&BIT_ASCII(data_tx(19)(11 downto 8))&BIT_ASCII(data_tx(19)(7 downto 4))&BIT_ASCII(data_tx(19)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
			    line2_buffer_O_S <= BIT_ASCII(data_tx(20)(31 downto 28))&BIT_ASCII(data_tx(20)(27 downto 24))&BIT_ASCII(data_tx(20)(23 downto 20))&BIT_ASCII(data_tx(20)(19 downto 16))&BIT_ASCII(data_tx(20)(15 downto 12))&BIT_ASCII(data_tx(20)(11 downto 8))&BIT_ASCII(data_tx(20)(7 downto 4))&BIT_ASCII(data_tx(20)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				line3_buffer_O_S <= BIT_ASCII(data_tx(21)(31 downto 28))&BIT_ASCII(data_tx(21)(27 downto 24))&BIT_ASCII(data_tx(21)(23 downto 20))&BIT_ASCII(data_tx(21)(19 downto 16))&BIT_ASCII(data_tx(21)(15 downto 12))&BIT_ASCII(data_tx(21)(11 downto 8))&BIT_ASCII(data_tx(21)(7 downto 4))&BIT_ASCII(data_tx(21)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
                line4_buffer_O_S <= BIT_ASCII(data_tx(22)(31 downto 28))&BIT_ASCII(data_tx(22)(27 downto 24))&BIT_ASCII(data_tx(22)(23 downto 20))&BIT_ASCII(data_tx(22)(19 downto 16))&BIT_ASCII(data_tx(22)(15 downto 12))&BIT_ASCII(data_tx(22)(11 downto 8))&BIT_ASCII(data_tx(22)(7 downto 4))&BIT_ASCII(data_tx(22)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";

				end if;
				
				
	when s7 =>  if count = 100000000 then
                   set_count <= '1';
	               next_state <= s8;

					
                else
				line1_buffer_O_S <= BIT_ASCII(data_tx(23)(31 downto 28))&BIT_ASCII(data_tx(23)(27 downto 24))&BIT_ASCII(data_tx(23)(23 downto 20))&BIT_ASCII(data_tx(23)(19 downto 16))&BIT_ASCII(data_tx(23)(15 downto 12))&BIT_ASCII(data_tx(23)(11 downto 8))&BIT_ASCII(data_tx(23)(7 downto 4))&BIT_ASCII(data_tx(23)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
			    line2_buffer_O_S <= BIT_ASCII(data_tx(24)(31 downto 28))&BIT_ASCII(data_tx(24)(27 downto 24))&BIT_ASCII(data_tx(24)(23 downto 20))&BIT_ASCII(data_tx(24)(19 downto 16))&BIT_ASCII(data_tx(24)(15 downto 12))&BIT_ASCII(data_tx(24)(11 downto 8))&BIT_ASCII(data_tx(24)(7 downto 4))&BIT_ASCII(data_tx(24)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				line3_buffer_O_S <= BIT_ASCII(data_tx(25)(31 downto 28))&BIT_ASCII(data_tx(25)(27 downto 24))&BIT_ASCII(data_tx(25)(23 downto 20))&BIT_ASCII(data_tx(25)(19 downto 16))&BIT_ASCII(data_tx(25)(15 downto 12))&BIT_ASCII(data_tx(25)(11 downto 8))&BIT_ASCII(data_tx(25)(7 downto 4))&BIT_ASCII(data_tx(25)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
                line4_buffer_O_S <= BIT_ASCII(data_tx(26)(31 downto 28))&BIT_ASCII(data_tx(26)(27 downto 24))&BIT_ASCII(data_tx(26)(23 downto 20))&BIT_ASCII(data_tx(26)(19 downto 16))&BIT_ASCII(data_tx(26)(15 downto 12))&BIT_ASCII(data_tx(26)(11 downto 8))&BIT_ASCII(data_tx(26)(7 downto 4))&BIT_ASCII(data_tx(26)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";

				end if;
				
				
	when s8 =>  if count = 100000000 then
                   set_count <= '1';
	               next_state <= idle;
					
                else
				line1_buffer_O_S <= BIT_ASCII(data_tx(27)(31 downto 28))&BIT_ASCII(data_tx(27)(27 downto 24))&BIT_ASCII(data_tx(27)(23 downto 20))&BIT_ASCII(data_tx(27)(19 downto 16))&BIT_ASCII(data_tx(27)(15 downto 12))&BIT_ASCII(data_tx(27)(11 downto 8))&BIT_ASCII(data_tx(27)(7 downto 4))&BIT_ASCII(data_tx(27)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
			    line2_buffer_O_S <= BIT_ASCII(data_tx(28)(31 downto 28))&BIT_ASCII(data_tx(28)(27 downto 24))&BIT_ASCII(data_tx(28)(23 downto 20))&BIT_ASCII(data_tx(28)(19 downto 16))&BIT_ASCII(data_tx(28)(15 downto 12))&BIT_ASCII(data_tx(28)(11 downto 8))&BIT_ASCII(data_tx(28)(7 downto 4))&BIT_ASCII(data_tx(28)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				line3_buffer_O_S <= BIT_ASCII(data_tx(29)(31 downto 28))&BIT_ASCII(data_tx(29)(27 downto 24))&BIT_ASCII(data_tx(29)(23 downto 20))&BIT_ASCII(data_tx(29)(19 downto 16))&BIT_ASCII(data_tx(29)(15 downto 12))&BIT_ASCII(data_tx(29)(11 downto 8))&BIT_ASCII(data_tx(29)(7 downto 4))&BIT_ASCII(data_tx(29)(3 downto 0))&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
                line4_buffer_O_S <= X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20"&X"20";
				end if;
	when others => 
	               next_state <= idle;
	
	end case;


end process;


  line1_buffer_O <= line1_buffer_O_S;
  line2_buffer_O <= line2_buffer_O_S;
  line3_buffer_O <= line3_buffer_O_S;
  line4_buffer_O <= line4_buffer_O_S;
  


  -- switch lines every second
  process(clk,rst)
  begin
  if rst = '0' then
    current_state <= idle;
    count <= 0;
  elsif rising_edge(clk) then
      current_state <= next_state;
      if set_count = '1' then
        count <= 0;
      elsif count < 100000000 then
        count <= count +1;
      else
        count <= 0;
     end if;
  end if;
      
  end process;
  
end architecture behavior;