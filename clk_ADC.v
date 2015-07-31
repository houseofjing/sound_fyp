module clk_ADC(input 		clk_clk, 
					output reg 	SCLK,  //if 0, posedge side of CE_SCLK. if 1, negedge side of CE_SCLK
					input			reset_n,
					output 		PE_SCLK,  //if 0, posedge side of CE_SCLK. if 1, negedge side of CE_SCLK
					output 		NE_SCLK);
reg  [7:0] CEcount;	
reg  [7:0] CEcount2; //proper clock enable signals							
wire CE_SCLK = (CEcount==8'd11); //2.083 MHz clock

//proper clock enable code
assign PE_SCLK = (CEcount2 == 8'd23); 
assign NE_SCLK = ~(CEcount2 == 8'd11);

//lowest CEcount possible is ==2'd3 which is a clock of (?) 6.25MHz
always @(posedge clk_clk)
begin
	if (~reset_n)
	begin
		CEcount <= 8'h00;
		SCLK<=1'b0;
	end
	else
	begin
		if (CE_SCLK) 
		begin
			SCLK <= SCLK+1'b1;
			CEcount <= 8'h00;
		end
		else begin
			CEcount<=CEcount+1'b1;
		end
	end	
end

always @(posedge clk_clk)
begin
	if (~reset_n) CEcount2 <= 8'h00;
	else
	begin
		if (CEcount2==8'd23) CEcount2 <= 8'd0;
		else CEcount2 <= CEcount2+1;
	end	
end



endmodule
