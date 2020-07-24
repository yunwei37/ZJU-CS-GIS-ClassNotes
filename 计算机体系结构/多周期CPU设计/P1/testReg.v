`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:26:35 04/03/2020
// Design Name:   REG32
// Module Name:   D:/Xilinx/arch/P1/testReg.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: REG32
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testReg;

	// Inputs
	reg clk;
	reg rst;
	reg en;
	reg [31:0] D;

	// Outputs
	wire [31:0] out;

	// Instantiate the Unit Under Test (UUT)
	REG32 uut (
		.clk(clk), 
		.rst(rst), 
		.en(en), 
		.D(D), 
		.out(out)
	);
	initial begin
		clk = 1'b0;
		forever begin
			clk = ~clk;
			#25;
		end
	end
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		en = 0;
		D = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

