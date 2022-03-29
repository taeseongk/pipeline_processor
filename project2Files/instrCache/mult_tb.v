module mult_tb();

reg clk, rst, mst, msgn;
reg [31:0] srcA, srcB;
wire [63:0] prod;
wire prodv;

MultSerial mult(clk, rst, mst, msgn, srcA, srcB, prod, prodv);

initial begin
	rst <= 0;
	mst <= 0;
	srcA <= 32'b0;
	srcB <= 32'b0;
end

always begin
	
	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;	

	srcA <= 32'h00FFFFFF;
	srcB <= 32'h80FFFFFF;
	mst <= 1;
	msgn <= 1;

	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;

	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;	

	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;	

	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;	

	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;	

	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;	

	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;	

	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;	

	//rst <= 1;

	clk <= 1; 
	# 20; 
	clk <= 0; 
	# 20;	

end

endmodule
