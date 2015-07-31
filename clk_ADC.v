module clk_ADC(input 		clk_clk, 
					output 		PE_SCLK,  //if 0, posedge side of CE_SCLK. if 1, negedge side of CE_SCLK
					output 		NE_SCLK,
					input			reset_n);
					
reg  [7:0] CEcount;	
							
assign PE_SCLK = (CEcount == 8'd0); //2.083 MHz clock
assign NE_SCLK = ~(CEcount == 8'd11);
//lowest CEcount possible is ==2'd3 which is a clock of (?) 6.25MHz
always @(posedge clk_clk)
begin
	if (~reset_n) CEcount <= 8'h00;
	else
	begin
		if (CEcount==8'd23) CEcount <= 8'd0;
		else CEcount <= CEcount+1;
	end	
end




endmodule
