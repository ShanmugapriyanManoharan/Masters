-------------------------------------------------------------------------------
-- Title      : Testbench for design "SPI_control"
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

entity tb_SPI_control is

end tb_SPI_control ;

-------------------------------------------------------------------------------

architecture rtl of tb_SPI_control  is
  
  component SPI_control
   
port ( CS_n : in std_logic;
      sclk : in std_logic;
      DIN : in std_logic;
      DOUT_I : in std_logic_vector (15 downto 0);
      DOUT : out std_logic;
      DIN_I : out std_logic_vector (7 downto 0)
      );
  end component;
  
    signal  DOUT  : std_logic  ;
    signal  CS_n    : std_logic:='1' ;
    signal DIN    : std_logic;
    signal  sclk    : std_logic:='1';
    signal DIN_I : std_logic_vector (7 downto 0);
    signal DOUT_I : std_logic_vector (15 downto 0);    
    
    
begin
  
  DUT: SPI_control
      port map (
      CS_n => CS_n,
      sclk => sclk,
      DIN => DIN,
      DOUT_I => DOUT_I,
      DOUT => DOUT,
      DIN_I => DIN_I);

  
  
  --clock generation
  sclk <= not sclk after 55 ns/2;
  
  --wave generation
   
  wave_gen_1:Process
  variable period : time := 55 ns;
  begin
    wait for period*16;
    CS_n <= '0';
    wait for period*16;
    CS_n <= '1';
   
  end process;
  wave_gen_2 : process
   variable period : time := 55 ns;
  begin
    
    DIN <= '1';
    DOUT_I <= "1111000011110000";
    wait; -- for period*16;
    --DIN <= '1';
   -- DOUT_I <= "0000111100001111";
  end process;
  
end rtl;
    
      