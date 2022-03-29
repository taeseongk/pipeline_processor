//data memory module
module data_memory (input clk, reset, MemWrite_M, MemWrite_M2, input [31:0] ALUOut_M, ALUOut_M2, WriteData_M, WriteData_M2, output [31:0] ReadData_M, ReadData_M2);
    /*reg [31:0] mem [63:0];
    initial begin
        $readmemh("memfile.dat",mem);
    end
    assign ReadData_M = mem[ALUOut_M[31:2]]; //word aligned
    always @ (posedge clk) begin
        if (MemWrite_M && !reset)
            mem[ALUOut_M[31:2]] <= WriteData_M;
    end*/
//module dmem(input clk, we,
            //input   [31:0] a, wd,
            //output  [31:0] rd);

	reg  [31:0] RAM[63:0];
  	assign ReadData_M = RAM[ALUOut_M[31:2]]; 		// word aligned
	assign ReadData_M2 = RAM[ALUOut_M2[31:2]];
  	always @(posedge clk) begin
    		if (MemWrite_M && !reset)
      			RAM[ALUOut_M[31:2]] <= WriteData_M;
		if (MemWrite_M2 && !reset)
			RAM[ALUOut_M2[31:2]] <= WriteData_M2;
	end


endmodule
