create_clock -period 10.000 -name MAIN_CLK -waveform {0.000 5.000} [get_ports MAIN_CLK]
create_generated_clock -name Clk -source [get_ports MAIN_CLK] -divide_by 2 [get_pins Clk_reg/Q]

set_input_delay -clock [get_clocks MAIN_CLK] -min -add_delay 7.246 [get_ports MAIN_RST]
set_input_delay -clock [get_clocks MAIN_CLK] -max -add_delay 8.000 [get_ports MAIN_RST]
set_input_delay -clock [get_clocks MAIN_CLK] -min -add_delay 4.000 [get_ports START]
set_input_delay -clock [get_clocks MAIN_CLK] -max -add_delay 8.000 [get_ports START]
set_input_delay -clock [get_clocks MAIN_CLK] -min -add_delay 4.000 [get_ports STEP]
set_input_delay -clock [get_clocks MAIN_CLK] -max -add_delay 8.000 [get_ports STEP]
set_input_delay -clock [get_clocks MAIN_CLK] -min -add_delay 4.000 [get_ports STOP]
set_input_delay -clock [get_clocks MAIN_CLK] -max -add_delay 8.000 [get_ports STOP]

