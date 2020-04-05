-------------------------------------------------------------------------------
-- Title      : Testbench for design "ADC_top"
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

entity tb_adc_digital_E is

end tb_adc_digital_E;

-------------------------------------------------------------------------------

architecture rtl of tb_adc_digital_E is
  
  component adc_digital_E
    port (
      CS_n    : in  std_logic;
      sclk     : in  std_logic;
      DIN : in std_logic;
      DOUT : out std_logic;
      run_conv : out std_logic;
      ch_sel   : out std_logic;
      volt_in  : in  integer range 0 to (2**12)-1;
      busy     : in  std_logic);
  
  end component;

    signal CS_n : std_logic :='1';
    signal sclk   : std_logic:='1';
    signal DIN  : std_logic;
    signal DOUT    : std_logic;
    signal run_conv    : std_logic;
    signal ch_sel    : std_logic:='1';
    signal volt_in  : integer range 0 to (2**12)-1;
    signal  busy    : std_logic:='0';
    

begin
      


DUT: adc_digital_E
      port map (
      run_conv => run_conv,
      ch_sel => ch_sel,
      DOUT => DOUT,
      CS_n => CS_n,
      DIN => DIN,
      sclk => sclk,
      volt_in => volt_in,
      busy => busy);
      

  
  
  --clock generation
  sclk <= not sclk after (55 ns/2);
  
  --wave generation
   
  wave_gen_1:Process
  variable period : time := 55 ns;
  begin
    
    wait for period;
    CS_n <= '0';
    --wait until(run_conv'event and run_conv = '1');
    --busy <= '1';
    --wait for 200ns;
    --busy <= '0';
   
    wait for period*16;
    CS_n <= '1';
end process;

busy_wave : Process
begin
    --wait until(run_conv'event and run_conv = '1');
    wait until(rising_edge(run_conv));
    busy <= '1';
    wait for 200 ns;
    busy <= '0';

end process;

wave_gen_2:Process
  variable period : time := 55 ns;
  begin
    wait for period*16; 
    volt_in <= 10;
    DIN <= '1';
    wait for period*32;
    DIN <= '0';
    wait;
end process;
  
    
    
end rtl;