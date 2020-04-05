LIBRARY ieee;
USE ieee.math_real.ALL;
use ieee.std_logic_1164.all;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;

ENTITY tb_adc_complete IS
END;

architecture simple of tb_adc_complete is
 component adc_top 
  GENERIC (
    resolution_in_bit : integer := 12;
    input_resistance : real := 10.0e6;  -- input resistance of conversion module
    pin_resistance : real := 1.0;       -- pin resistance 
    pin_capacity : real := 6.0e-12; 	-- pin capacity (pin to ground)
    sw_resistance : real := 100.0);	-- switch & MUX resistance (pin to conversion)

  PORT (
    TERMINAL V_in0,V_in1, VPLUS, GROUND : ELECTRICAL;
    signal DIN, CS_N, SCLK : in std_logic;
    signal DOUT : out std_logic);
 end component;

 TERMINAL volt1, volt0, vplus, masse : electrical;
 
 quantity udd across idd through vplus;-- to GND;
 quantity u1 across i1 through volt1;-- to GND;
 quantity u0 across i0 through volt0;-- to GND;
 quantity ugnd across ignd through masse;

 constant resolution : integer := 12; -- minimum resolution must be 4 bit for testbench!
 constant quiet_time : time := 30.0 ns;
 constant SCLK_setup_time : time := 10.0 ns;
 
 signal sclk_enable : std_logic := '0'; -- single bit signals (active high)
 signal SCLK, sclk_internal : std_logic := '1';  -- clock (default high)
 signal CS_N : std_logic := '1';  -- chip select (active low)
 signal DIN : std_logic := 'Z';   -- SPI MOSI (default tristate)
 signal DOUT : std_logic;         -- SPI MISO (to be driven by adc)
 signal volt_integer : integer range 0 to (2**resolution)-1 := 0;
 signal data_received : std_logic_vector(15 downto 0);
  
  BEGIN

  adc1 : ENTITY work.adc_top_E(struct)
    GENERIC MAP (
      resolution_in_bit => resolution,
      sw_resistance => 100.0,
      pin_resistance => 1.0,
      pin_capacity => 6.0e-12,
      input_resistance => 10.0e6)
    PORT MAP (
      V_in0 => volt0,
      V_in1 => volt1,
      VPLUS => vplus,
      GROUND => masse,
      DIN => DIN,
      CS_N => CS_N,
      SCLK => SCLK,
      DOUT => dout);

  -- Analog constant pin values
  udd == 5.0;
  masse'reference == 0.0;
  
  if now < 50 us use
    u0 == 0.0;
    u1 == 0.0;
  elsif now < 100 us use
    u0 == 5.0;
    u1 == 2.5;
  else
    u0 == 6.0 * sin(2.0 * MATH_PI * 1.0e5*now);
    u1 == 2.5 + 2.0 * sin(2.0 * MATH_PI * 2.0e3 * now);
  end use;
  
  -- process to generate stimuli for SPI transmission
  SPI_P : PROCESS
  BEGIN
    wait for 1 us; -- default state for all
    cs_n <= '0';
    din <= '1';
    wait for SCLK_setup_time;
    -- send packet to ADC 
    wait until rising_edge(sclk_internal);
    cs_n <= '0';
    DIN <= '1';                   		-- now request channel 1 for next read
    wait for SCLK_setup_time;
    wait until falling_edge(sclk_internal); 	-- enable SCLK for ADC
    sclk_enable <= '1';				-- read 1st (meaningless) bit from ADC
    data_received(15) <= DOUT;
    for i in 14 downto 0 loop
      wait until falling_edge(sclk_internal);   -- read data bits from ADC at falling edge always
      data_received(i) <= DOUT;
    end loop;
    wait until rising_edge(sclk_internal);
    cs_n <= '1';                                -- end of data transmission 
    sclk_enable <= '0';
    wait for quiet_time; 
    -- send next packet to ADC 
    wait until rising_edge(sclk_internal);
	
	 cs_n <= '0';
    DIN <= '0';                   		-- now request channel 0 for next read
    wait for SCLK_setup_time;
    wait until falling_edge(sclk_internal); 	-- enable SCLK for ADC
    sclk_enable <= '1';				-- read 1st (meaningless) bit from ADC
    data_received(15) <= DOUT;
    for i in 14 downto 0 loop
      wait until falling_edge(sclk_internal);   -- read data bits from ADC at falling edge always
      data_received(i) <= DOUT;
    end loop;
    wait until rising_edge(sclk_internal);
    cs_n <= '1';                                -- end of data transmission 
    sclk_enable <= '0';
    wait for quiet_time; 
    --wait;  					-- end of SPI testbench
  END PROCESS;

   -- define clocking scheme
  SCLK <= sclk_internal when sclk_enable = '1' else '1';
  sclk_internal <= not sclk_internal after 100 ns;
END;