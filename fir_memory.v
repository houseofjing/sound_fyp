module fir_memory(input 			  			clk_clk,
						input 		[l-1:0] 		fir_input,
						input				  			reset_n,
						output reg	[2*l+1:0] 	fir_array [0:n-1]);																					
parameter n=20;
parameter l=10;

integer i;
always@(posedge clk_clk) begin
	if (~reset_n) 
	begin
		for (i=0; i<n; i=i+1) fir_array[i] <= 10'h000;
	end
	else
	begin
		for (i=0; i<n-1; i=i+1)
		begin
			fir_array[i+1] <= fir_array[i];
		end
		fir_array[0] <= fir_input;
	end
end

endmodule
