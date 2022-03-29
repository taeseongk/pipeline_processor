// pipelined MIPS processor
// instantiates a controller and a datapath module

module mips(input clk, reset,
            output  [31:0] pc,
            input   [31:0] instr,
            output  memwritem,
            output  [31:0] aluoutm, writedatam,
            input   [31:0] readdata, input countdone);

	wire multstart, multsgn, branch, jump, regwrite, alusrc, memwrite, zerom, multstarte, prodve; 
	wire [1:0] immop, regdst, ForwardAE, ForwardBE;
	wire [2:0] wbsrc, wbsrce, wbsrcm, alucontrol;
  wire [4:0] WriteRegM, WriteRegE, WriteRegW, rsE, rtE, rsD, rtD, rtM;
  wire StallF, StallD, StallE, FlushE, ForwardAD, ForwardBD;
  wire  RegWriteM, RegWriteE, RegWriteW;
	wire [31:0] instrd;

	controller con(instrd[31:26], instrd[5:0],		
				multstart, multsgn,
				branch, jump,
				regwrite, memwrite,
				alusrc, regdst, immop,
				wbsrc, alucontrol, brOp);
  	hazard haz(rsE, rtE, instrd[25:21], instrd[20:16], rtM, WriteRegE, WriteRegM, WriteRegW, RegWriteE, RegWriteM, RegWriteW, 
  	wbsrce[0], wbsrcm[0], branch, multstart, multstarte, prodve, ForwardAE, ForwardBE, ForwardAD, ForwardBD, StallF, StallD, FlushE, StallE, countdone);

	datapath dp(clk, reset, wbsrc, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol, pc, instr, instrd,
              aluoutm, writedatam, readdata, memwrite, memwritem, branch, immop, multstart, multstarte, multsgn, prodve, brOp,
              StallF, StallD, StallE, FlushE, ForwardAD, ForwardBD, ForwardAE, ForwardBE, rsE, rtE, rtM,
              WriteRegM, WriteRegE, WriteRegW, RegWriteM, RegWriteE, RegWriteW, wbsrce, wbsrcm);

endmodule
