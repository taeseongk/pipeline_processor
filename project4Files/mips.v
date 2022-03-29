// pipelined MIPS processor
// instantiates a controller and a datapath module

module mips(input clk, reset,
            output  [31:0] pc,
            input   [31:0] instr, instr2,
            output  memwritem, memwritem2,
            output  [31:0] aluoutm, aluoutm2, writedatam, writedatam2,
            input   [31:0] readdata, readdata2,
		output [31:0] pcplus4f, srcbm, srcbm2b);

	wire multstart, multstart2, multsgn, multsgn2, branch, branch2, jump, jump2, regwrite, regwrite2, alusrc, alusrc2, 
		memwrite, memwrite2, multstarte, multstarte2, prodve, prodve2, regdst, regdst2; 
	wire [1:0] immop, immop2, ForwardAE, ForwardBE, ForwardAE2, ForwardBE2;
	wire [1:0] wbsrc, wbsrc2, wbsrce, wbsrce2, wbsrcm, wbsrcm2;
	wire [2:0] alucontrol, alucontrol2;
  wire [4:0] WriteRegM, WriteRegM2, WriteRegE, WriteRegE2, WriteRegW, WriteRegW2, rsE, rtE, rsE2, rtE2, rsD, rtD, rtM, rtM2;
  wire StallF, StallD, StallE, FlushE, ForwardAD, ForwardBD;
  wire  RegWriteM, RegWriteM2, RegWriteE, RegWriteE2, RegWriteW, RegWriteW2;
	wire [31:0] instrd, instrd2;
	wire [1:0] ForwardDiagA, ForwardDiagB, ForwardDiagA2, ForwardDiagB2;

	controller con(instrd[31:26], instrd[5:0], instrd2[31:26], instrd2[5:0],	
				multstart, multstart2, multsgn, multsgn2,
				branch, branch2, jump, jump2,
				regwrite, regwrite2, memwrite, memwrite2,
				alusrc, alusrc2, regdst, regdst2, immop, immop2,
				wbsrc, wbsrc2, alucontrol, alucontrol2, brOp, brOp2);

  	hazard haz(rsE, rsE2, rtE, rtE2, instrd[25:21], instrd2[25:21], instrd[20:16], instrd2[20:16], rtM, WriteRegE, WriteRegM, WriteRegW, WriteRegE2, 
	WriteRegM2, WriteRegW2, RegWriteE, RegWriteM, RegWriteW, RegWriteE2, RegWriteM2, RegWriteW2, 
  	wbsrce[0], wbsrcm[0], branch, multstart, multstarte, prodve, ForwardAE, ForwardAE2, ForwardBE, ForwardBE2, ForwardAD, ForwardBD, StallF, StallD, FlushE, StallE,
	ForwardDiagA, ForwardDiagB, ForwardDiagA2, ForwardDiagB2);

	datapath dp(clk, reset, wbsrc, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol, pc, instr, instrd, instr2, instrd2,
              aluoutm, writedatam, readdata, memwrite, memwritem, branch, immop, multstart, multstarte, multsgn, prodve, brOp,
              StallF, StallD, StallE, FlushE, ForwardAD, ForwardBD, ForwardAE, ForwardBE, ForwardAE2, ForwardBE2, rsE, rtE, rtM, rsE2, rtE2,
              WriteRegM, WriteRegE, WriteRegW, RegWriteM, RegWriteE, RegWriteW, wbsrce, wbsrcm, srcbm, srcbm2b,
	      WriteRegE2, WriteRegW2, RegWriteE2, RegWriteW2, wbsrce2, mulstarte2, prodve2,
	      RegWriteM2, wbsrcm2, memwritem2, writedatam2, WriteRegM2, rtM2,
	      aluoutm2,
	      branch2, brOp2, regwrite2, wbsrc2, memwrite2, alucontrol2, alusrc2, regdst2,
              immop2, multstart2, multsgn2, readdata2, pcplus4f, ForwardDiagA, ForwardDiagB, ForwardDiagA2, ForwardDiagB2);

endmodule



