LIBRARY IEEE;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;
USE IEEE.math_real.all;


ENTITY diode_E IS
  
  GENERIC (
           thermalVoltage: real :=25.0e-3;
           idealityFactor: real :=1.1; 
    	   saturationCurrent : real :=1.0e-9);        -- Widerstand

  PORT (
    TERMINAL a,c : ELECTRICAL);

END diode_E;

ARCHITECTURE simple OF diode_E IS
  QUANTITY u_d ACROSS i_d THROUGH a TO c;
BEGIN  -- simple

  i_d == saturationCurrent*(exp((u_d/(idealityFactor*thermalVoltage))-1.0));

END simple;