`timescale 1ns / 1ps

module mux8to1(
		input [8 * WIDTH - 1:0] in,
		input [2:0] select,
		output [WIDTH - 1:0] out
		);

	parameter WIDTH = 1;

	assign out =
			select == 3'b000 ? in[WIDTH - 1:0] :
			select == 3'b001 ? in[2 * WIDTH - 1: WIDTH] :
			select == 3'b010 ? in[3 * WIDTH - 1: 2 * WIDTH] :
			select == 3'b011 ? in[4 * WIDTH - 1: 3 * WIDTH] :
			select == 3'b100 ? in[5 * WIDTH - 1: 4 * WIDTH] :
			select == 3'b101 ? in[6 * WIDTH - 1: 5 * WIDTH] :
			select == 3'b110 ? in[7 * WIDTH - 1: 6 * WIDTH] :
			in[8 * WIDTH - 1: 7 * WIDTH];
endmodule
