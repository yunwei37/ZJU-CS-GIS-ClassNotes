gui_open_window Wave
gui_sg_create pll_controller_group
gui_list_add_group -id Wave.1 {pll_controller_group}
gui_sg_addsignal -group pll_controller_group {pll_controller_tb.test_phase}
gui_set_radix -radix {ascii} -signals {pll_controller_tb.test_phase}
gui_sg_addsignal -group pll_controller_group {{Input_clocks}} -divider
gui_sg_addsignal -group pll_controller_group {pll_controller_tb.CLK_IN1}
gui_sg_addsignal -group pll_controller_group {{Output_clocks}} -divider
gui_sg_addsignal -group pll_controller_group {pll_controller_tb.dut.clk}
gui_list_expand -id Wave.1 pll_controller_tb.dut.clk
gui_sg_addsignal -group pll_controller_group {{Status_control}} -divider
gui_sg_addsignal -group pll_controller_group {pll_controller_tb.RESET}
gui_sg_addsignal -group pll_controller_group {pll_controller_tb.LOCKED}
gui_sg_addsignal -group pll_controller_group {{Counters}} -divider
gui_sg_addsignal -group pll_controller_group {pll_controller_tb.COUNT}
gui_sg_addsignal -group pll_controller_group {pll_controller_tb.dut.counter}
gui_list_expand -id Wave.1 pll_controller_tb.dut.counter
gui_zoom -window Wave.1 -full
