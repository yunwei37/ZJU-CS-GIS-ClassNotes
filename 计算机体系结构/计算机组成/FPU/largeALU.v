`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:38:49 04/10/2020 
// Design Name: 
// Module Name:    largeALU 
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
module largeALU(
		input clk,
		input rst,
		input en,			// en = 1 开始计算,fin置0
		input [31:0] A,	
		input [31:0] B,
		input [1:0] ctrl, // 00 +, 01 -, 10 *, 11 /
		output reg [31:0] result, 
		output reg fin		//计算结束fin = 1
    );
	 wire [63:0] c;
	 wire [31:0] r;
	 assign c = A * B;
	assign r = ctrl[1]?
		(ctrl[0]?d[32:0]:{6'b0,c[47:22]}):
		(ctrl[0]?(A - B):(A + B));
	initial fin = 1'b1;
	
	wire [47:0] d;
	reg endiv;
	reg finflag;
	wire dfin;
	
	div_rill diver(.clk(clk),.rst(rst),.en(endiv),.a({A[23:0],24'b0}),.b({24'b0,B[23:0]}),.yshang(d),.calc_done(dfin));
	
	always@(posedge clk or posedge rst) begin
		if(rst) begin
			fin <= 1'b1;
			result <= 32'b0;
			finflag <= 1'b0;
			endiv <= 1'b0;
		end else begin
			if(en) begin
				if(ctrl == 2'b11) begin
					if(finflag) begin
						endiv <= 1'b0;
						fin <= 1'b1;
						finflag <= 1'b0;
					end else begin
						endiv <= 1'b1;
						fin <= 1'b0;
					end
				end else begin
					fin <= 1'b0;
					finflag <= 1'b0;
				end
			end 
			if(~fin) begin
				if(ctrl == 2'b11) begin
					endiv <= 1'b0;
					if(dfin & (~endiv) & (~finflag)) begin
							result <= r;
							fin <= 1'b1;
							finflag <= 1'b1;
					end
				end
				else begin
					result <= r;
					fin <= 1'b1;
				end
			end
		end
	end	
endmodule
