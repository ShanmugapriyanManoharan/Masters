-- ADC model for AN7922 (UBAS)
LIBRARY IEEE;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;
use IEEE.std_logic_1164.all;
use ieee.math_real.all;

ENTITY adc_top_E IS
  
 GENERIC (
    resolution_in_bit : integer := 12;
    input_resistance : real := 10.0e6;  -- input resistance of conversion module
    pin_resistance : real := 1.0;       -- pin resistance 
    pin_capacity : real := 6.0e-12; 	-- pin capacity (pin to ground)
    sw_resistance : real := 100.0);	-- switch & MUX resistance (pin to conversion)

  PORT (
    TERMINAL V_in0,V_in1, GROUND, VPLUS : ELECTRICAL;
    signal DIN, CS_n, sclk : in std_logic;
    signal DOUT : out std_logic);

END adc_top_E;

ARCHITECTURE struct OF adc_top_E IS
  signal adc_busy, adc_run, adc_channel : std_logic;
  signal volt_integer : integer range 0 to 2**resolution_in_bit-1 := 0;
  signal volt_channel0, volt_channel1 : real;

  COMPONENT adc_digital_E
  GENERIC (resolution : integer := 12);  -- Bitwidth
  PORT (
    DIN, CS_n, sclk  	: in std_logic;     		-- SPI inputs
    DOUT 		: out std_logic;                -- SPI output
    run_conv 	: out std_logic;    		-- trigger analog part
    ch_sel 	: out std_logic;      		-- select analog input
    volt_in : in integer range 0 to 2**resolution-1; 	-- sampled integer value 
    busy 		: in std_logic);             	-- volt_in is not valid
  END COMPONENT;
  
   COMPONENT adc_analog_E  
 GENERIC (
    resolution_in_bit : integer := 12;
    input_resistance : real := 10.0e6;  -- input resistance of conversion module
    pin_resistance : real := 1.0;       -- pin resistance 
    pin_capacity : real := 6.0e-12; 	-- pin capacity (pin to ground)
    sw_resistance : real := 100.0);	-- switch & MUX resistance (pin to conversion)
  PORT (
    TERMINAL V_in0,V_in1, GROUND, VPLUS : ELECTRICAL;
    signal run_conversion, channel_select : in std_logic;
    signal busy : out std_logic;
    signal outreal1, outreal0 : out real;
    signal outint : out integer);
  END COMPONENT;

BEGIN  
  digital_adc : adc_digital_E
  GENERIC MAP(resolution_in_bit)
  PORT MAP(DIN => DIN,
	CS_n => CS_n,
	sclk => sclk,
	DOUT => DOUT,
	volt_in => volt_integer,
	run_conv => adc_run,
	ch_sel => adc_channel,
	busy => adc_busy);

	analog_adc : adc_analog_E
  GENERIC MAP(resolution_in_bit, input_resistance, pin_resistance, pin_capacity, sw_resistance)
  PORT MAP(
	V_in0 => V_in0,
	V_in1 => V_in1,
	VPLUS => VPLUS,
	GROUND => GROUND,
	outint => volt_integer,
	outreal0 => volt_channel0,
	outreal1 => volt_channel1, 
	run_conversion => adc_run,
	channel_select => adc_channel,
	busy => adc_busy);

 
END struct;