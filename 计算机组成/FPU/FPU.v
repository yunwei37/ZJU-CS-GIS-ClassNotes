`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:41:11 04/10/2020 
// Design Name: 
// Module Name:    floatALU 
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
module FPU(
	input clk, 
	input rst,
	input [31:0] A,
	input [31:0] B,
	input [1:0] c, // 00 +, 01 -, 10 *, 11 /
	input en,			// en = 1, begin
	output reg [31:0] result,
	output reg fin		// fin = 1 when finish
    );
	 
	reg [8:0] ae;
	reg [8:0] be;
	reg [31:0] am;
	reg [31:0] bm;
	reg af;
	reg bf;
	
	reg [1:0] state;
	initial state = 2'b00;
	initial fin = 1'b1;
	reg [1:0] ctrl;
	
	initial sALUc = 2'b00;
	reg [1:0] sALUc;
	//wire [8:0] sA;
	//wire [8:0] sB;
	wire [8:0] sr;
	smallALU sALU(.A(ae),.B(be),.ctrl(sALUc),.result(sr));
	
	wire [8:0] adder1r;
	addone adder1(.A(be),.ctrl(1'b0),.result(adder1r));
	
	wire [8:0] adder2r;
	addone adder2(.A(ae),.ctrl(1'b0),.result(adder2r));
	
	wire [8:0] adder3r;
	addone adder3(.A(ae),.ctrl(1'b1),.result(adder3r));
	
	initial lALUc = 2'b00;
	reg [1:0] lALUc;
	//wire [47:0] lA;
	//wire [47:0] lB;
	wire [31:0] lr;
	reg lALUen, lALUused;
	wire lALUfin;
	largeALU lALU(.clk(clk),.rst(rst),.en(lALUen),.A(am),.B(bm),.ctrl(lALUc),.result(lr),.fin(lALUfin));
	
	wire aNaN;
	wire bNaN;
	assign aNaN = (A == 32'h4B000000)?1'b1:1'b0;
	assign bNaN = (B == 32'h4B000000)?1'b1:1'b0;
	
	wire aInf;
	wire bInf;
	assign aInf = (A[30:0] == 31'h7F800000)?1'b1:1'b0;
	assign bInf = (B[30:0] == 31'h7F800000)?1'b1:1'b0;
	
	always@(posedge clk or posedge rst) begin
		if(rst) begin
			state <= 2'b00;
			fin <= 1'b1;
			result <= 32'h00000000;
			lALUc <= 2'b00;
			sALUc <= 2'b00;
			lALUen <= 1'b0;
			lALUused <= 1'b0;
		end else begin
			case(state)
				2'b00:begin //state 0
							if(en) begin  
								if(((|A)&(~(|A[30:23])))|((|B)&(~(|B[30:23])))|aNaN|bNaN) begin // 非规格化浮点数或NaN
										state <= 2'b00;
										fin <= 1'b1;
										result <= 32'h4B000000;
								end else begin
									fin <= 1'b0;
									af <= A[31];
									ae <= {1'b0,A[30:23]};
									be <= {1'b0,B[30:23]};
									lALUused <= 1'b0;
									lALUen <= 1'b0;
									case(c)
										2'b00,2'b01:begin // state 0 add, sub
													sALUc <= 2'b10;
													am <= (|A)?{2'b01,A[22:0],7'b0}:32'b0;
													bm <= (|B)?{2'b01,B[22:0],7'b0}:32'b0;
													ctrl <= 2'b00;													
													bf <= c[0]?(~B[31]):(B[31]); //sub 符号位取反
													if(aInf | bInf) begin // inf
														if(aInf & bInf) begin
															result <= (c[0]^A[31]^B[31])? (32'h4B000000):((A[31])?32'hFF800000:32'h7F800000);
															state <= 2'b00;
															fin <= 1'b1;
														end else begin // a or b is inf
															state <= 2'b00;
															fin <= 1'b1;
															result <= aInf? A:B;
														end
													end else begin
														state <= 2'b01;
													end
												end
										2'b10:begin // state 0 mul
													sALUc <= 2'b00;
													ctrl <= 2'b10;
													bf <= B[31];
													am <= {8'b0,1'b1,A[22:0]};
													bm <= {8'b0,1'b1,B[22:0]};													
													if((~(|A))|(~(|B))) begin // a == 0 or b == 0
														state <= 2'b00;
														fin <= 1'b1;
														result <= 32'h00000000;
													end else begin
														if(aInf | bInf) begin
															result <= (A[31]^B[31])? 32'hFF800000:32'h7F800000;
															state <= 2'b00;
															fin <= 1'b1;
														end else begin
															state <= 2'b01;
														end
													end
												end
										2'b11:begin // state 0 div
													if((~(|B)) | aInf) begin
														if(aInf & bInf) begin
																state <= 2'b00;
																fin <= 1'b1;
																result <= 32'h4B000000;
														end else begin
															state <= 2'b00;
															fin <= 1'b1;
															result <= (A[31])? 32'hFF800000:32'h7F800000;
														end
													end else begin
														if(bInf) begin
																state <= 2'b00;
																fin <= 1'b1;
																result <= 32'h00000000;									
														end else begin
															sALUc <= 2'b01;
															ctrl <= 2'b11;
															bf <= B[31];
															am <= {8'b0,1'b1,A[22:0]};
															bm <= {8'b0,1'b1,B[22:0]};
															state <= 2'b01;		
														end
													end											
												end
									endcase
								end
							end
				end
				2'b01:begin //state 1
						case(ctrl)
							2'b00,2'b01:begin // state 1 add, sub
									if(sr[8]) begin		// A > B, 交换AB
										state <= 2'b01;
										am <= bm;
										bm <= am;
										ae <= be;
										be <= ae;
										af <= bf;
										bf <= af;
									end
									else begin
										if(|sr) begin
											if( sr > 32 ) begin // a >> b，避免进行过长的位移操作浪费时间
												state <= 2'b01;
												be <= ae;
												bm <= 32'b0;
											end
											else begin
												state <= 2'b01;
												be <= adder1r;
												bm <= {1'b0,bm[31:1]};
											end
										end
										else begin
											state <= 2'b10;
											case({af,bf})   // 根据符号位设置ALU加法或减法
												2'b00:begin // 正数正数
													lALUc <= 2'b00;
													af <= 1'b0;
												end
												2'b10:begin // 负数正数
													lALUc <= 2'b01;
													af <= 1'b1;
												end
												2'b01:begin // 正数负数
													lALUc <= 2'b01;
													af <= 1'b0;
												end
												2'b11:begin // 负数负数
													lALUc <= 2'b00;
													af <= 1'b1;
												end
											endcase
										end
									end	
							end
							2'b10:begin // state 1 mul
									state <= 2'b10;
									lALUc <= 2'b10;
									af <= af^bf;
									ae <= sr;
							end
							2'b11:begin // state 1 div
								state <= 2'b10;
								lALUc <= 2'b11;
								af <= af^bf;
								ae <= sr;
							end
						endcase
				end
				2'b10:begin //state 2
					case(ctrl)
						2'b00,2'b01:begin // state 2 add, sub
								if(am < bm) begin // 如果指数相等，保证大数减小数
									state <= 2'b10;
									am <= bm;
									bm <= am;
									if(lALUc == 2'b01) af <= ~af;
								end
								else begin			// 从ALU获得计算完成的结果
									if(~lALUen) begin
										lALUen <= 1'b1;  
										state <= 2'b10;
										lALUused <= 1'b1;
									end else begin
										if(lALUfin&(~lALUused)) begin
											am <= {6'b0,lr[31:7],1'b0};
											state <= 2'b11; 
											lALUen <= 1'b0;
										end else begin
											state <= 2'b10;
											lALUused <= 1'b0;
										end
									end
								end
						end
						2'b10,2'b11:begin  // state 2 mul, div
							if(~lALUen) begin
								lALUen <= 1'b1;
								state <= 2'b10;
								lALUused <= 1'b1;
							end else begin
								if(lALUfin&(~lALUused)) begin
									am <= lr;				// 从ALU获得计算完成的结果
									state <= 2'b11;	
									lALUen <= 1'b0;
								end else begin
									state <= 2'b10;
									lALUused <= 1'b0;
								end
							end	
						end
					endcase
				end
				2'b11:begin //state 3
							if(|(am&32'hfe000000))begin //右移规格化
								ae <= adder2r;
								am <= {1'b0,am[31:1]};
								state <= 2'b11;
							end
							else begin
								if((!(am&32'h01000000))&&(|am))begin //左移规格化
									ae <= adder3r;
									am <= {am[30:0],1'b0};
									state <= 2'b11;
								end
								else begin
									if(ae[8]) begin // 判断指数部分是否溢出
										state <= 2'b00;
										fin <= 1'b1;
										result <= 32'h7F800000;
									end else begin
										if((&am[23:1])&am[0]) begin // 四舍五入导致进位需要再次规格化的情况
											state <= 2'b11;
											am[24:0] <= 25'b0;
											am[25] <= 1'b1;
										end else begin
											state <= 2'b00;
											fin <= 1'b1;
											result[31] <= (|am)?af:1'b0;
											result[30:23] <= (|am)?ae[7:0]:8'h00;
											result[22:0] <= am[0]?(am[23:1]+23'b01):am[23:1];	
										end
									end
								end
							end
				end
			endcase
		end
	end
		
endmodule
