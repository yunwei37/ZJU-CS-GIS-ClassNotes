`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:24:55 04/17/2020
// Design Name:   div_rill
// Module Name:   D:/Xilinx/org/floatpoint/testdiv.v
// Project Name:  floatpoint
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: div_rill
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testdiv;

	// Inputs
	reg clk;
	reg rst;
	reg en;
	reg [31:0] a;
	reg [31:0] b;

	// Outputs
	wire [31:0] yshang;
	wire [31:0] yyushu;
	wire calc_done;

	// Instantiate the Unit Under Test (UUT)
	div_rill uut (
		.clk(clk), 
		.rst(rst), 
		.en(en),
		.a(a), 
		.b(b), 
		.yshang(yshang), 
		.yyushu(yyushu), 
		.calc_done(calc_done)
	);
	
		always #10 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		en = 0;
		#50;
		rst = 0;
		en = 1;
		a = 35;
		b = 9;
		#50 
		en = 0;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

