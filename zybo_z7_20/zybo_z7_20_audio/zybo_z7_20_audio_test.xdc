##Clock signal
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports CLK]
create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports CLK]

create_clock -period 8.000 -name main_clk -waveform {0.000 4.000} -add [get_pins U_CLK/clk_out1]
create_clock -period 81.300 -name ssm_mclk -waveform {0.000 40.600} -add [get_pins U_CLK/clk_out2]
create_clock -period 320 -name clk3072khz -waveform {0.000 160} -add [get_nets U/clk3072khz]

set_false_path -from [get_clocks main_clk] -to [get_clocks clk3072khz]
set_false_path -from [get_clocks clk3072khz] -to [get_clocks main_clk]
set_false_path -from [get_clocks ssm_mclk] -to [get_clocks clk3072khz]
set_false_path -from [get_clocks clk3072khz] -to [get_clocks ssm_mclk]

set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {BTN[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {BTN[1]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {BTN[2]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {BTN[3]}]

set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {SW[0]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {SW[1]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {SW[2]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {SW[3]}]

##Audio Codec
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports BCLK]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports MCLK]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports MUTE]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports PBDAT]
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports PBLRC]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports RECDAT]
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports RECLRC]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports SCL]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports SDA]
