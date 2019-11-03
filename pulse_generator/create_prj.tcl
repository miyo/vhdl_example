set project_dir "./prj"
set project_name "pulse_generator"
set project_target "xc7z020clg400-1"
set ip_dir "./ip/pulse_generator"

set vendor_name "wasa-labo.com"

set source_files { \
		       ./hdl/pulse_generator_kernel.vhd \
		       ./hdl/pulse_generator.v \
		       ./hdl/pulse_generator_S00_AXI.v \
		   }

set tb_files { \
		   ./tb/pulse_generator_kernel_sim.vhd \
	       }

create_project -force $project_name $project_dir -part $project_target

add_files -norecurse $source_files
update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $tb_files
update_compile_order -fileset sim_1

reset_project

launch_runs synth_1 -jobs 4
wait_on_run synth_1

ipx::package_project -root_dir . -vendor $vendor_name -library user -taxonomy /UserIP -force
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

quit
