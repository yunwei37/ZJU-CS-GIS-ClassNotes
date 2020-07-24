`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:52:07 04/03/2020
// Design Name:   mCPU
// Module Name:   D:/Xilinx/arch/P1/testCPU.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mCPU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testCPU;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire [31:0] PC_out;
	wire [31:0] ram_addr_in;
	wire [31:0] IR_out;
	wire [31:0] c_out;
	wire [3:0] state_out;
	// Instantiate the Unit Under Test (UUT)
	mCPU uut (
		.clk(clk), 
		.rst(rst), 
		.PC_out(PC_out),  
		.ram_addr_in(ram_addr_in), 
		.IR_out(IR_out), 
		.c_out(c_out),
		.state_out(state_out)
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
		rst = 1;
		// Wait 100 ns for global reset to finish
		#10;
      rst = 0;
		// Add stimulus here

	end
      
endmodule

