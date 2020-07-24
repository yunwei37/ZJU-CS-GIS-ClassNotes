// Basys Board and Spartan-3E Starter Boards
// Push Button Debounce pbdebounce.v

module pbdebounce(input clk, input button, output reg pbreg); 

reg [3:0] pbshift;
	
always@(posedge clk)
	begin
		pbshift=pbshift<<1;
		pbshift[0]=button;
	if (pbshift==0)
		pbreg=0;
	if (pbshift==15)
		pbreg=1;			
	end

endmodule

