module sloc_top(	input CLOCK_50, 
						inout [35:0] GPIO_1, 
						output [7:0] LEDG, 
						output [17:0] LEDR, 
						input [17:0] SW, 
						output signed [10:0] SPI_CH0, 
						output signed [10:0] SPI_CH1, 
						output signed [10:0] SPI_CH2, 
						output signed [10:0] SPI_CH3,  
						output tempclock,
						output [22:0] fir_out,
						output [18:0] fir_out18);
						
						

assign reset_n = SW[0]; //reset switch
assign LEDG[0] = reset_n;

/***********************/
/******SPI Input/Output Pins*********/
/***********************/
assign SPI_IN		= GPIO_1[2];
assign GPIO_1[4] 	= SPI_OUT;
assign GPIO_1[3] 	= (TFS&&~RFS);
assign GPIO_1[5] 	= PEorNE&&SCLK; //2.270MHz
assign GPIO_1[7] 	= RFS;
assign GPIO_1[9] 	= TFS;

/***********************/
/*******ADC Data Input/Output********/
/***********************/


/***********************/
/***********************/
///*****DTMF Pins*******/
/***********************/


/*
assign GPIO_1[21]= 1;
assign GPIO_1[29]= 1;
assign GPIO_1[33]= 0;
assign GPIO_1[17]= 0;

wire DVL; 
wire DVR;
wire [7:0]dtmfin;
assign DVL = GPIO_1[25];
assign DVR = GPIO_1[26];
assign LEDR[12]=GPIO_1[35];
assign LEDR[11]=GPIO_1[23];
assign LEDR[10]=GPIO_1[31];
assign LEDR[9]=GPIO_1[27];
 
assign LEDR[3]=GPIO_1[24];
assign LEDR[2]=GPIO_1[13];
assign LEDR[1]=GPIO_1[15];
assign LEDR[0]=GPIO_1[19];
*/
/***********************//***********************/
/***********************//***********************/


/*******************************/
/**********test clock speed stuff***********/
/*******************************/
assign GPIO_1[11] = CLOCK_50; //50MHz
assign GPIO_1[13] = tempclock; //40.064kHz

/*******************************/
/*******************************/


/*************modules******************/
//clock module
wire PEorNE;
clk_ADC M1(.clk_clk(CLOCK_50), 
			  .SCLK(PEorNE), 
			  .reset_n(reset_n),
			  .tempclock(tempclock));


/***************************************/
/*******************************/
//adc control signals + data transfer
wire RFS, TFS, SCLK, SPI_OUT;
wire [1:0] select_ch;
wire [5:0] count;
ADC_DataControl A1(	.clk_clk(PEorNE),
							.reset_n(reset_n),
							.RFS(RFS),
							.TFS(TFS),
							.SCLK(SCLK),
							.select_ch(select_ch),
							.SPI_IN(SPI_IN), 
							.SPI_OUT(SPI_OUT), 
							.SPI_CH0(SPI_CH0), 
							.SPI_CH1(SPI_CH1), 
							.SPI_CH2(SPI_CH2), 
							.SPI_CH3(SPI_CH3));

/***************************************/
/***************************************/


wire [1:0] fir_error;
wire fir_valid, fir_ready;

assign fir_out18 = fir_out[18:0];
assign LEDG[7] = fir_ready;
assign LEDG[6] = fir_valid;
assign LEDG[3:2] = fir_error;

wire [10:0] CE_count;
assign CE_fir = (CE_count == 11'd1249);
always @(posedge CLOCK_50) begin
	if (~reset_n) CE_count <= 11'd0;
	else begin
		if (CE_fir)  CE_count <= 11'd0;
		else CE_count <= CE_count+1;
	end
end
//fir filter
fir_mlab F1(	.clk(CLOCK_50),
			.reset_n(reset_n),
			.enable(CE_fir),
			.ast_sink_data(SPI_CH0),
			.ast_sink_valid(1'b1),
			.ast_source_ready(1'b1),
			.ast_sink_error(2'b00),
			.ast_source_data(fir_out), //output
			.ast_sink_ready(fir_ready),  //output
			.ast_source_valid(fir_valid), //output
			.ast_source_error(fir_error)); //output	

	
/***************************************/
/***************************************/
/*****data registers for each ch go here*******/


parameter l=10; //number of bits per value
parameter n=20; //number of values per memory block 

wire [l:0] ch0_reg [0:n-1];
wire [l:0] ch1_reg [0:n-1];

wire [2*l+1:0] ch0_fir [0:n-1];

ch_memory CH0 (.clk_clk(tempclock),
					.reg_input(SPI_CH0),
					.reset_n(reset_n),
					.reg_array(ch0_reg));
						
ch_memory CH1 (.clk_clk(tempclock),
					.reg_input(SPI_CH1),
					.reset_n(reset_n),
					.reg_array(ch1_reg));

					
fir_memory C0 (.clk_clk(tempclock),
					.fir_input(fir_out0),
					.reset_n(reset_n),
					.fir_array(ch0_fir));



///////////
endmodule
	


