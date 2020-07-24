`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:02:26 04/02/2020 
// Design Name: 
// Module Name:    mCPU 
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
module mCPU(
		input clk,
		input rst,
		output [31:0] PC_out,
		output [31:0] ram_addr_in,
		output [31:0] DR_out,
		output [31:0] IR_out,
		output [31:0] c_out,
		output [3:0] state_out
    );
	 
	wire WritePC;
	wire [31:0] PC_in;
	//wire [31:0] PC_out;
	
	wire [31:0] next_PC;
	wire [31:0] branch_PC;
	
	wire IorD;
	
	wire WriteMem;
	//wire [31:0] ram_addr_in;
	wire [31:0] MEM_out;
	
	wire WriteIR;
	//wire [31:0] IR_out;
	
	wire WriteDR;
	//wire [31:0] DR_out;
	
	wire [25:0] j_target;
	assign j_target = IR_out[25:0];
	wire [5:0] op;
	assign op = IR_out[31:26];
	wire [5:0] func;
	assign func = IR_out[5:0];
	wire [4:0] rs;
	assign rs = IR_out[25:21];
	wire [4:0] rt;
	assign rt = IR_out[20:16];
	wire [4:0] rd;
	assign rd = IR_out[15:11];
	wire [15:0] imm;
	assign imm = IR_out[15:0];
	
	wire [31:0] imm32;
	
	wire MemToReg;
	
	wire WriteReg;
	wire [4:0] write_dst;
	wire [31:0] write_data;
	wire [31:0] reg_out_A;
	wire [31:0] reg_out_B;
	
	wire RegDst;
	assign write_dst = RegDst?rd:rt;
	
	wire WriteA;
	wire [31:0] a_out;
	
	wire WriteB;
	wire [31:0] b_out;
	
	wire ALUSrcA;
	wire ALUSrcB;
	
	wire [2:0] ALUC;
	wire [31:0] alu_in_a;
	wire [31:0] alu_in_b;
	wire [31:0] alu_out;
	wire Zero;
	
	wire WriteC;
	//wire [31:0] c_out;
	
	wire [1:0] PCSource;
	
	REG32 PC(.clk(clk),
			.rst(rst),
			.en(WritePC),
			.D(PC_in),
			.out(PC_out));
	
	AdderPC PC_adder_4(
		.A(PC_out),
		.B(32'h00000004),
		.out(next_PC)
	);
	
	AdderPC PC_adder_imm(
		.A(next_PC),
		.B({imm32[29:0],2'b00}),
		.out(branch_PC)
	);
	
	mux2to1 Data_IorD_mux(.A(PC_out),
		.B(c_out),
		.select(IorD),
		.out(ram_addr_in)
	);
	
	ram RAM(.datain(b_out),
			.addr(ram_addr_in),
			.WriteMem(WriteMem),
			.out(MEM_out));
	
	REG32 IR(.clk(clk),
			.rst(rst),
			.en(WriteIR),
			.D(MEM_out),
			.out(IR_out));

	Ext_32 imm_ex_32(.Imm_16(imm),
				.Imm_32(imm32));
	
	REG32 DR(.clk(clk),
			.rst(rst),
			.en(WriteDR),
			.D(MEM_out),
			.out(DR_out));
	
	mux2to1 REG_des_mux(.A(c_out),
			.B(DR_out),
			.select(MemToReg),
			.out(write_data));
	
	Regs RegFile(.clk(clk),
			.rst(rst),
			.L_S(WriteReg),
			.R_addr_A(rs),
			.R_addr_B(rt),
			.Wt_addr(write_dst),
			.Wt_data(write_data),
			.rdata_A(reg_out_A),
			.rdata_B(reg_out_B)
			);
	

	REG32 A(.clk(clk),
			.rst(rst),
			.en(WriteA),
			.D(reg_out_A),
			.out(a_out));
			
	REG32 B(.clk(clk),
			.rst(rst),
			.en(WriteB),
			.D(reg_out_B),
			.out(b_out));
	
	
	mux2to1 ALU_A_mux(.A(next_PC),
			.B(a_out),
			.select(ALUSrcA),
			.out(alu_in_a)
		);
	
	mux2to1 ALU_B_mux(.A(b_out),
			.B(imm32),
			.select(ALUSrcB),
			.out(alu_in_b)
			);
	
	ALU alu(.A(alu_in_a),
			.B(alu_in_b),
			.ALUC(ALUC),
			.result(alu_out),
			.zero(Zero));

	REG32 C(.clk(clk),
			.rst(rst),
			.en(WriteC),
			.D(alu_out),
			.out(c_out));

	mux4to1 PC_in_mux(.A(next_PC),
				.B(branch_PC),
				.C({next_PC[31:28],j_target,2'b0}),
				.D(32'b0),
				.select(PCSource),
				.out(PC_in)
		);
		
	CtrlUnit Ctrl(.clk(clk),
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
			.state_out(state_out)
			);
	
endmodule
