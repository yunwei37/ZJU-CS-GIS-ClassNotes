`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:26:03 04/02/2020 
// Design Name: 
// Module Name:    mux2to1 
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
module mux2to1(
		input [31:0] A,
		input [31:0] B,
		input select,
		output [31:0] out
    );
	assign out = select? B:A;

endmodule
