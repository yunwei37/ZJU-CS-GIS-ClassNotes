`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:24:52 06/18/2020
// Design Name:   sp6
// Module Name:   D:/Xilinx/project/sp6ex9/testsp6.v
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

module testsp6;

	// Inputs
	reg ext_clk_25m;
	reg ext_rst_n;
	reg [3:0] switch;

	// Outputs
	wire [3:0] dtube_cs_n;
	wire [7:0] dtube_data;
	wire [7:0] led;

	// Instantiate the Unit Under Test (UUT)
	sp6 uut (
		.ext_clk_25m(ext_clk_25m), 
		.ext_rst_n(ext_rst_n), 
		.switch(switch), 
		.dtube_cs_n(dtube_cs_n), 
		.dtube_data(dtube_data), 
		.led(led)
	);

	initial begin
		// Initialize Inputs
		ext_clk_25m = 0;
		switch = 4'b0000;
		ext_rst_n = 0;
		// Wait 100 ns for global reset to finish
		#200;
      ext_rst_n = 1;
		// Add stimulus here
		switch = 4'b0000;
	end
   always #25 ext_clk_25m = ~ext_clk_25m;
endmodule

