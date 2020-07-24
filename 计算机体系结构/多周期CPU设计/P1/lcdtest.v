// Spartan-3E Starter Board
// Liquid Crystal Display Test lcdtest.v

module lcdtest(input CCLK, BTN2, 
					input [3:0] SW, 
					output LCDRS, LCDRW, LCDE, 
					output [3:0] LCDDAT, 
					output [7:0] LED
				);
					
wire [3:0] lcdd;
wire rslcd, rwlcd, elcd;
wire debpb0;
wire [3:0] temp_out;
wire [7:0] htoa_out;

reg [255:0]strdata = "0123456789abcdefHello world!0000";
reg [3:0] temp=0;

assign LCDDAT[3]=lcdd[3];
assign LCDDAT[2]=lcdd[2];
assign LCDDAT[1]=lcdd[1];
assign LCDDAT[0]=lcdd[0];

assign LCDRS=rslcd;
assign LCDRW=rwlcd;
assign LCDE=elcd;

assign LED[0] = SW[0];
assign LED[1] = SW[1];
assign LED[2] = SW[2];
assign LED[3] = SW[3];
assign LED[4] = temp[0];
assign LED[5] = temp[1];
assign LED[6] = temp[2];
assign LED[7] = temp[3];

assign temp_out = temp;

	display M0 (CCLK, debpb0, strdata, rslcd, rwlcd, elcd, lcdd);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	clock M2 (CCLK, 25000, clk);
	pbdebounce M1 (clk, BTN2, debpb0);
	HexToASCii htoa(temp_out,htoa_out);
	
always @(posedge debpb0)
begin
//	if(debpb0 == 1'b1) begin
		temp = temp +1;
		strdata[7:0] <= htoa_out;
//	end
end

endmodule