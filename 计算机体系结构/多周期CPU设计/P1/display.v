module display(input CCLK, reset,input [255:0]strdata, output rslcd, rwlcd, elcd, 
					output [3:0] lcdd);
wire [7:0] lcddatin;
					
lcd M0 (CCLK, resetlcd, clearlcd, homelcd, datalcd, addrlcd,
			lcdreset, lcdclear, lcdhome, lcddata, lcdaddr,
			rslcd, rwlcd, elcd, lcdd, lcddatin, initlcd);
			
genlcd M1 (CCLK, reset, strdata, resetlcd, clearlcd, homelcd, datalcd,
				addrlcd, initlcd, lcdreset, lcdclear, lcdhome,
				lcddata, lcdaddr, lcddatin);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        				
endmodule