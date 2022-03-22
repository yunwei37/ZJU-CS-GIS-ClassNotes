`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:09:54 04/17/2020 
// Design Name: 
// Module Name:    div32 
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
module div_rill
(
input clk,
input rst,
input en,
input[47:0] a, 
input[47:0] b,
output [47:0] yshang,
output [47:0] yyushu,
output reg calc_done
);
reg[47:0] tempb;
reg[95:0] temp_a;
reg[95:0] temp_b;
reg [7:0] counter;

assign yshang = temp_a[47:0];
assign yyushu = temp_a[95:48];


always @(posedge clk or posedge rst)
begin
	if(rst)
		begin
			temp_a <= 96'h0;
			temp_b <= 96'h0;	
			calc_done <= 1'b1;
			counter <= 0;
		end
	else
		begin
			if(en) begin
				 tempb <= b;
				 counter <= 0;
				 calc_done <= 1'b0;
				 temp_a <= {48'h0,a};
				 temp_b <= {b,48'h0}; 
			end
			if(calc_done == 1'b0) begin
				if(counter <= 47)
					begin
						//temp_a <= {temp_a[62:0],1'b0};
						if(temp_a[95:48] >= tempb)
							begin
								temp_a <= (temp_a - temp_b + 1'b1) << 1;
							end
						else
							begin
								temp_a <= temp_a << 1;
							end
						counter <= counter + 1;
						calc_done <= 1'b0;
					end
				else
					begin
						if( yyushu >= tempb ) begin
							temp_a[47:0] <= temp_a[47:0] + 1;
							temp_a[95:48] <= temp_a[95:48] - tempb;
						end
					
						counter <= 0;
						calc_done <= 1'b1;
					end
			end
		end
end
endmodule
