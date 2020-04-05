-------------------------------------------------------------------------------
-- Title      : Testbench for design "control"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_control.vhd
-- Author     : Marcel Putsche  <...@hrz.tu-chemnitz.de>
-- Company    : TU-Chemmnitz, SSE
-- Created    : 2018-04-11
-- Last update: 2018-04-18
-- Platform   : x86_64-redhat-linux
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 TU-Chemmnitz, SSE
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-04-11  1.0      mput    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity tb_conversion_control is

end tb_conversion_control;

-------------------------------------------------------------------------------

architecture rtl of tb_conversion_control is
  
  component control
    port (
      run_conv : out std_logic;
    ch_sel   : out std_logic;
    DOUT_I   : out std_logic_vector (15 downto 0);
    CS_n    : in  std_logic;
    DIN_I    : in  std_logic_vector (7 downto 0);
    sclk     : in  std_logic;
    volt_in  : in  integer range 0 to (2**12)-1;
    busy     : in  std_logic);
  end component;

    signal run_conv : std_logic :='0';
    signal ch_sel   : std_logic:='1';
    signal  DOUT_I  : std_logic_vector (15 downto 0);
    signal  CS_n    : std_logic:='1' ;
    signal DIN_I    : std_logic_vector (7 downto 0);
    signal  sclk    : std_logic:='1';
    signal volt_in  : integer := 10;
    signal  busy    : std_logic:='0';
    

begin
      


DUT: control
      port map (
      run_conv => run_conv,
      ch_sel => ch_sel,
      DOUT_I => DOUT_I,
      CS_n => CS_n,
      DIN_I => DIN_I,
      sclk => sclk,
      volt_in => volt_in,
      busy => busy);
      

  
  
  --clock generation
  sclk <= not sclk after (55 ns/2);
  
  --wave generation
   
  wave_gen_1:Process
  variable period : time := 55 ns;
  begin
    
    wait for 15 ns;
    CS_n <= '0';
    busy <= '1';
    wait for 200 ns;
    busy <= '0';
   
    wait for period*16;
    CS_n <= '1';
   
    
    
  end process;

wave_gen_2:Process
  variable period : time := 55 ns;
  begin
    wait for period*16; 
    volt_in <= 16;
    DIN_I <= "00101110";
    wait for period*32;
    DIN_I <= "00001111";
    wait;
end process;
    

    
    
end rtl;
    
      
      
      
      
      