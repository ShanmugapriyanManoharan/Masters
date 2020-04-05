LIBRARY IEEE;
USE IEEE.ELECTRICAL_SYSTEMS.ALL;

ENTITY capacitor_E IS
  
  GENERIC (
    capacitance : real := 6.0e-12);        -- Widerstand

  PORT (
    TERMINAL a,b : ELECTRICAL);

END capacitor_E;

ARCHITECTURE simple OF capacitor_E IS
  QUANTITY u_c ACROSS i_c THROUGH a TO b;
BEGIN  -- simple

  i_c == capacitance*u_c'dot;

END simple;