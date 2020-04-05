#CLK & RST
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports MAIN_CLK]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports MAIN_RST]

#BUTTONS
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports STOP]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports START]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports STEP]


#LCD OUTPUT
set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVCMOS33} [get_ports lcd_e]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS33} [get_ports lcd_rs]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {lcd_db[4]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {lcd_db[5]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {lcd_db[6]}]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports {lcd_db[7]}]

#Voltage
set_property CFGBVS Vcco [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


