module clk_ADC(input 		clk_clk, 
					output reg 	SCLK,  //if 0, posedge side of CE_SCLK. if 1, negedge side of CE_SCLK
					input			reset_n/*, 
					output reg	tempclock*/); //sampling speed of ADC		
					
reg  [7:0] CEcount;
reg [2:0] four_cycles;	
							
wire CE_SCLK = (CEcount==8'd11); //2.083 MHz clock
//lowest CEcount possible is ==2'd3 which is a clock of (?) 6.25MHz
always @(posedge clk_clk)
begin
	if (~reset_n)
	begin
		CEcount <= 8'h00;
		SCLK<=1'b0;
		four_cycles <= 8'h00;
		//tempclock <= 0;
	end
	else
	begin
		if (CE_SCLK) 
		begin
			SCLK <= SCLK+1'b1;
			four_cycles <= four_cycles+1'b1;
			CEcount <= 8'h00;
			//if (four_cycles == 3'b110) tempclock <= 1;
			//else tempclock <= 0;
		end
		else CEcount<=CEcount+1'b1;
	end	
end




endmodule
