module tb();

	reg clk, reset;

	top dut(clk, reset);

	initial
	begin
		reset <= 1;
		# 22; 
		reset <= 0;
	end
	always
	begin
		clk <= 1; 
		# 20; 
		clk <= 0; 
		# 20;
	end

endmodule
