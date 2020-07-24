`timescale 1ns / 1ps

module mux4to1(
		input [31:0] A,
		input [31:0] B,
		input [31:0] C,
		input [31:0] D,
		input [1:0] select,
		output [31:0] out
		);

	parameter WIDTH = 1;

	assign out =
			select[1]?(
				select[0]?D:C):(
				select[0]?B:A);
endmodule
