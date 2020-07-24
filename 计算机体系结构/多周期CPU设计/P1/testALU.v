`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:16:08 04/02/2020
// Design Name:   ALU
// Module Name:   D:/Xilinx/arch/P1/testALU.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ALU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testALU;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;
	reg [2:0] ALUC;

	// Outputs
	wire [31:0] result;
	wire zero;

	// Instantiate the Unit Under Test (UUT)
	ALU uut (
		.A(A), 
		.B(B), 
		.ALUC(ALUC), 
		.result(result), 
		.zero(zero)
	);

	initial begin
		// Initialize Inputs
		A = 32'h00000002;
		B = 32'h00000003;
		for(ALUC=0;ALUC<7;ALUC=ALUC+1) begin
			#50;
		end
		#50;
		A = 32'hfffffff0;
		B = 32'h00000003;
		for(ALUC=0;ALUC<7;ALUC=ALUC+1) begin
			#50;
		end
	end
      
endmodule

