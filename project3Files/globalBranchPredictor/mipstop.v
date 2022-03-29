// Top level system including MIPS and memories

module top(input clk, reset);

  wire [31:0] pc, instr, readdata;
  wire [31:0] writedata, dataadr;
  wire        memwrite;
  
  // processor and memories are instantiated here 
  mips mips(clk, reset, pc, instr, memwrite, dataadr, writedata, readdata);
  instr_mem imem(pc, instr);

  data_memory dmem(clk, reset, memwrite, dataadr, writedata, readdata);

endmodule


