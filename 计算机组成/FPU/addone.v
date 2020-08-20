`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:40:49 04/11/2020 
// Design Name: 
// Module Name:    addone 
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
module addone(
			input [8:0] A,
			input ctrl,
			output [8:0] result
    );
	assign result = ctrl?(A-9'b000000001):(A+9'b000000001);

endmodule
