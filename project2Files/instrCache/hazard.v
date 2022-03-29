
module hazard(input [4:0] rsE, input [4:0] rtE,
				input [4:0] rsD, input [4:0] rtD, input [4:0] rtM,
				input [4:0] WriteRegE, WriteRegM, WriteRegW,
				input RegWriteE, RegWriteM, RegWriteW, 
				input MemtoRegE, MemtoRegM, BranchD, 
				input MultStart, MultStartE, ProdVE,
				output reg [1:0] ForwardAE, 
				output reg [1:0] ForwardBE,
				output reg ForwardAD, ForwardBD,
				output reg StallF, StallD, FlushE, StallE,
				input countdone);

	reg lwstall, branchstall;

	always@(*) begin
		if ((rsE != 5'b0) & (rsE == WriteRegM) & RegWriteM) begin
			ForwardAE <= 2'b10;
		end
		else if((rsE != 5'b0) & (rsE == WriteRegW) & RegWriteW) begin
			ForwardAE <= 2'b01;
		end
		else begin
			ForwardAE <= 2'b00;
		end

		if ((rtE != 5'b0) & (rtE == WriteRegM) & RegWriteM) begin
			ForwardBE <= 2'b10;
		end
		else if((rtE != 5'b0) & (rtE == WriteRegW) & RegWriteW) begin
			ForwardBE <= 2'b01;
		end
		else begin
			ForwardBE <= 2'b00;
		end

		StallE <= (MultStart | MultStartE) & (ProdVE == 1'b0);

		lwstall <= ((rsD == rtE) | (rtD == rtE) | (rsD == rtM) | (rtD == rtM)) & MemtoRegE;
		branchstall <= BranchD & ((RegWriteE & ((WriteRegE == rsD) | (WriteRegE == rtD))) | (MemtoRegM & ((WriteRegM == rsD) | (WriteRegM == rtD))));

		StallF <= lwstall || branchstall;
		StallD <= lwstall || branchstall;
		FlushE <= lwstall || branchstall;	

		ForwardAD <= (rsD != 0) & (rsD == WriteRegM) & RegWriteM;
		ForwardBD <= (rtD != 0) & (rtD == WriteRegM) & RegWriteM;
	end

endmodule

