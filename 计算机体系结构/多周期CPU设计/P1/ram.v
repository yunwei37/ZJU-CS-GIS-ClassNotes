`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:18:04 04/02/2020 
// Design Name: 
// Module Name:    ram 
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
module ram(
	input [31:0] datain,
	input [31:0] addr,
	input WriteMem,
	output [31:0] out
    );
	reg [31:0] data[255:0];
	integer i;
	initial begin
		for (i = 0; i < 256; i = i + 1) begin
				data[i] = 0;
		end
		$readmemh("memory.list",data);
	end
	assign out = data[addr[9:2]];
	always@(posedge WriteMem) begin
		data[addr[9:2]] <= datain;
	end
endmodule
