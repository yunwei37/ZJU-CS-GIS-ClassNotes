
 
 
 




#--------------------------------------------------------------------------------
#--
#--  BMG core Demo Testbench 
#--
#--------------------------------------------------------------------------------
# (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
# 
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
# 
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
# 
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
# 
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
# Filename: vcs_session.tcl
#
# Description:
#   This is the VCS wave form file.
#
#--------------------------------------------------------------------------------
if { ![gui_is_db_opened -db {bmg_vcs.vpd}] } {
	gui_open_db -design V1 -file bmg_vcs.vpd -nosource
}
gui_set_precision 1ps
gui_set_time_units 1ps

gui_open_window Wave
gui_sg_create mem_Group
gui_list_add_group -id Wave.1 {mem_Group}

      gui_sg_addsignal -group mem_Group  /mem_tb/status
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/CLKA
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/ADDRA
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/DINA
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/WEA
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/DOUTA
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/CLKB
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/ADDRB
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/DINB
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/WEB
      gui_sg_addsignal -group mem_Group  /mem_tb/mem_synth_inst/bmg_port/DOUTB

gui_zoom -window Wave.1 -full
