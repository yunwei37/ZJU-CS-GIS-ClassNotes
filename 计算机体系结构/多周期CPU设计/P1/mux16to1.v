`timescale 1ns / 1ps
module mux16to1(
		input [128 - 1:0] in,
		input [3:0] select,
		output [7:0] out
		);
	parameter WIDTH = 8;

	assign out =
			select == 4'b0000 ? in[WIDTH - 1:0] :
			select == 4'b0001 ? in[2 * WIDTH - 1: WIDTH] :
			select == 4'b0010 ? in[3 * WIDTH - 1: 2 * WIDTH] :
			select == 4'b0011 ? in[4 * WIDTH - 1: 3 * WIDTH] :
			select == 4'b0100 ? in[5 * WIDTH - 1: 4 * WIDTH] :
			select == 4'b0101 ? in[6 * WIDTH - 1: 5 * WIDTH] :
			select == 4'b0110 ? in[7 * WIDTH - 1: 6 * WIDTH] :
			select == 4'b0111 ? in[8 * WIDTH - 1: 7 * WIDTH] :
			select == 4'b1000 ? in[9 * WIDTH - 1: 8 * WIDTH] :
			select == 4'b1001 ? in[10 * WIDTH - 1: 9 * WIDTH] :
			select == 4'b1010 ? in[11 * WIDTH - 1: 10 * WIDTH] :
			select == 4'b1011 ? in[12 * WIDTH - 1: 11 * WIDTH] :
			select == 4'b1100 ? in[13 * WIDTH - 1: 12 * WIDTH] :
			select == 4'b1101 ? in[14 * WIDTH - 1: 13 * WIDTH] :
			select == 4'b1110 ? in[15 * WIDTH - 1: 14 * WIDTH] :
			in[16 * WIDTH - 1: 15 * WIDTH];
endmodule
