`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:02:36 04/05/2020 
// Design Name: 
// Module Name:    CPUtop 
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
// Spartan-3E Starter Board

module CPUtop(input CCLK, BTN2, 
					input [3:0] SW, 
					output LCDRS, LCDRW, LCDE, 
					output [3:0] LCDDAT, 
					output [7:0] LED
				);
					
wire [3:0] lcdd;
wire rslcd, rwlcd, elcd;
wire pclk,clk,rst;

wire [31:0] c_out;
wire [31:0] ram_addr_in;
wire [31:0] IR_out;
wire [3:0] state_out;

reg [255:0] strdatar = "IR00000000 STAT0AL00000000 ADD00";
wire [255:0] strdata;
reg [3:0] temp=0;

assign LCDDAT[3]=lcdd[3];
assign LCDDAT[2]=lcdd[2];
assign LCDDAT[1]=lcdd[1];
assign LCDDAT[0]=lcdd[0];

assign LCDRS=rslcd;
assign LCDRW=rwlcd;
assign LCDE=elcd;

	display M0 (CCLK, pclk, strdata, rslcd, rwlcd, elcd, lcdd);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	clock M2 (CCLK, 25000, pclk);
	clock M3 (CCLK, 5, clk);
	pbdebounce M1 (pclk, BTN2, rst);
	
	HexToASCii htoa0(ram_addr_in[5:2],strdata[7:0]);
	HexToASCii htoa1(ram_addr_in[9:6],strdata[15:8]);
	
	HexToASCii htoa2(state_out,strdata[135:128]);
	
	genvar i1;
	generate
		for(i1=0;i1<8;i1=i1+1) begin:C_loop
			HexToASCii htoac(c_out[4*i1+3:4*i1],strdata[48+8*i1+7:48+8*i1]);
		end
	endgenerate
	
	genvar i2;
	generate
		for(i2=0;i2<8;i2=i2+1) begin:IR_loop
			HexToASCii htoai(IR_out[4*i2+3:4*i2],strdata[176+8*i2+7:176+8*i2]);
		end
	endgenerate
	
	
	mCPU cpu(.clk(clk),
				.rst(rst),
				.c_out(c_out),
				.IR_out(IR_out),
				.ram_addr_in(ram_addr_in),
				.state_out(state_out)
		);
	always@(posedge clk)begin
		strdatar <= strdata;
	end
endmodule