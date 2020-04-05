------------------------------------------------------------------------------
-- Title      : DHS ADC
-- Project    : 
-------------------------------------------------------------------------------
-- File       : control.vhd
-- Author     : Marcel Putsche  <...@hrz.tu-chemnitz.de>
-- Company    : TU-Chemmnitz, SSE
-- Created    : 2018-04-10
-- Last update: 2018-04-18
-- Platform   : x86_64-redhat-linux
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: SPI part of the ADC in DHS practical lab
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


entity SPI_control is
 
port ( CS_n : in std_logic;
      sclk : in std_logic;
      DIN : in std_logic;
      DOUT_I : in std_logic_vector (15 downto 0);
      DOUT : out std_logic;
      DIN_I : out std_logic_vector (7 downto 0)
      );
      --CS_n : out std_logic;
      --sclk : out std_logic;);
end entity SPI_control;

architecture rtl of SPI_control is
    type state is (s1, s2, s3,s4);
    signal current_state : state;
    signal next_state : state;
    signal count : integer range 0 to 16;
    signal done : std_logic;
    signal DIN_I_S : std_logic_vector (7 downto 0);
    signal DOUT_I_S : std_logic_vector (15 downto 0);
  begin
    counter : process (sclk,CS_n)
    begin
      if CS_n= '1' then
        count <= 0;
		 elsif sclk'event and sclk = '0' then
        if done = '1' then
            count <= 0;
        elsif count < 16 then
          count <= count +1;
        else
          count <= 0;
        end if;
      end if;
    end process;
    
    state_register: process(sclk,CS_n)
      begin
        if CS_n = '1' then
          current_state <= s1;
        elsif sclk'event and sclk = '0' then
          current_state <= next_state;
        end if;
      end process;
      
      Transition : process(current_state, count)
      begin
        next_state <= current_state;
        done <= '0';
        
        case current_state is
        when s1 => next_state <= s2;
                  
        when s2 => if count = 16 then
                     next_state <= s4;
                    done <= '1';
                  end if;
        when s3 => if count = 8 then
                     next_state <= s4;
                      done <= '1';
                    end if;
                    
        when s4 => next_state <= s1;
		  end case;
      end process;
    
    
    
  
  output : process (sclk,CS_n,current_state)
    begin
      if CS_n = '1' then
        DIN_I_S <= "00000000";
        DOUT_I_S <= DOUT_I;
        
      elsif sclk'event and sclk = '0' then
        if current_state = s2  or current_state = s3 then
           DIN_I_S <= DIN_I_S (6 downto 0) & DIN; 
      --elsif (current_state = s3) then
            DOUT_I_S <= DOUT_I_S(14 downto 0) & '0';
      end if;
    end if;
    end process;
    
    DIN_I <= DIN_I_S;
    DOUT <= DOUT_I_S (15) when CS_n = '0' else 'Z';
    
     
      
end architecture rtl;