set project_dir    "./zybo_z7_20_audio_uart"
set project_name   "zybo_z7_20_audio_uart"
set project_target "xc7z020clg400-1"
set source_files { \
                   ../../drivers/i2c_ctrl/i2c_ctrl.vhd \
                   ../../drivers/i2s/i2s_decoder.vhd \
                   ../../drivers/i2s/i2s_encoder.vhd \
                   ../zybo_z7_20_audio/config_ssm2603.vhd \
                   ../zybo_z7_20_audio/if_ssm2603.vhd \
                 }
set constraint_files {./zybo_z7_20_audio_test.xdc}

create_project -force $project_name $project_dir -part $project_target
add_files -norecurse $source_files
add_files -fileset constrs_1 -norecurse $constraint_files

import_ip -files ../zybo_z7_20_audio/ip/clk_wiz_0.xci
import_ip -files ../zybo_z7_20_audio/ip/fifo_generator_0.xci
import_ip -files ../zybo_z7_20_audio/ip/div_gen_0.xci
import_ip -files ../zybo_z7_20_audio/ip/ila_0.xci

update_compile_order -fileset sources_1

upgrade_ip [get_ips fifo_generator_0]
upgrade_ip [get_ips div_gen_0]
upgrade_ip [get_ips clk_wiz_0]
upgrade_ip [get_ips ila_0]

reset_project

launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -jobs 4
wait_on_run impl_1

open_run impl_1
report_utilization -file [file join $project_dir "project.rpt"]
report_timing -file [file join $project_dir "project.rpt"] -append

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

close_project

quit
