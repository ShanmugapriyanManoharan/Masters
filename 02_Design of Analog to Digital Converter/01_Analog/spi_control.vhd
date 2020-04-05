-------------------------------------------------------------------------------
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

entity spi_control is
 
port ( CS_n  : in std_logic;
      sclk : in std_logic;
      CS_n_out :out std_logic;
      sclk_out :out std_logic;
      DIN : in std_logic;
      DOUT_I : in std_logic_vector (15 downto 0);
      DOUT : out std_logic;
      DIN_I : out std_logic_vector (7 downto 0)
      );
 
end entity spi_control;

architecture rtl of spi_control is
    type state is (idle, data_s2p_p2s_tx);
    signal current_state : state;
    signal next_state : state;
    signal count : integer range 0 to 16 := 0;
    signal finish : std_logic := '1';
    signal DIN_I_s : std_logic_vector(7 downto 0);
    signal DOUT_I_s : std_logic_vector(15 downto 0);
    
     
   begin
     
     
    counter : process (sclk,CS_n)
    begin
     if CS_n = '1' then
        count <= 0 ;
         current_state <= idle;
         
      elsif sclk'event and sclk = '0' and CS_n = '0' then
           current_state <= next_state;
          if finish = '1' then
            count <= 0 ;
          elsif count < 16 then
          count <= count +1;
        else
          count <= 0;
        end if;
      end if;
  
    end process;
	
	 Transition : process(current_state, count)
      begin
       next_state <= current_state;
        finish <= '0';
        
      case current_state is
           
           when idle => 
            
              next_state <= data_s2p_p2s_tx;            
          
         when data_s2p_p2s_tx => 
            if count = 16 then 
             next_state <= idle;
             finish <= '1';
          end if;  
                    
        when others => 
              next_state <= idle;
        
        end case;
        
      end process;
	  
	    output: process(current_state,sclk,CS_n,next_state)
    
     variable a : integer range -1 to 7 := 7 ;
     variable b : integer range 0 to 16 := 0 ; 
    
    begin
      if CS_n = '1' then
          DIN_I_s <= "00000000";
          DOUT_I_s <= DOUT_I;
     
    elsif falling_edge(sclk) then
       
      case current_state is
        
     when idle =>
        DIN_I_s <= "00000000";
         DOUT <= 'Z';
         a := 7;
         b := 0;
         
      when data_s2p_p2s_tx =>
        
         --if sclk'event and sclk = '0' then
            if b <= 15 then       
              DOUT_I_s <= '0' & DOUT_I_s(13 downto 0) & '0';
              b := b+1;
              
            --end if;
          end if;
		  
		  when others =>
         DIN_I_s <= "00000000";
         DOUT <= 'Z';
         a := 7;
         b := 0;
     end case ;
     
   end if;
     
  if next_state =  data_s2p_p2s_tx and sclk'event and sclk = '0' then
          if a >= 0  then       
               DIN_I_s(a) <=  DIN ;
              
             a := a-1;
         end if;
     
  end if;
  
 
  
 end process;    
   
     DIN_I <= DIN_I_s;
    DOUT <= DOUT_I_s(14) when CS_n = '0' else 'Z';
    sclk_out  <= sclk ;
    CS_n_out  <= CS_n  ;   
end architecture ;