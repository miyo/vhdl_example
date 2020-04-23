set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports CLK]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports CLK]

set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports UART_TX]
set_property -dict {PACKAGE_PIN A9  IOSTANDARD LVCMOS33} [get_ports UART_RX]

set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {LD[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {LD[1]}]

set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]
set_property -dict {PACKAGE_PIN B8 IOSTANDARD LVCMOS33} [get_ports {btn[3]}]

