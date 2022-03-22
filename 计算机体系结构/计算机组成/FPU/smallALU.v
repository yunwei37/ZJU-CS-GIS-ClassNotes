`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:39:55 04/10/2020 
// Design Name: 
// Module Name:    smallALU 
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
module smallALU(
			input [8:0] A,
			input [8:0] B,
			input [1:0] ctrl,
			output [8:0] result
    );
	 assign result = ctrl[1]?
		(ctrl[0]?8'h00:($signed(A) - $signed(B))):
		(ctrl[0]?(A + 8'h7f - B):(A + B - 8'h7f));
endmodule
