set project_dir    "./zybo_z7_20_misc"
set project_name   "zybo_z7_20_misc"
set project_target "xc7z020clg400-1"
set source_files {../../misc/arith_test.vhd \
                  ../../misc/logic_test.vhd \
		  ../../misc/xorshift.vhd \
		  ../../misc/full_addr.vhd \
		  ../../misc/half_addr.vhd \
		  ../../misc/stmt_test.vhd \
		  ../../misc/bitcount.vhd
		  ../../utils/pwm.vhd \
		  ./zybo_z7_20_misc.vhd \
		  }
set constraint_files {./zybo_z7_20_misc.xdc}

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
