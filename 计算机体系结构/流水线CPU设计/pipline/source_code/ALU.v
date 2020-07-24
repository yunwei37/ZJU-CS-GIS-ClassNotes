`timescale 1ns / 1ps

module ALU(
	input [31:0] A,
	input [31:0] B,
	input [4:0] shamt,
	input [3:0] ALU_operation,
	output reg [31:0] res,
	output overflow
    );

wire [31:0] Bo, And, Or, Srl, Xor, Nor, Sll, Sra, Srlv, Srav, Sllv;
wire [32:0] Sum;
wire sub = ALU_operation[2];

	assign Bo = B ^ {32{sub}}; //if sub is True, Bo = 2^32 - 1 - B else B
	assign Sum = A + Bo + {~(A[31]^B[31]), 31'b0, ALU_operation[2]};
	//overflow occurs when:
	//sub A[31] B[31] S
	// 1   1     0    0
	// 1   0     1    1
	// 0   1     1    0
	// 0   0     0    1
	assign overflow = (Sum[31] & ~(A | (sub ^ B[31]))) | (~Sum[31] & (A & (sub ^ B[31])));
	assign And = A & B;
	assign Or = A | B;
	assign Srlv = B >> A[4:0];
	assign Sllv = B << A[4:0];
	assign Srav = B >>> A[4:0];
	assign Srl = B >> shamt; //extend to SRLV 
	assign Sll = B << shamt; //SLL, SLLV
	assign Sra = B >>> shamt;
	assign Xor = A ^ B;
	assign Nor = ~A & ~B;
    
always@(*)begin
	case(ALU_operation)
		4'b0000: res <= And;
		4'b0001: res <= Or;
		4'b0010: res <= Sum[31:0];
		4'b0011: res <= Xor;
		4'b0100: res <= Nor;
		4'b0101: res <= Srl;
		4'b0110: res <= Sum[31:0];
		4'b0111: res <= {31'b0, Sum[32]}; //slt
		4'b1000: res <= Sra;
		4'b1001: res <= Srlv;
		4'b1010: res <= Sllv;
		4'b1011: res <= Srav;
		4'b1101: res <= Sll;
		4'b1111: res <= (A < B);
	endcase
end
endmodule
