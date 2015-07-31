module ADC_DataControl(	input clk_clk, //clock
								input reset_n, //reset signal
								output reg RFS, //ADC control lines
								output reg TFS,
								output reg SCLK,
								output reg [1:0] select_ch, //channel select
								input SPI_IN, //input from ADC
								output reg SPI_OUT, //output to ADC
								output reg signed [10:0] SPI_CH0, //ch data
								output reg signed [10:0] SPI_CH1, 
								output reg signed [10:0] SPI_CH2, 
								output reg signed [10:0] SPI_CH3);
								

/************************************/
//counters

reg [3:0] read_counter; 
reg [3:0] write_counter;

/*************************************/
/*************************************/
//SPI control signals


/**********channel selection*****************/
reg [15:0] output_signal; //output sequence to ADC
always @(select_ch)
begin
	case (select_ch)		
		//code that works for 4ch correctly
		2'b00: output_signal = 16'h6480; //ch0
		2'b01: output_signal = 16'h6680; //ch1
		2'b10: output_signal = 16'h6080; //ch2
		2'b11: output_signal = 16'h6280; //ch3		
	endcase
end

/*************Control lines to ADC**********/
reg [5:0] count; //
always@(posedge clk_clk)
begin
	if (~reset_n) 
	begin
		//ADC does not transfer
		count <= 6'h00;
		RFS <= 1'b0;
		TFS <= 1'b1;
		SCLK <= 1'b0;
		select_ch <= 1'b0;
	end	
	else
	begin
		if (count == 0) 
		begin
			RFS <= 1'b1; 
			TFS <= 1'b0;
			SCLK <=1'b1;
		end
		else if (count == 11) RFS<= 1'b0;
		if (count == 12)
		begin
			SCLK <=0;
			count <=6'h00;
			TFS <= 1'b1;
			RFS <= 1'b0;
			select_ch <= select_ch+1'b1;
		end
		else count<= count+1'b1;
	end
end
/************************************************/
/************************************************/
/***********************************************/


/***********SPI Data******************/
reg [15:0]SPI_IN_signal;

//data input from ADC
always@(posedge clk_clk)
begin
	if (~reset_n)
	begin
		SPI_IN_signal <= 10'h000;
		SPI_CH0 <= 10'h000;
		SPI_CH1 <= 10'h000;
		SPI_CH2 <= 10'h000;
		SPI_CH3 <= 10'h000;
	end
	else 
	begin
		if (RFS&&SCLK)
		begin
			case(read_counter)
				0: SPI_IN_signal[15] <= SPI_IN;
				1: SPI_IN_signal[14] <= SPI_IN;
				2: SPI_IN_signal[13] <= SPI_IN;
				3: SPI_IN_signal[12] <= SPI_IN;
				4: SPI_IN_signal[11] <= SPI_IN;
				5: SPI_IN_signal[10] <= SPI_IN;
				6: SPI_IN_signal[9] <= SPI_IN;
				7: SPI_IN_signal[8] <= SPI_IN;
				8: SPI_IN_signal[7] <= SPI_IN;
				9: SPI_IN_signal[6] <= SPI_IN;
				10: 
				begin
					SPI_IN_signal[5] <= SPI_IN;
					case (select_ch)
						2'b00: SPI_CH0 <= {1'b0,SPI_IN_signal[15:6]};
						2'b01: SPI_CH1 <= {1'b0,SPI_IN_signal[15:6]};
						2'b10: SPI_CH2 <= {1'b0,SPI_IN_signal[15:6]};
						2'b11: SPI_CH3 <= {1'b0,SPI_IN_signal[15:6]};
					endcase
				end
				11: SPI_IN_signal[4] <= SPI_IN;
				12: SPI_IN_signal[3] <= SPI_IN;
				13: SPI_IN_signal[2] <= SPI_IN;
				14: SPI_IN_signal[1] <= SPI_IN;
				15: SPI_IN_signal[0] <= SPI_IN;					
			endcase
			read_counter <= read_counter+1'b1;
		end	
		else read_counter<= 4'b0000;
	end	
end

/***********************************************/
/***********************************************/
/***********************************************/

//data output to ADC
always@(negedge clk_clk)
begin
if (~reset_n)
	begin
		write_counter<= 4'b0000;
	end
	else //'negative edge' of CE_SCLK
	begin
		if (~TFS&&SCLK)
		begin
			case (write_counter)
				0: SPI_OUT <= output_signal[15];
				1: SPI_OUT <= output_signal[14];			
				2: SPI_OUT <= output_signal[13];
				3: SPI_OUT <= output_signal[12];
				4: SPI_OUT <= output_signal[11];			
				5: SPI_OUT <= output_signal[10];
				6: SPI_OUT <= output_signal[9];
				7: SPI_OUT <= output_signal[8];			
				8: SPI_OUT <= output_signal[7];
				9: SPI_OUT <= output_signal[6];
				10: SPI_OUT <= output_signal[5];
				11: SPI_OUT <= output_signal[4];
				12: SPI_OUT <= output_signal[3];
				13: SPI_OUT <= output_signal[2];
				14: SPI_OUT <= output_signal[1];
				15: SPI_OUT <= output_signal[0];
				default: SPI_OUT <= 1'b0;	
			endcase		

			write_counter <= write_counter+1;		
		end
		else write_counter<= 4'b0000;		
	end
end


endmodule

