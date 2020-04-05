-------------------------------------------------------------------------------
-- Title      : DHS ADC
-- Project    : 
-------------------------------------------------------------------------------
-- File       : control.vhd
-- Author     : Marcel Putsche  <...@hrz.tu-chemnitz.de>
-- Company    : TU-Chemmnitz, SSE
-- Created    : 2018-04-10
-- Last update: 2018-05-07
-- Platform   : x86_64-redhat-linux
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Control unit for the ADC used in DHS practical lab
-------------------------------------------------------------------------------
-- Copyright (c) 2018 TU-Chemmnitz, SSE
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-04-10  1.0      mput    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity control is

  generic (
    resolution : integer := 12);

  port (
    run_conv : out std_logic;
    ch_sel   : out std_logic;
    DOUT_I   : out std_logic_vector (15 downto 0);
    CS_n    : in  std_logic;
    DIN_I    : in  std_logic_vector (7 downto 0);
    sclk     : in  std_logic;
    volt_in  : in  integer range 0 to 2**resolution-1;
    busy     : in  std_logic);

end entity control;

architecture rtl of control is

  signal ch_sel_s : std_logic;

  
begin


  process (sclk)
-- process to synchronously write the measured voltage to the 16 bit output (DOUT_I)
  begin
    if sclk'event and sclk = '1' then
      if CS_n = '0' and busy = '0' then
        ch_sel_s                        <= DIN_I(5);
        DOUT_I(11 downto 12-resolution) <= std_logic_vector(to_unsigned(volt_in, resolution));
        DOUT_I(13 downto 12)            <= ch_sel_s & '0';
        DOUT_I(15 downto 14)            <= (others => '0');
      end if;
      
    end if;
  end process;


  run_conv <= not CS_n;

  ch_sel <= ch_sel_s when CS_n = '1';

end architecture rtl;