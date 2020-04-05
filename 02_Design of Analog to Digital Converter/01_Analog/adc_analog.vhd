-- ADC model for AN7922 (UBAS)
LIBRARY IEEE;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;
use IEEE.std_logic_1164.all;
use ieee.math_real.all;

ENTITY adc_analog_E IS
  
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

END adc_analog_E;

ARCHITECTURE simple OF adc_analog_E IS
  TERMINAL V_adc0, V_adc1 : ELECTRICAL;
  QUANTITY u_in0 ACROSS V_adc0 TO GROUND; -- i_in0 THROUGH
  QUANTITY u_in1 ACROSS V_adc1 TO GROUND; -- i_in1 THROUGH
  quantity u_dd ACROSS VPLUS to GROUND;
  quantity u_gnd ACROSS GROUND;
  signal busy_sig :std_logic:='0';
  signal voltage0, voltage1, voltagedd : real:= 0.0;
  signal volt_value_int : integer range 0 to 2**resolution_in_bit := 0;
 -- signal counter : integer range 0 to 17:= 0;
  --signal voltsave0, voltsave1 : real;
  
  COMPONENT adc_analog_input_E IS
    GENERIC (
      input_resistance : real := 10.0e6;  -- input resistance of conversion module
      pin_resistance : real := 1.0;       -- pin resistance 
      pin_capacity : real := 6.0e-12; 	-- pin capacity (pin to ground)
      sw_resistance : real := 100.0);	-- switch & MUX resistance (pin to conversion)
    PORT (
      TERMINAL V_in,V_out, GROUND, VPLUS : ELECTRICAL);
  END COMPONENT;


BEGIN  -- simple
    
  busy <= busy_sig;

  -- analog characteristics of input structure
  input0 : ENTITY work.adc_analog_input_E(struct)
   GENERIC MAP (
      sw_resistance => sw_resistance,
      pin_resistance => pin_resistance,
      pin_capacity => pin_capacity,
      input_resistance => input_resistance)
    PORT MAP (
      V_in => V_in0,
      V_out => V_adc0,
      GROUND => GROUND,
      VPLUS => VPLUS);
	   input1 : ENTITY work.adc_analog_input_E(struct)
   GENERIC MAP (
      sw_resistance => sw_resistance,
      pin_resistance => pin_resistance,
      pin_capacity => pin_capacity,
      input_resistance => input_resistance)
    PORT MAP (
      V_in => V_in1,
      V_out => V_adc1,
      GROUND => GROUND,
      VPLUS => VPLUS);


   -- purpose: Sampling input data
  -- type   : sequential
  -- inputs : 
  -- outputs: voltages as real
  sample_P: process 
    variable voltvar0, voltvar1, voltvardd, volt2convert : real;
  begin  -- process sample_P
     voltvar0 := 0.0;
     voltvar1 := 0.0;
     voltvardd := 5.0;
     --volt_value_int <= 0;
     busy_sig <= '0';
     wait until run_conversion'event and run_conversion = '1';
     busy_sig <= '1';
     wait for 200 ns;                   -- Delay from Track&Hold
     if u_in0 < u_gnd then              -- all is relative to ground potential
       voltvar0 := 0.0;
     elsif u_in0 > u_dd then            -- Exceeds Vdd?
       voltvar0 := u_dd;
     else
       voltvar0 := u_in0-u_gnd;         -- normal mode
     end if;
     if u_in1 < u_gnd then		
       voltvar1 := 0.0;
     elsif u_in1 > u_dd then
       voltvar1 := u_dd;
     else
	 voltvar1 := u_in1-u_gnd;
     end if;
     voltvardd := u_dd - u_gnd+1.0e-6;
     voltage0 <= voltvar0;
     voltage1 <= voltvar1;
     voltagedd <= voltvardd;
     if (channel_select = '0') then 
	volt2convert := voltvar0/voltvardd; 
     else
        volt2convert := voltvar1/voltvardd;
     end if;
       
     if (volt2convert < 1.0) then
        volt_value_int <= integer(floor(volt2convert * 2.0**(resolution_in_bit)));
     else
	volt_value_int <= 2**resolution_in_bit-1;
     end if;
     busy_sig <= '0';
     wait until run_conversion = '0';
  end process sample_P;
  
  outreal0 <= voltage0;
  outreal1 <= voltage1;
  outint <= volt_value_int;

END simple;