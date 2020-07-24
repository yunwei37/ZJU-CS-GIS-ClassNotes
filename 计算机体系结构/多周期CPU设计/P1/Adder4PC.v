`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:38:15 04/02/2020 
// Design Name: 
// Module Name:    Adder4PC 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module AdderPC(
	input [31:0] A,
	input [31:0] B,
	output [31:0] out
    );
	assign out = A+B;

endmodule
