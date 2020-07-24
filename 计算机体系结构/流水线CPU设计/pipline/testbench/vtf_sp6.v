`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:03:44 05/11/2015
// Design Name:   sp6
// Module Name:   D:/ds/xilinx_sp6/prj/sp6ex_led_dll/testbench/vtf_sp6.v
// Project Name:  sp6
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: sp6
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vtf_sp6;

	// Inputs
	reg ext_clk_25m;
	reg ext_rst_n;
	
	// Outputs
	wire [7:0] led;

	// Instantiate the Unit Under Test (UUT)
	sp6 uut (
		.ext_clk_25m(ext_clk_25m), 
		.ext_rst_n(ext_rst_n), 
		.led(led),
		.switch(switch)
	);

	initial begin
		// Initialize Inputs
		ext_clk_25m = 0;
		ext_rst_n = 1;
		
		// Wait 100 ns for global reset to finish
		#100;
		ext_rst_n = 0;
      switch = 4'b0000;
		
		// Add stimulus here
		#1_000_000_000;
		$stop;
	end
   
always #20 ext_clk_25m = ~ext_clk_25m;
   
endmodule

