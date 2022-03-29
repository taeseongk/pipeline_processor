// Top level system including MIPS and memories

module top(input clk, reset);

  wire [31:0] pc, instr, readdata;
  wire [31:0] writedata, dataadr;
  wire memwrite;
  wire [2:0] wbsrcm;
  wire countdone;
  
  // processor and memories are instantiated here 
  mips mips(clk, reset, pc, instr, memwrite, dataadr, writedata, readdata, wbsrcm, countdone);
  instr_mem imem(pc, instr);
  datamemtop dmem(clk, reset, memwrite, dataadr, writedata, wbsrcm, readdata, countdone);

endmodule
