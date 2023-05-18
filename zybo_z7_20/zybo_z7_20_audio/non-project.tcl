set_part xc7z020clg400-1
set_property default_lib work [current_project]

set source_files { \
                   ../../drivers/i2c_ctrl/i2c_ctrl.vhd \
                   ../../drivers/i2s/i2s_decoder.vhd \
                   ../../drivers/i2s/i2s_encoder.vhd \
                   ./zybo_z7_20_audio_test.vhd \
                   ./config_ssm2603.vhd \
                   ./if_ssm2603.vhd \
                 }

file mkdir ./ip/clk_wiz_0
file copy -force ./ip/clk_wiz_0.xci ./ip/clk_wiz_0
read_ip ./ip/clk_wiz_0/clk_wiz_0.xci

file mkdir ./ip/fifo_generator_0
file copy -force ./ip/fifo_generator_0.xci ./ip/fifo_generator_0
read_ip ./ip/fifo_generator_0/fifo_generator_0.xci

file mkdir ./ip/div_gen_0
file copy -force ./ip/div_gen_0.xci ./ip/div_gen_0
read_ip ./ip/div_gen_0/div_gen_0.xci

generate_target all [get_ips clk_wiz_0]
generate_target all [get_ips fifo_generator_0]
generate_target all [get_ips div_gen_0]

synth_ip [get_ips clk_wiz_0]
synth_ip [get_ips fifo_generator_0]
synth_ip [get_ips div_gen_0]

read_vhdl $source_files
read_xdc ./zybo_z7_20_audio_test.xdc

synth_design -top z7_audio_test
opt_design
place_design
route_design
write_bitstream -force top.bit

#write_project_tcl create_prj-of-non-project.tcl
