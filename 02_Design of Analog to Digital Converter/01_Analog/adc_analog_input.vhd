	-- ADC model for AN7922 (UBAS)
-- modeling the input stage according to datasheet but without sampling capacity

LIBRARY IEEE;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;
use IEEE.std_logic_1164.all;
use ieee.math_real.all;

ENTITY adc_analog_input_E IS
  
  GENERIC (
    input_resistance : real := 10.0e6;  -- input resistance of conversion module
    pin_resistance : real := 1.0;       -- pin resistance 
    pin_capacity : real := 6.0e-12; 	-- pin capacity (pin to ground)
    sw_resistance : real := 100.0;      -- switch & MUX resistance (pin to conversion)
    thermalVoltage: real :=25.0e-3;
    idealityFactor: real :=1.1;
    saturationCurrent : real :=1.0e-9);	

  PORT (
    TERMINAL V_in,V_out, GROUND, VPLUS : ELECTRICAL);

END adc_analog_input_E;

ARCHITECTURE struct OF adc_analog_input_E IS
  
  COMPONENT resistor_E
	GENERIC(resistance : real:=100.0);
	PORT(TERMINAL a,b: ELECTRICAL);
  END COMPONENT;
 
  COMPONENT capcitor_E
	GENERIC (capacitor : real := 20.0e-12);
	PORT(TERMINAL a,b: ELECTRICAL);
  END COMPONENT;

  COMPONENT diode_E
	GENERIC (thermalVoltage, idealityFactor, saturationCurrent : real);

	PORT(TERMINAL a,c: ELECTRICAL);
  END COMPONENT;

	TERMINAL intm : ELECTRICAL;
	
	BEGIN  

	R_P : ENTITY work.resistor_E(simple)
	GENERIC MAP (resistance => pin_resistance)
	PORT MAP( a => V_in,
		  b => intm);


	C_P : ENTITY work.capacitor_E(simple)
	GENERIC MAP (capacitance => pin_capacity)
	PORT MAP ( a => GROUND,
		   b => intm);

	D1 : ENTITY work.diode_E(simple)
	GENERIC MAP (thermalVoltage => thermalVoltage,
		     idealityFactor => idealityFactor,
		     saturationCurrent => saturationCurrent)
	PORT MAP ( a => intm,
		   c => VPLUS);

	D2 : ENTITY work.diode_E(simple)
	GENERIC MAP (thermalVoltage =>thermalVoltage,
		     idealityFactor => idealityFactor,
         	     saturationCurrent => saturationCurrent)
	PORT MAP ( a => GROUND,
		   c => intm);

	R_sw : ENTITY work.resistor_E(simple)
	GENERIC MAP (resistance => sw_resistance)
	PORT MAP( a => V_out,
		  b => intm);		
	
	R_in : ENTITY work.resistor_E(simple)
	GENERIC MAP (resistance => input_resistance)
	PORT MAP( a => GROUND,
		  b => V_out);
 
END struct;