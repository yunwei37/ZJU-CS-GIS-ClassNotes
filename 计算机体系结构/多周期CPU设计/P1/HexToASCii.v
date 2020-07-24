`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:37:51 04/05/2020 
// Design Name: 
// Module Name:    HexToASCii 
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
module HexToASCii(
			input [3:0] hex,
			output [7:0] ascii
    );
	 mux16to1  CHAR_SELECT (
			.in({"F"
				,"E"
				,"D"
				,"C"
				,"B"
				,"A"
				,"9"
				,"8"
				,"7"
				,"6"
				,"5"
				,"4"
				,"3"
				,"2"
				,"1"
				,"0"
			}),
			.select(hex),
			.out(ascii)
	);
endmodule
