//data memory module
module data_memory (input clk, reset, MemWrite_M, hit_miss, input [31:0] ALUOut_M, input [31:0] WriteData_M, 
					output [31:0] ReadData_M1, ReadData_M0, ReadData_M, output Count_Done,
					input [2:0] wbsrcm); 
	reg [31:0] readdata;
	reg [31:0] readdata1;
	reg [31:0] readdata0;
	reg  [63:0] RAM[63:0];
	reg r_countdone;
	integer count;
	integer k;
	initial begin
		count = 0;
		r_countdone = 0;
		for(k = 0; k < 64; k = k +1) begin //initialize values
			RAM[k] = 0;
		end
	end
	always @(posedge clk) begin
		if (!reset) begin
			if(r_countdone == 1) begin
					r_countdone <= 0;
				end
			if ((!hit_miss && wbsrcm[0]) || MemWrite_M) begin //think about count
				count = count + 1;
				r_countdone <= 0;
				if (count == 20) begin
					r_countdone <= 1;
					if (!hit_miss) begin //for read miss only
						if (ALUOut_M[2] == 0) begin //if block offset is 0
							readdata <= RAM[ALUOut_M[31:3]][31:0];
						end
						else if (ALUOut_M[2] == 1) begin //if block offset is 1
							readdata <= RAM[ALUOut_M[31:3]][63:32];
						end
						readdata1 <= RAM[ALUOut_M[31:3]][63:32]; 
						readdata0 <= RAM[ALUOut_M[31:3]][31:0];
					end
					if (MemWrite_M) begin //if write
						if (ALUOut_M[2] == 0) begin
							RAM[ALUOut_M[31:3]][31:0] <= WriteData_M;
						end
						else if (ALUOut_M[2] == 1) begin
							RAM[ALUOut_M[31:3]][63:32] <= WriteData_M;
						end
					end
					count = 0;
				end
			end
		end
	end
	assign ReadData_M = readdata;		//32 bit output to mux to pipeline
	assign ReadData_M1 = readdata1;	//2 32 bit outputs to be concatenated when sent to the cache
	assign ReadData_M0 = readdata0;
	assign Count_Done = r_countdone;

endmodule
