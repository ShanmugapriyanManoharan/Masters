-- Entity for digital part of AD7922
-- to be used in DHS labs

library ieee;
use ieee.std_logic_1164.all;


entity adc_digital_E is
  
  generic (resolution : integer := 12);  -- Bitwidth

  port (sclk : in std_logic;
        CS_n : in std_logic;
        DIN : in std_logic;
        busy : in std_logic;
        volt_in  : in  integer range 0 to (2**12)-1;
        run_conv : out std_logic;
        ch_sel   : out std_logic; 
        DOUT : out std_logic);
        
end adc_digital_E;

architecture rtl of adc_digital_E is
  
  
  component SPI_control
    port (sclk : in std_logic;
        CS_n : in std_logic;
        DIN : in std_logic;
        DOUT_I : in std_logic_vector (15 downto 0);
        DOUT : out std_logic;
        DIN_I : out std_logic_vector (7 downto 0));
  end component;
  
  component control is
    port (sclk : in std_logic;
          CS_n : in std_logic;
          busy : in std_logic;
          volt_in  : in  integer range 0 to (2**12)-1;
          DIN_I    : in  std_logic_vector (7 downto 0);
          run_conv : out std_logic;
          ch_sel   : out std_logic;
          DOUT_I   : out std_logic_vector (15 downto 0));
        end component;
        
  signal DIN_I_s : std_logic_vector (7 downto 0);
  signal DOUT_I_s : std_logic_vector (15 downto 0);
  --siganl CS_n : std_logic;
  --signal sclk_intrm : std 
        
  begin
    
    Operation_1 : SPI_control
      port map(CS_n => CS_n,
               sclk => sclk,
               DIN => DIN,
               DOUT => DOUT,
               DIN_I => DIN_I_s,
               DOUT_I => DOUT_I_s);
               
    Operation_2 : control
      port map(CS_n => CS_n,
               sclk => sclk,           
               run_conv => run_conv,
               ch_sel => ch_sel,
               volt_in=> volt_in,
               busy => busy,
               DIN_I => DIN_I_s,
               DOUT_I => DOUT_I_s);
               
  end rtl;               