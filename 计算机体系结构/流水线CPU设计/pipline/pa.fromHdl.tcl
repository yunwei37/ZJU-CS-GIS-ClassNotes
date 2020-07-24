
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name sp6 -dir "D:/ds/xilinx_sp6/prj/sp6ex_beep2/planAhead_run_5" -part xc6slx9tqg144-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "sp6.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {source_code/sp6.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top sp6 $srcset
add_files [list {sp6.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-2
