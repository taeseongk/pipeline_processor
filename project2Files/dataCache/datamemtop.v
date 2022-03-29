module datamemtop(input clk, rst, wren, 
		input [31:0] ALUOut_M, 
		input [31:0] din_pipe, 
		input [2:0] wbsrcm,
		output [31:0] readdata_M,
		output countdone);
	
	wire [31:0] readdata1, readdata0, readdata; 
	wire hit_miss;
	wire [31:0] dataout;
	cache cache (clk, rst, wren, ALUOut_M, {readdata1, readdata0} , din_pipe, countdone, wbsrcm, hit_miss, dataout);
	data_memory dmem (clk, rst, wren, hit_miss, ALUOut_M, din_pipe, readdata1, readdata0, readdata, countdone, wbsrcm);
	mux21_32 readdatam(readdata, dataout, hit_miss, readdata_M);
endmodule