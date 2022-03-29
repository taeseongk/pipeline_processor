module regfile_tb();

reg clk, rst, we3;
reg  [4:0]  ra1, ra2, wa3;
reg [31:0] wd3;
wire [31:0] rd1, rd2;

regfile rf(clk, we3, rst, ra1, ra2, wa3, wd3, rd1, rd2);

initial
	begin
		rst <= 1;
		# 22; 
		rst <= 0;
	end
	always
	begin
		clk <= 1; 
		# 20; 
		clk <= 0; 
		# 20;
		
		
		we3 <= 1;
		clk <= 1; 
		# 20; 
		wa3 <= 5'b01000;
		wd3 <= 32'h00000006;
		clk <= 0; 
		# 20;
		
		we3 <= 0;
		clk <= 1; 
		# 20; 
		clk <= 0; 
		# 20;

		we3 <= 1;
		clk <= 1; 
		# 20; 
		wa3 <= 5'b01001;
		wd3 <= 32'h00000003;
		clk <= 0; 
		# 20;
		
		we3 <= 0;
		clk <= 1; 
		# 20; 
		clk <= 0; 
		# 20;

		ra1 <= 5'b01000;
		ra2 <= 5'b01001;
		clk <= 1; 
		# 20; 
		clk <= 0; 
		# 20;

		rst <= 1;
		clk <= 1; 
		# 20; 
		clk <= 0; 
		# 20;
		rst <= 0;

		
		clk <= 1; 
		# 20; 
		clk <= 0; 
		# 20;
	end

endmodule