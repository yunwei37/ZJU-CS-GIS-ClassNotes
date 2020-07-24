`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:06:57 04/02/2020 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
	input [31:0] A,
	input [31:0] B,
	input [2:0] ALUC,
	output [31:0] result,
	output zero
    );
	assign result = 
		ALUC[2]?
		(ALUC[1]?(
			ALUC[0]? {31'b0, $signed(A) < $signed(B)} : {31'b0, A < B}):(
			ALUC[0]? ~(A|B) : A^B )):
		(ALUC[1]?(
			ALUC[0]? A|B : A&B):(
			ALUC[0]? A-B : A+B));
	assign zero = ~|result;	


endmodule
