set project_dir    "./zybo_z7_20_uart"
set project_name   "zybo_z7_20_uart"
set project_target "xc7z020clg400-1"
set source_files { \
                   ../../drivers/uart/uart_tx.vhd \
                   ../../drivers/uart/uart_rx.vhd \
                   ../../drivers/uart/clk_div.vhd \
                   ./zybo_z7_20_uart.vhd \
		  }
set constraint_files {./zybo_z7_20_uart.xdc}

create_project -force $project_name $project_dir -part $project_target
add_files -norecurse $source_files
add_files -fileset constrs_1 -norecurse $constraint_files
update_compile_order -fileset sources_1

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
