`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:53:06 04/11/2020
// Design Name:   floatALU
// Module Name:   D:/Xilinx/org/floatpoint/testfloat.v
// Project Name:  floatpoint
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: floatALU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testfloat;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] A;
	reg [31:0] B;
	reg [1:0] c;
	reg en;

	// Outputs
	wire [31:0] result;
	wire fin;


	// Instantiate the Unit Under Test (UUT)
	FPU uut (
		.clk(clk), 
		.rst(rst), 
		.A(A), 
		.B(B), 
		.c(c), 
		.en(en), 
		.result(result), 
		.fin(fin)
	);
	
	always #50 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		
		clk = 0;
		rst = 1;
		#20;
		rst = 0; 
		//对照课程网站上的浮点数计算器
		/*
		A = 32'h3f800000;
		B = 32'h00000000;
		c = 2'b00;   // 1 0
		en = 1;
		#100;
		while(~fin) #50;
		c = 2'b01;
		#100;
		while(~fin) #50;
		c = 2'b10;
		#100;
		while(~fin) #50;
		c = 2'b11;
		#100;
		*/
		/*
		A = 32'h3f800000; //1
		B = 32'h3f800000; //1
		c = 2'b00;     // +
		en = 1;        // 40000000
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // 00000000
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// 3f800000
		while(~fin) #50;
		c = 2'b11;		// 3f800000
		#100;
      */
		/*
		A = 32'h40000000; //2
		B = 32'h40400000; //3
		c = 2'b00;     // +
		en = 1;        // 40A00000
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // BF800000
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// 40C00000
		while(~fin) #50;
		c = 2'b11;		// /
		#100;				// 3F2AAAAB
		*/
		
		/*
		A = 32'hc144cccd; //-12.3
		B = 32'h42f60000; //123
		c = 2'b00;     // +
		en = 1;        // 42DD6666
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // C3074CCD
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// C4BD1CCD
		while(~fin) #50;
		c = 2'b11;		// BDCCCCCD
		#100;
		*/
		
		/*
		A = 32'hbf2c9c4e; //-0.6742600202560425
		B = 32'hbd5ebd90; //-0.05437999963760376
		c = 2'b00;     // +
		en = 1;        // BF3A8827
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // BF1EB075
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// 3D162F5C
		while(~fin) #50;
		c = 2'b11;		// 4146627C
		#100;
		*/
		/*
		A = 32'h539c9c03; //1345264731312
		B = 32'h3e6db1f8; //0.23212421543
		c = 2'b00;     // +
		en = 1;        // 539C9C03
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // 539C9C03
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// 5291694F/5291694e
		while(~fin) #50;
		c = 2'b11;		//54A8AB7B
		#100;
		*/
		
		/*
		A = 32'h7F800000; //inf
		B = 32'h43270000; //167
		c = 2'b00;     // +
		en = 1;        // inf
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // inf
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// inf
		while(~fin) #50;
		c = 2'b11;		// inf
		#100;

		*/
	
		/*
		A = 32'h7F800000; //inf
		B = 32'hFF800000; //-inf
		c = 2'b00;     // +
		en = 1;        // NaN
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // Infinity
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// -Infinity
		while(~fin) #50;
		c = 2'b11;		// NaN
		#100;
		*/
		/*
		A = 32'h3eeb851f; //0.46
		B = 32'h4B000000; //NaN
		c = 2'b00;     // +
		en = 1;        // NaN
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // NaN
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// NaN
		while(~fin) #50;
		c = 2'b11;		// NaN
		#100;
		*/
		/*
		A = 32'h7f918658; //123456789012425232326524652335523542345678134761
		B = 32'h74c2c7cd; //123456789012345623523523578134761
		c = 2'b00;     // +
		en = 1;        // 7F91865B
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // 7F918655/7F918654
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// inf
		while(~fin) #50;
		c = 2'b11;		// 58635FA9 / 4a3f4363
		#100;
		*/
		
		A = 32'h60e74be5; //133333333333333333333
		B = 32'h081746ce; //0.00000000000000000000000000000000045523138246274825452
		c = 2'b00;     // +
		en = 1;        // 60E74BE5
		#100
		while(~fin) #50;
		c = 2'b01;     // -
		#100;          // 60E74BE5
		while(~fin) #50;
		c = 2'b10;		// *
		#100;				// 2988ADBD
		while(~fin) #50;
		c = 2'b11;		// inf
		#100;
		
	end
	
	
	
      
endmodule

