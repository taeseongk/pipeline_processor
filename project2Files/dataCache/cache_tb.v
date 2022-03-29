module cache_tb();
	
	reg clk, rst, wren;
	reg [31:0] addr;
	reg [63:0] din_pipe, din_mem;
	wire hit_miss;
	wire [31:0] dout;

	cache dut(clk, rst, wren, addr, din_mem, din_pipe, hit_miss, dout);

	initial begin
		clk <= 0;
		rst <= 0;
		addr <= 0;
		din_pipe <= 0;
		din_mem <= 0;
		wren <= 0;
		#20
		clk <= 1;
		#20;
		clk <= 0;
		addr <= 4;
		#20;
		clk <= 1;
		addr <= 8;
		wren <= 1;
		din_pipe <= 64'h00000000EEEEEEEE;
		#20;
		clk <= 0;
		#20;
		clk <= 1;
		#20;
		clk <= 0;
		#20;
		clk <= 1;
		addr <= 20;
		wren <= 1;
		din_pipe <= 64'h00000000AAAAAAAA;
		#20;
		clk <= 0;
		#20;
		clk <= 1;
		#20;
		clk <= 0;
	end
endmodule
