module datapath(input          clk, reset,
                input [2:0]      wbsrc,
		input	 pcsrc,
                input          alusrc, 
		input [1:0] regdst,
                input          regwrite, jump,
                input   [2:0]  alucontrol,
                output  [31:0] pc,
                input   [31:0] instr, output [31:0] instrd,
                output  [31:0] aluoutm, writedatam,
                input   [31:0] readdata,
		input memwrite, 
		output memwritem,
		input branch, 
		input [1:0] immop,
		input multstart,
		output multstarte,
		input multsgn,
		output prodv,
		input brOp,
		input StallF, StallD, StallE,
		input FlushE,
		input ForwardAD, ForwardBD,
		input [1:0] ForwardAE, ForwardBE,
		output [4:0] rse, rte, rtm,
		output [4:0] writeregm, writerege, writeregw, 
		output regwritem, regwritee, regwritew,
		output [2:0] wbsrce, wbsrcm,
		input [31:0] bta,
		input bpredsel,
		output pcsrcd,
		output [31:0] pcd, 
		output bothtaken,
		input found);
             
	wire memwritee, branche, branchm, 
		alusrce, multsgne, equalD, notstalld, notstallf, notstalle;
	wire [1:0] immope, regdste;
	wire [2:0] alucontrole, wbsrcw;
	wire [27:0] jshifted;
	wire [4:0]  rde, rsd, rtd;
  	wire [31:0] pcprime, pcprime2, pcprime3, pcprime4, pcprime5, pcnextbr, pcplus4f, pcplus4d, pcplus4e, pcplus4m, pcplus4w, pcbranchd, signimmd, signimme, shifted, 
			srcad, srcbd, srcae, srcbe, aluoute, aluoutw, readdataw, writedatae, zeroimmd, zeroimme, zeropadd, zeropade, resultw, afterimmmux,
			branchAD, branchBD, srcae2, srcbe2;
	wire [63:0] prode, prodm, prodw;
	wire bpredseld, notpcsrcd, pc4sel, pcsel, notbothtaken, bpredmuxsel, backtopc4sel, pc4selreal;
	assign rsd = instrd[25:21];
	assign rtd = instrd[20:16];

	//pc logic
	NOT notbothtaken1(bothtaken, notbothtaken);
	mux21_1 bothtakenmux(pcsrcd, notbothtaken, bothtaken, pcsel);
	NOT not1(StallF, notstallf);
  	reg_en #(32) pcreg(clk, reset, 1'b0, notstallf, pcprime5, pc);
  	adder pcadder1(pc, 32'b100, pcplus4f);		//adder for pcplus4
	mux21_32 pcbrmux(pcplus4f, pcbranchd, pcsrcd, pcprime);	

	NOT not2(StallD, notstalld);
	mux21_32 jmux(pcprime, {pcplus4d[31:28], jshifted}, jump, pcprime2);
	mux21_1 takenvsbothtaken(bpredsel, notbothtaken, bothtaken, bpredmuxsel);
	mux21_32 bpredmux(pcprime2, bta, bpredmuxsel, pcprime3);
	mux21_32 takennottakenvsbothtakenmux(pcprime4, pcplus4f, bothtaken, pcprime5);
	AND_2 andbranch(pc4sel, found, pc4selreal);
	mux21_32 backtopc4mux(pcprime3, pcplus4d, pc4selreal, pcprime4);
	reg_en #(97) fetchreg(clk, reset, pcsel, notstalld, {instr, pcplus4f, pc, bpredsel}, {instrd, pcplus4d, pcd, bpredseld});

	//register file logic
  	regfile rf(clk, reset, regwritew, instrd[25:21], instrd[20:16], writeregw, resultw, srcad, srcbd); 
	sign_ext signext(instrd[15:0], signimmd);
	shifter32 immshift(signimmd, shifted);
	adder pcadder2(pcplus4d, shifted, pcbranchd);		//adder for pcbranch
	zero_ext zext(instrd[15:0], zeroimmd);
	zero_pad zpad(instrd[15:0], zeropadd);
	shifter28 sh28(instrd[25:0], jshifted);
	mux21_32 bmux1(srcad, aluoutm, ForwardAD, branchAD);
	mux21_32 bmux2(srcbd, aluoutm, ForwardBD, branchBD);
	br_comp brcomp(branchAD, branchBD, brOp, equalD);
	AND_2 brand(branch, equalD, pcsrcd);
	NOT not3(StallE, notstalle);

	NOT not8(pcsrcd, notpcsrcd);
	AND_2 backtopc4(bpredseld, notpcsrcd, pc4sel);

	AND_2 bothtakenand(bpredseld, pcsrcd, bothtaken);

	reg_en #(223) decreg(clk, reset, FlushE, 1'b1, {regwrite, wbsrc, memwrite, branch, alucontrol, alusrc, regdst, immop, srcad, srcbd, instrd[25:21], instrd[20:16], instrd[15:11], signimmd, pcplus4d, zeroimmd, zeropadd, multstart, multsgn},
								{regwritee, wbsrce, memwritee, branche, alucontrole, alusrce, regdste, immope, srcae, srcbe, rse, rte, rde, signimme, pcplus4e, zeroimme, zeropade, multstarte, multsgne});
	
	MultSerial mul(clk, reset, multstarte, multsgne, srcae2, srcbe2, prode, prodv);
	mux31_5 writeregmux(rte, rde, 5'b11111, regdste, writerege);
	mux31_32 immmux(signimme, zeroimme, zeropade, immope, afterimmmux);
	mux31_32 srcamux(srcae, resultw, aluoutm, ForwardAE, srcae2);
	mux31_32 srcbmux(srcbe, resultw, aluoutm, ForwardBE, writedatae);
	mux21_32 srcbmux1(writedatae, afterimmmux, alusrce, srcbe2);		//mux for srcb
	ALU ALU(srcae2, srcbe2, alucontrole, aluoute); 
	
	register #(176) memreg(clk, reset, 1'b1, {regwritee, wbsrce, memwritee, branche, aluoute, writedatae, writerege, pcplus4e, prode, rte}, 
										{regwritem, wbsrcm, memwritem, branchm, aluoutm, writedatam, writeregm, pcplus4m, prodm, rtm});
	
	register #(169) wbreg(clk, reset, 1'b1, {regwritem, wbsrcm, aluoutm, readdata, writeregm, pcplus4m, prodm},
								{regwritew, wbsrcw, aluoutw, readdataw, writeregw, pcplus4w, prodw});

	mux51_32 resultmux(aluoutw, readdataw, pcplus4m, prodw[63:32], prodw[31:0], wbsrcw, resultw);			//mux for result
endmodule





