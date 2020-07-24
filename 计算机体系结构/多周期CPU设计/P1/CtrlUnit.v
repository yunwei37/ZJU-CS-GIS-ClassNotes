`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:30:27 04/02/2020 
// Design Name: 
// Module Name:    CtrlUnit 
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
module CtrlUnit(
	input clk, 
	input rst,
	input	[5:0] op,
	input [5:0] func,
	input Zero,
	output reg WritePC,
	output reg IorD, 
	output reg WriteMem, 
	output reg WriteDR, 
	output reg WriteIR, 
	output reg MemToReg, 
	output reg RegDst,
	output reg [1:0] PCSource,
	output reg WriteC,
	output reg [2:0] ALUC,
	output reg ALUSrcA,
	output reg ALUSrcB,
	output reg WriteA, 
	output reg WriteB, 
	output reg WriteReg,
	
	output [3:0] state_out
    );
	reg [3:0] state;
	assign state_out = state;
	//state
	localparam
			IF = 4'b0000,
			ID = 4'b0001,
			EX_R = 4'b0010,
			WB_R = 4'b1000,
			EX_LD = 4'b0011,
			MEM_RD = 4'b0101,
			WB_LS = 4'b1001,
			EX_ST = 4'b0100,
			MEM_ST = 4'b0111;
	
	// op
	localparam
			R = 6'b000000,
			LW = 6'b100011,
			SW = 6'b101011,
			BEQ = 6'b000100,
			BNE = 6'b000101,
			J = 6'b000010,
			ADDi = 6'b001000,
			SLTi = 6'b001010,
			ANDi = 6'b001100,
			ORi = 6'b001101,
			XORi = 6'b001110;
			
		
	//func
	localparam	
			ADD = 6'b100000,
			SUB = 6'b100010,
			SLT = 6'b101010,
			AND = 6'b100100,
			OR = 6'b100101,
			XOR = 6'b100110,
			NOR = 6'b100111;

	task startIF;
		begin
			WritePC <= 1'b0;
			IorD <= 1'b0;
			WriteMem <= 1'b0;
			WriteDR <= 1'b0;
			WriteIR <= 1'b1; //
			MemToReg <= 1'b0; 
			RegDst <= 1'b0;
			PCSource <= 2'b00;
			WriteC <= 1'b0;
			ALUC <= 3'b000;
			ALUSrcA <= 1'b0;
			ALUSrcB <= 1'b0;
			WriteA <= 1'b0;
			WriteB <= 1'b0; 
			WriteReg <= 1'b0;
			state <= IF;
		end
	endtask

	initial begin
		startIF;
	end

	always @(posedge clk or posedge rst) begin
	//always @(posedge clk) begin
		if(rst) begin
			startIF;
		end
		else begin
			case(state)
				IF:begin
					WriteIR <= 1'b0; 
					state <= ID;
					WriteA <= 1'b1;
					WriteB <= 1'b1;
				end
				ID:begin
					case(op)
						J:begin
							WritePC <= 1'b1;
							PCSource <= 2'b10;
							state <= WB_R;
						end
						R:begin
							case(func)
								ADD: ALUC <=3'b000;
								SUB: ALUC <=3'b001;
								SLT: ALUC <=3'b111;
								AND: ALUC <=3'b010;
								OR:  ALUC <=3'b011;
								XOR: ALUC <=3'b100;
								NOR: ALUC <=3'b101;
							endcase
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b0;
							state <= EX_R;
							WriteC <=1'b1;
						end
						LW:begin
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b1;
							ALUC <= 3'b000;
							WriteC <=1'b1;
							state <= EX_LD;
						end
						SW:begin
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b1;
							ALUC <= 3'b000;
							WriteC <=1'b1;							
							state <= EX_ST;
						end
						BEQ:begin
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b0;
							ALUC <= 3'b001;
							WriteC <=1'b1;
							state <= EX_R;
						end
						BNE:begin
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b0;
							ALUC <= 3'b001;
							WriteC <=1'b1;
							state <= EX_R;
						end
						ADDi:begin
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b1;
							ALUC <=3'b000;
							WriteC <=1'b1;
							state <= EX_R;
						end
						ANDi:begin
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b1;
							ALUC <=3'b010;
							WriteC <=1'b1;
							state <= EX_R;
						end
						ORi:begin
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b1;
							ALUC <=3'b011;
							WriteC <=1'b1;
							state <= EX_R;
						end
						XORi:begin
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b1;
							ALUC <=3'b100;
							WriteC <=1'b1;
							state <= EX_R;
						end
						SLTi:begin
							ALUSrcA <= 1'b1;
							ALUSrcB <= 1'b1;
							ALUC <=3'b111;
							WriteC <=1'b1;
							state <= EX_R;
						end
						default:begin
							WritePC <= 1'b1;
							PCSource <= 2'b00;
							state <= WB_R;
						end
					endcase
				end
				EX_R:begin
					case(op)
						BEQ:begin							
							PCSource <= Zero? 2'b01:2'b00;							
						end
						BNE:begin							
							PCSource <= Zero? 2'b00:2'b01;							
						end
						R:begin
							RegDst <= 1'b1;
							WriteReg <= 1'b1;
							PCSource <= 2'b00;
						end
						ADDi,ANDi,ORi,XORi,SLTi:begin
							RegDst <= 1'b0;
							WriteReg <= 1'b1;
							PCSource <= 2'b00;						
						end
					endcase
					MemToReg <= 1'b0;
					WritePC <= 1'b1;
					state <= WB_R;
				end
				WB_R:begin
					startIF;
				end
				EX_LD:begin
					IorD <= 1'b1;
					state <= MEM_RD;
					WriteDR <=1'b1;
				end
				MEM_RD:begin
					RegDst <=1'b0;
					WriteReg <= 1'b1;
					PCSource <= 2'b00;
					WritePC <= 1'b1;
					MemToReg <= 1'b1;
					state <= WB_LS;
				end
				WB_LS:begin
					startIF;
				end
				EX_ST:begin
					WriteMem <= 1'b1;
					IorD <= 1'b1;
					state <= MEM_ST;
				end
				MEM_ST:begin
					PCSource <= 2'b00;
					WritePC <= 1'b1;
					state <= WB_LS;
				end
			endcase
		end
	end

endmodule
