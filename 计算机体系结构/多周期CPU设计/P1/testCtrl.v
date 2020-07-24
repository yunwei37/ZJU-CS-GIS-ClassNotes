`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:44:02 04/03/2020
// Design Name:   CtrlUnit
// Module Name:   D:/Xilinx/arch/P1/testCtrl.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CtrlUnit
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testCtrl;

	// Inputs
	reg clk;
	reg rst;
	reg [5:0] op;
	reg [5:0] func;
	reg Zero;

	// Outputs
	wire WritePC;
	wire IorD;
	wire WriteMem;
	wire WriteDR;
	wire WriteIR;
	wire MemToReg;
	wire RegDst;
	wire [1:0] PCSource;
	wire WriteC;
	wire [2:0] ALUC;
	wire ALUSrcA;
	wire ALUSrcB;
	wire WriteA;
	wire WriteB;
	wire WriteReg;
	wire [3:0] state_out;
	wire insn_type;
	wire insn_code;
	wire insn_stage;

	// Instantiate the Unit Under Test (UUT)
	CtrlUnit uut (
		.clk(clk), 
		.rst(rst), 
		.op(op), 
		.func(func), 
		.Zero(Zero), 
		.WritePC(WritePC), 
		.IorD(IorD), 
		.WriteMem(WriteMem), 
		.WriteDR(WriteDR), 
		.WriteIR(WriteIR), 
		.MemToReg(MemToReg), 
		.RegDst(RegDst), 
		.PCSource(PCSource), 
		.WriteC(WriteC), 
		.ALUC(ALUC), 
		.ALUSrcA(ALUSrcA), 
		.ALUSrcB(ALUSrcB), 
		.WriteA(WriteA), 
		.WriteB(WriteB), 
		.WriteReg(WriteReg), 
		.state_out(state_out), 
		.insn_type(insn_type), 
		.insn_code(insn_code), 
		.insn_stage(insn_stage)
	);
	initial begin
		clk = 1'b0;
		forever begin
			clk = ~clk;
			#25;
		end
	end
	initial begin
		// Initialize Inputs
		clk = 1'b0;
		rst = 1'b1;
		#20
		rst = 1'b0;
		op = 6'b000000;
		func = 6'b100000;
		Zero = 1'b0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

