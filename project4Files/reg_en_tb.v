module reg_en_tb();

	reg clk, rst, clear, enable;
	reg [31:0] d;
	wire [31:0] q;

	reg_en dut(clk, rst, clear, enable, d, q);

	initial begin
		clear <= 0;
		enable <= 1;
		d <= 32'b1;
		rst <= 0;
		clk <= 1;
		#20;
		clk <= 0;
		#20;
		clk <= 1;
		rst <= 1;
		#20;
		clk <= 0;
		#20
		rst <= 0;
		clk <= 1;
	end

	/*always @(*) begin
		rst <= 0;
		clk <= 1;
		#20;
		clk <= 0;
		#20;
		clk <= 1;
		rst <= 1;
		#20;
		clk <= 0;
		#20
		rst <= 0;
		clk <= 1;
	end*/

endmodule
