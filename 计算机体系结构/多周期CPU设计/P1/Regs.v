`timescale 1ns / 1ps

module Regs(
		input clk,
		input rst,
		input L_S,
		input [4:0] R_addr_A,
		input [4:0] R_addr_B,
		input [4:0] Wt_addr,
		input [31:0] Wt_data,
		output [31:0] rdata_A,
		output [31:0] rdata_B
		);
	integer i;
	reg [31:0] register [1:31];
	initial begin
		for (i = 1; i < 32; i = i + 1) begin
				register[i] = 0;
		end
	end
	assign rdata_A = R_addr_A == 0 ? 0 : register[R_addr_A];

	assign rdata_B = R_addr_B == 0 ? 0 : register[R_addr_B];

	always @(posedge clk or posedge rst) begin
	//always @(posedge clk) begin
		if (rst) begin
			for (i = 1; i < 32; i = i + 1) begin
				register[i] <= 0;
			end
		end else if (L_S == 1 && Wt_addr != 0) begin
			register[Wt_addr] <= Wt_data;
		end
	end
endmodule
