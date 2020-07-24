`timescale 1ns / 1ps

module Ext_32(
		input [15:0] Imm_16,
		output [31:0] Imm_32
		);
	assign Imm_32 = {{16{Imm_16[15]}}, Imm_16};
endmodule
