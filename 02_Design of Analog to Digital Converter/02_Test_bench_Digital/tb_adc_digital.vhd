-- Testbench for digital part of AD7922
-- to be used in DHS labs

library ieee;
use ieee.std_logic_1164.all;

entity tb_adc_digital is
end tb_adc_digital;

architecture digital_behav of tb_adc_digital is
  -- signal declarations
  constant resolution                                : integer   := 12;  -- minimum resolution must be 4 bit for testbench!
  constant quiet_time                                : time      := 30.0 ns;
  constant SCLK_setup_time                           : time      := 10.0 ns;
  constant adc_conversion_time                       : time      := 350 ns;
  signal adc_busy, adc_run, adc_channel, sclk_enable : std_logic := '0';  -- single bit signals (active high)
  signal SCLK, sclk_internal                         : std_logic := '1';  -- clock (default high)
  signal CS_N                                        : std_logic := '1';  -- chip select (active low)
  signal DIN                                         : std_logic := 'Z';  -- SPI MOSI (default tristate)
  signal DOUT                                        : std_logic;  -- SPI MISO (to be driven by adc)
  signal volt_integer                                : integer range 0 to 2**resolution-1;
  signal data_received                               : std_logic_vector(15 downto 0);

  -- component declaration
  -- to be added by students
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
  
  begin

  -- instantiate DUT
  -- to be added by students
DUT: adc_digital_E
      port map (
      run_conv => adc_run,
      ch_sel => adc_channel,
      DOUT => DOUT,
      CS_n => CS_N,
      DIN => DIN,
      sclk => SCLK,
      volt_in => volt_integer,
      busy => adc_busy);






  -- define clocking scheme
  -- no changes requires by students
  SCLK          <= sclk_internal when sclk_enable = '1' else '1';
  sclk_internal <= not sclk_internal after 100 ns;
 -- process to generate stimuli for SPI transmission
  SPI_P : process
  begin
    wait for 1 us;                      -- default state for all
    cs_n        <= '0';
    din         <= '1';
    wait for SCLK_setup_time;
    -- send first packet to ADC
    wait until falling_edge(sclk_internal);   -- enable SCLK for ADC
    sclk_enable <= '1';
    wait until rising_edge(sclk_internal);    -- wait meaningless 2 MOSI bits
    wait until rising_edge(sclk_internal);
    DIN         <= '0';                 -- request channel 0
    wait until rising_edge(sclk_internal);
    DIN         <= '0';  -- no change to channelbit => normal operation mode (no daisy chain)
    wait until rising_edge(sclk_internal);
    for i in 0 to 11 loop
      wait until rising_edge(sclk_internal);  -- wait remaining bits
    end loop;
    cs_n        <= '1';                 -- end of data transmission 
    sclk_enable <= '0';
    wait for quiet_time;
	
	
    -- 2nd transmission to ADC (request channel 1, read first request)
    wait until rising_edge(sclk_internal);
    -- to be added by students
  wait for 1 us;                      -- default state for all
    cs_n        <= '0';
    din         <= '1';
    wait for SCLK_setup_time;
	 -- send first packet to ADC
    wait until falling_edge(sclk_internal);   -- enable SCLK for ADC
    sclk_enable <= '1';
    wait until rising_edge(sclk_internal);    -- wait meaningless 2 MOSI bits
    wait until rising_edge(sclk_internal);
    DIN         <= '1';                 -- request channel 0
    wait until rising_edge(sclk_internal);
    DIN         <= '1';  -- no change to channelbit => normal operation mode (no daisy chain)
    wait until rising_edge(sclk_internal);
    for i in 0 to 11 loop
      wait until rising_edge(sclk_internal);  -- wait remaining bits
    end loop;
    cs_n        <= '1';                 -- end of data transmission 
    sclk_enable <= '0';
    wait for quiet_time;
	
	
	-- 3rd transmission to ADC request channel 0, read second request)
    wait until rising_edge(sclk_internal);
    -- to be added by students
wait for 1 us;                      -- default state for all
    cs_n        <= '0';
    din         <= '1';
    wait for SCLK_setup_time;
    -- send first packet to ADC
    wait until falling_edge(sclk_internal);   -- enable SCLK for ADC
    sclk_enable <= '1';
    wait until rising_edge(sclk_internal);    -- wait meaningless 2 MOSI bits
    wait until rising_edge(sclk_internal);
    DIN         <= '0';                 -- request channel 0
    wait until rising_edge(sclk_internal);
    DIN         <= '0';  -- no change to channelbit => normal operation mode (no daisy chain)
    wait until rising_edge(sclk_internal);
    for i in 0 to 11 loop
      wait until rising_edge(sclk_internal);  -- wait remaining bits
    end loop;
    cs_n        <= '1';                 -- end of data transmission 
    sclk_enable <= '0';
    wait for quiet_time;

	
    wait;                               -- end of SPI testbench
  end process;

  -- process to imitate ADC analog part
  ADC_ana_P : process
  begin
    adc_busy <= '0';
    wait until rising_edge(adc_run);    -- wait for first sampling request
    adc_busy <= '1';
    wait for adc_conversion_time;
    if adc_channel = '0' then           -- send out data for first request
      volt_integer <= 5;                -- channel 0
    elsif adc_channel = '1' then
      volt_integer <= 10;               -- channel 1
    else
      volt_integer <= 15;               -- no correct signal driver
    end if;
    adc_busy     <= '0';
    wait until falling_edge(adc_run);
    volt_integer <= 0;

	 -- second sampling request (set voltage to lower two digits of
    -- matriculation number of first student)
    -- to be added by students
    adc_busy <= '0';
    wait until rising_edge(adc_run);    -- wait for first sampling request
    adc_busy <= '1';
    wait for adc_conversion_time;
    if adc_channel = '0' then           -- send out data for first request
      volt_integer <= 21;                -- channel 0
    elsif adc_channel = '1' then
      volt_integer <= 10;               -- channel 1
    else
      volt_integer <= 15;               -- no correct signal driver
    end if;
    adc_busy     <= '0';
    wait until falling_edge(adc_run);
    volt_integer <= 0;

	
	-- third sampling request (set voltage to lower two digits of
    -- matriculation number of second student or arbitrary value if single work)
    -- to be added by students
    adc_busy <= '0';
    wait until rising_edge(adc_run);    -- wait for first sampling request
    adc_busy <= '1';
    wait for adc_conversion_time;
    if adc_channel = '0' then           -- send out data for first request
      volt_integer <= 5;                -- channel 0
    elsif adc_channel = '1' then
      volt_integer <= 70;               -- channel 1
    else
      volt_integer <= 15;               -- no correct signal driver
    end if;
    adc_busy     <= '0';
    wait until falling_edge(adc_run);
    volt_integer <= 0;

    wait;                               -- end of ADC_analog testbench
  end process;
  
  datareceived : process(sclk_internal,CS_N)
  begin
    if CS_N = '0' then
      if rising_edge(sclk_internal) then
        data_received <= data_received(14 downto 0) & DOUT;
      end if;
    end if;
  end process;

end digital_behav;
