`timescale 1ns / 1ps

module REG32(
		input clk,
		input rst,
		input en,
		input [31:0] D,
		output reg [31:0] out
	);
	initial out <= 0;
	always @(posedge clk or posedge rst) begin
	//always @(posedge clk) begin
		if (rst) begin
			out <= 0;
		end else if (en) begin
			out <= D;
		end
	end
endmodule
