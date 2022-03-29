
module instrmemtop (input clk, 
		input [31:0] PC_F, 
		output [31:0] Instr_F);
	
	wire [31:0] instr_f1, instr_f0, instr_f; 
	//wire [31:0] writedata_m32;
	//wire [63:0] writedata_m64;
	//wire [63:0] din_mem;
	wire hit_miss, countdone;
	wire [31:0] dataout;
	//din_mem = {readdata1, readdata0};
	//zero_ext64 zext(writedata_m32, writedata_m64);
	instr_cache icche (clk, PC_F, {instr_f1, instr_f0}, countdone, hit_miss, dataout);
	instr_mem imem (clk, hit_miss, PC_F, instr_f1, instr_f0, instr_f, countdone);
	
	mux21_32 instr(instr_f, dataout, hit_miss, Instr_F);
endmodule