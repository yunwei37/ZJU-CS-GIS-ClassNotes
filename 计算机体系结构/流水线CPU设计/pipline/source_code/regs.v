`timescale 1ns / 1ps
module  regs(
    input clk,
    input rst,
    input L_S, 
	input [4:0] R_addr_A,
    input [4:0] R_addr_B,
    input [4:0] Wt_addr, 
	input [31:0] Wt_data,
	output reg [31:0]  rdata_A,
    output reg [31:0]  rdata_B
	);

reg [31:0] register [1:31];		// r1 - r31
integer i;

wire clk1;
assign clk1 = ~clk;


always@(posedge clk1 or posedge rst)begin
    if(rst) begin rdata_A <= 32'b0; rdata_B <= 32'b0; end
    else begin 
        rdata_A <= (R_addr_A == 0) ? 0 : register[R_addr_A];
        rdata_B <= (R_addr_B == 0) ? 0 : register[R_addr_B];
    end     
end

//always write at the posedge, read at negedge
always @(*)begin
    if (rst)  
        for (i=1; i<32; i=i+1)  register[i] <= 0; 		// reset
    else if ((Wt_addr != 0) && (L_S == 1)) 
        register[Wt_addr] <= Wt_data;      			// write
    end
endmodule
