module datamemtop(input clk, rst, wren, 
		input [31:0] ALUOut_M, 
		input [31:0] din_pipe, 
		output [31:0] readdata_M);
	
	wire [31:0] readdata1, readdata0, readdata; 
	//wire [31:0] writedata_m32;
	//wire [63:0] writedata_m64;
	//wire [63:0] din_mem;
	wire hit_miss, countdone;
	wire [31:0] dataout;
	//din_mem = {readdata1, readdata0};
	//zero_ext64 zext(writedata_m32, writedata_m64);
	data_cache dcche (clk, rst, wren, ALUOut_M, {readdata1, readdata0} , din_pipe, countdone, hit_miss, dataout);
	data_memory dmem (clk, rst, wren, hit_miss, ALUOut_M, din_pipe, readdata1, readdata0, readdata, countdone);
	
	mux21_32 readdatam(readdata, dataout, hit_miss, readdata_M);
endmodule