// Top level system including MIPS and memories

module top(input clk, reset);

  wire [31:0] pc, pc2, instr, instr2, readdata, readdata2;
  wire [31:0] writedata, writedata2, dataadr, dataadr2, srcbm, srcbm2b;
  wire        memwrite, memwrite2;
  
  //adder pcadder(pc, 32'b100, pc2);
  // processor and memories are instantiated here 
  mips mips(clk, reset, pc, instr, instr2, memwrite, memwrite2, dataadr, dataadr2, writedata, writedata2, readdata, readdata2, pc2, srcbm, srcbm2b);
  instr_mem imem(pc, pc2, instr, instr2);
  //data_memory dmem(clk, reset, memwrite, memwrite2, dataadr, dataadr2, srcbm, srcbm2b, readdata, readdata2);
  data_memory dmem(clk, reset, memwrite, memwrite2, dataadr, dataadr2, writedata, writedata2, readdata, readdata2);

endmodule



