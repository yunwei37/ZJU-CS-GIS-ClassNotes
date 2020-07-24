# file: wave.sv
# 
# (c) Copyright 2008 - 2010 Xilinx, Inc. All rights reserved.
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
#
# Get the windows set up
#
if {[catch {window new WatchList -name "Design Browser 1" -geometry 1054x819+536+322}] != ""} {
    window geometry "Design Browser 1" 1054x819+536+322
}
window target "Design Browser 1" on
browser using {Design Browser 1}
browser set \
    -scope nc::pll_controller_tb
browser yview see nc::pll_controller_tb
browser timecontrol set -lock 0

if {[catch {window new WaveWindow -name "Waveform 1" -geometry 1010x600+0+541}] != ""} {
    window geometry "Waveform 1" 1010x600+0+541
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar visibility partial
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 75
cursor set -using TimeA -time 0
waveform baseline set -time 0
waveform xview limits 0 20000n

#
# Define signal groups
#
catch {group new -name {Output clocks} -overlay 0}
catch {group new -name {Status/control} -overlay 0}
catch {group new -name {Counters} -overlay 0}

set id [waveform add -signals [list {nc::pll_controller_tb.CLK_IN1}]]

group using {Output clocks}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    {pll_controller_tb.dut.clk[1]} \
    {pll_controller_tb.dut.clk[2]}  \     {pll_controller_tb.dut.clk[3]}  \     {pll_controller_tb.dut.clk[4]}  

group using {Counters}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    {pll_controller_tb.dut.counter[1]} \
    {pll_controller_tb.dut.counter[2]}  \     {pll_controller_tb.dut.counter[3]}  \     {pll_controller_tb.dut.counter[4]}  

group using {Status/control}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
   {nc::pll_controller_tb.RESET}    {nc::pll_controller_tb.LOCKED}


set id [waveform add -signals [list {nc::pll_controller_tb.COUNT} ]]

set id [waveform add -signals [list {nc::pll_controller_tb.test_phase} ]]
waveform format $id -radix %a

set groupId [waveform add -groups {{Input clocks}}]
set groupId [waveform add -groups {{Output clocks}}]
set groupId [waveform add -groups {{Status/control}}]
set groupId [waveform add -groups {{Counters}}]
