module datapath(input          clk, reset,
                input [1:0]      wbsrc,
                input     pcsrc,
                input          alusrc,
                input  regdst,
                input          regwrite, jump,
                input   [2:0]  alucontrol,
                output  [31:0] pc,
                input   [31:0] instr, output [31:0] instrd,
                input   [31:0] instr2, output [31:0] instrd2,
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
                input [1:0] ForwardAE, ForwardBE, ForwardAE2, ForwardBE2,
                output [4:0] rse, rte, rtm, rse2, rte2,
                output [4:0] writeregm, writerege, writeregw,
                output regwritem, regwritee, regwritew,
                output [1:0] wbsrce, wbsrcm,
		output [31:0] srcbm, srcbm2b,
                
                output [4:0] writerege2, output [4:0] writeregw2, output regwritee2, regwritew2, output [1:0] wbsrce2, output multstarte2, output prodv2,
                output regwritem2, output [1:0] wbsrcm2, output memwritem2, output [31:0] writedatam2, output [4:0] writeregm2, rtm2, 
		output [31:0] aluoutm2,
                input branch2, brOp2, regwrite2, input [1:0] wbsrc2, input memwrite2, input [2:0] alucontrol2, input alusrc2, input regdst2,
                input [1:0] immop2, input multstart2, input multsgn2, input [31:0] readdata2,
		output [31:0] pcplus4f,

		input [1:0] ForwardDiagA, ForwardDiagB, ForwardDiagA2, ForwardDiagB2);
             
    wire memwritee, branche, branchm,
        alusrce, pcsrcd, multsgne, equalD, notstalld, notstallf, notstalle, regdste;
    wire [1:0] immope, wbsrcw;
    wire [2:0] alucontrole;
    wire [27:0] jshifted, jshifted2;
    wire [4:0]  rde, rsd, rtd;
    wire [31:0] pcprime, pcprime2, pcprime3, pcnextbr, pcplus4d, pcplus4e, pcplus4m, pcplus4w, pcbranchd, signimmd, signimme, shifted,
            srcad, srcbd, srcae, srcbe, aluoute, aluoutw, readdataw, writedatae, zeroimmd, zeroimme, zeropadd, zeropade, resultw, afterimmmux,
            branchAD, branchBD, srcae2, srcbe2;
    wire [63:0] prode, prodm, prodw;
    
    wire [31:0] signimmd2, shifted2, pcplus4d2, pcbranchd2, zeroimmd2, zeropadd2, srcad2, srcbd2, signimme2, zeroimme2, 
    zeropade2, afterimmmux2, srcaeb, srcae2b, srcbe2b, srcbeb, writedatae2, aluoute2, aluoutw2, readdataw2, pcplus4m2, resultw2, pcplus4e2, 
	pcplus4w2, pcplus8f, pcplus8d;
    wire equalD2, pcsrcd2, memwritee2, branche2, alusrce2, multsgne2, branchm2, regdste2;
    wire [1:0] immope2, wbsrcw2;
    wire [2:0] alucontrole2;
    wire [4:0] rde2;
    wire [63:0] prode2, prodm2, prodw2;

	wire [31:0] srcaec, srcbec, srcae2c, srcbe2c;


    //pc logic
    NOT not1(StallF, notstallf);
	mux21_32 pcsrcmux(pcplus8f, 32'b1, pcsrcd, pcprime);
	mux21_32 jmux2(pcprime, {pcplus8d[31:28], jshifted2}, jump2, pcprime2);
	mux21_32 jmux(pcprime2, {pcplus4d[31:28], jshifted}, jump, pcprime3);
	reg_en #(32) pcreg(clk, reset, 1'b0, notstallf, pcprime3, pc);
	adder pcadder1(pc, 32'b100, pcplus4f);        //adder for pcplus4
 	adder pcadder8(pc, 32'b1000, pcplus8f);        //adder for pcplus8
    //mux21_32 pcbrmux(pcplus4f, pcbranchd, pcsrcd, pcprime);    

    NOT not2(StallD, notstalld);
    
    reg_en #(128) fetchreg(clk, reset, pcsrcd, notstalld, {instr, pcplus4f, instr2, pcplus8f}, {instrd, pcplus4d, instrd2, pcplus8d});

    //register file logic
    regfile rf(clk, reset, regwritew, regwritew2, instrd[25:21], instrd[20:16], instrd2[25:21], instrd2[20:16], writeregw, writeregw2, 
			resultw, resultw2, srcad, srcad2, srcbd, srcbd2);
    sign_ext signext(instrd[15:0], signimmd);
    sign_ext signext2(instrd2[15:0], signimmd2);
    shifter32 immshift(signimmd, shifted);
    shifter32 immshift2(signimmd2, shifted2);
    adder pcadder2(pcplus4d, shifted, pcbranchd);        //adder for pcbranch
    adder pcadder2b(pcplus8d, shifted2, pcbranchd2);        //adder for pcbranch
    zero_ext zext(instrd[15:0], zeroimmd);
    zero_ext zext2(instrd2[15:0], zeroimmd2);
    zero_pad zpad(instrd[15:0], zeropadd);
    zero_pad zpad2(instrd2[15:0], zeropadd2);
    shifter28 sh28(instrd[25:0], jshifted);
    shifter28 sh28b(instrd2[25:0], jshifted2);
    //mux21_32 bmux1(srcad, aluoutm, ForwardAD, branchAD);
    //mux21_32 bmux1b(srcad2, aluoutm2, ForwardAD2, branchAD2);    //ForwardAD2, branchAD2
    //mux21_32 bmux2(srcbd, aluoutm, ForwardBD, branchBD);
    //mux21_32 bmux2b(srcbd2, aluoutm2, ForwardBD2, branchBD2);    //ForwardBD2, branchBD2
    //br_comp brcomp(branchAD, branchBD, brOp, equalD);
    //br_comp brcomp2(branchAD2, branchBD2, brOp2, equalD2);        //branchAD2, branchBD2
	br_comp brcomp(srcad, srcbd, brOp, equalD);
    	br_comp brcomp2(srcad2, srcbd2, brOp2, equalD2); 
    AND_2 brand(branch1, equalD, pcsrcd);
    AND_2 brand2(branch2, equalD2, pcsrcd2);
    NOT not3(StallE, notstalle);

    reg_en #(442) decreg(clk, reset, FlushE, 1'b1, {regwrite, wbsrc, memwrite, branch, alucontrol, alusrc, regdst, immop, srcad, srcbd, 
                            instrd[25:21], instrd[20:16], instrd[15:11], signimmd, pcplus4d, zeroimmd, zeropadd, multstart, multsgn,
                            regwrite2, wbsrc2, memwrite2, branch2, alucontrol2, alusrc2, regdst2, immop2, srcad2, srcbd2, instrd2[25:21], 
                            instrd2[20:16], instrd2[15:11], signimmd2, pcplus4d2, zeroimmd2, zeropadd2, multstart2, multsgn2},
                                {regwritee, wbsrce, memwritee, branche, alucontrole, alusrce, regdste, immope, srcae, srcbe, rse, rte, rde,
                             signimme, pcplus4e, zeroimme, zeropade, multstarte, multsgne, 
                             regwritee2, wbsrce2, memwritee2, branche2, alucontrole2, alusrce2, regdste2, immope2, srcae2, srcbe2, rse2,
                             rte2, rde2, signimme2, pcplus4e2, zeroimme2, zeropade2, multstarte2, multsgne2});
    
    //MultSerial mul(clk, reset, multstarte, multsgne, srcaeb, srcbeb, prode, prodv);
   //MultSerial mul2(clk, reset, multstarte2, multsgne2, srcae2b, srcbe2b, prode2, prodv2);
    //mux31_5 writeregmux(rte, rde, 5'b11111, regdste, writerege);
    //mux31_5 writeregmux2(rte2, rde2, 5'b11111, regdste2, writerege2);
	mux21_5 writeregmux(rte, rde, regdste, writerege);
    	mux21_5 writeregmux2(rte2, rde2, regdste2, writerege2);
    mux31_32 immmux(signimme, zeroimme, zeropade, immope, afterimmmux);
    mux31_32 immmux2(signimme2, zeroimme2, zeropade2, immope2, afterimmmux2);    

    mux31_32 srcamux(srcae, resultw, aluoutm, ForwardAE, srcaeb);
	mux31_32 diagmux1(srcaeb, resultw2, aluoutm2, ForwardDiagA, srcaec);

    mux31_32 srcbmux(srcbe, resultw, aluoutm, ForwardBE, writedatae);
	mux31_32 diagmux2(writedatae, resultw2, aluoutm2, ForwardDiagB, srcbeb);

    mux31_32 srcamux2(srcae2, resultw2, aluoutm2, ForwardAE2, srcae2b);        //ForwardAE2
	mux31_32 diagmux3(srcae2b, resultw, aluoutm, ForwardDiagA2, srcae2c);

    mux31_32 srcbmux2(srcbe2, resultw2, aluoutm2, ForwardBE2, writedatae2);    //ForwardBE2
	mux31_32 diagmux4(writedatae2, resultw, aluoutm, ForwardDiagB2, srcbe2b);

    mux21_32 srcbmux1_2(srcbeb, afterimmmux, alusrce, srcbec);        //mux for srcb
    mux21_32 srcbmux2_2(srcbe2b, afterimmmux2, alusrce2, srcbe2c);        //mux for srcb
	//mux21_32 srcbmux2_1(srcbe, afterimmmux, alusrce, srcbe2);        //mux for srcb
    	//mux21_32 srcbmux2_2(srcbe2b, afterimmmux2, alusrce2, srcbe2c);        //mux for srcb
    //ALU ALU(srcaeb, srcbeb, alucontrole, aluoute);
	ALU ALU(srcaec, srcbec, alucontrole, aluoute);
    ALU ALU2(srcae2c, srcbe2c, alucontrole2, aluoute2);

    
    register #(414) memreg(clk, reset, 1'b1, {regwritee, wbsrce, memwritee, branche, aluoute, writedatae, writerege, pcplus4e, prode, rte, srcbeb,
                                                regwritee2, wbsrce2, memwritee2, branche2, aluoute2, writedatae2, writerege2, pcplus4e2, prode2, rte2, srcbe2b},
                                        {regwritem, wbsrcm, memwritem, branchm, aluoutm, writedatam, writeregm, pcplus4m, prodm, rtm, srcbm,
                                        regwritem2, wbsrcm2, memwritem2, branchm2, aluoutm2, writedatam2, writeregm2, pcplus4m2, prodm2, rtm2, srcbm2b});
    
    register #(336) wbreg(clk, reset, 1'b1, {regwritem, wbsrcm, aluoutm, readdata, writeregm, pcplus4m, prodm,
                                            regwritem2, wbsrcm2, aluoutm2, readdata2, writeregm2, pcplus4m2, prodm2},
                                            {regwritew, wbsrcw, aluoutw, readdataw, writeregw, pcplus4w, prodw,
                                            regwritew2, wbsrcw2, aluoutw2, readdataw2, writeregw2, pcplus4w2, prodw2});

    //mux51_32 resultmux(aluoutw, readdataw, pcplus4m, prodw[63:32], prodw[31:0], wbsrcw, resultw);            //mux for result
    //mux51_32 resultmux2(aluoutw2, readdataw2, pcplus4m2, prodw2[63:32], prodw2[31:0], wbsrcw2, resultw2);            //mux for result
	mux41_32 resultmux(aluoutw, readdataw, prodw[63:32], prodw[31:0], wbsrcw, resultw);
	mux41_32 resultmux2(aluoutw2, readdataw2, prodw2[63:32], prodw2[31:0], wbsrcw2, resultw2);
endmodule




