//data memory module
module data_memory (input clk, reset, MemWrite_M, input [31:0] ALUOut_M, [31:0] WriteData_M, output [31:0] ReadData_M);
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
  	always @(posedge clk)
    	if (MemWrite_M && !reset)
      		RAM[ALUOut_M[31:2]] <= WriteData_M;


endmodule

