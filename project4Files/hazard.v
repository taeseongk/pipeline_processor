
module hazard(input [4:0] rsE, rsE2, input [4:0] rtE, rtE2,
				input [4:0] rsD, rsD2, input [4:0] rtD, rtD2, input [4:0] rtM,
				input [4:0] WriteRegE, WriteRegM, WriteRegW,
				input [4:0] WriteRegE2, WriteRegM2, WriteRegW2,
				input RegWriteE, RegWriteM, RegWriteW, 
				input RegWriteE2, RegWriteM2, RegWriteW2, 
				input MemtoRegE, MemtoRegM, BranchD, 
				input MultStart, MultStartE, ProdVE,
				output reg [1:0] ForwardAE, ForwardAE2,
				output reg [1:0] ForwardBE, ForwardBE2,
				output reg ForwardAD, ForwardBD,
				output reg StallF, StallD, FlushE, StallE,
				//input [4:0] WriteRegM2, input RegWriteM2, input [4:0] WriteRegW2, input RegWriteW2,
				output reg [1:0] ForwardDiagA, ForwardDiagB, ForwardDiagA2, ForwardDiagB2);

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

		if ((rsE2 != 5'b0) & (rsE2 == WriteRegM2) & RegWriteM2) begin
			ForwardAE2 <= 2'b10;
		end
		else if((rsE2 != 5'b0) & (rsE2 == WriteRegW2) & RegWriteW2) begin
			ForwardAE2 <= 2'b01;
		end
		else begin
			ForwardAE2 <= 2'b00;
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

		if ((rtE2 != 5'b0) & (rtE2 == WriteRegM2) & RegWriteM2) begin
			ForwardBE2 <= 2'b10;
		end
		else if((rtE2 != 5'b0) & (rtE2 == WriteRegW2) & RegWriteW2) begin
			ForwardBE2 <= 2'b01;
		end
		else begin
			ForwardBE2 <= 2'b00;
		end

		if((rsD != 5'b0) & (rsD == WriteRegE2) & RegWriteE2) begin
			ForwardDiagA <= 2'b10;
		end
		else if((rsD != 5'b0) & (rsD == WriteRegM2) & RegWriteM2) begin
			ForwardDiagA <= 2'b01;
		end
		else begin
			ForwardDiagA <= 2'b00;
		end

		if((rtD != 5'b0) & (rtD == WriteRegE2) & RegWriteE2) begin
			ForwardDiagB <= 2'b10;
		end
		else if((rtD != 5'b0) & (rtD == WriteRegM2) & RegWriteM2) begin
			ForwardDiagB <= 2'b01;
		end
		else begin
			ForwardDiagB <= 2'b00;
		end

		if((rsE2 != 5'b0) & (rsE2 == WriteRegM) & RegWriteM) begin
			ForwardDiagA2 <= 2'b10;
		end
		else if((rsE2 != 5'b0) & (rsE2 == WriteRegW) & RegWriteW) begin
			ForwardDiagA2 <= 2'b01;
		end
		else begin
			ForwardDiagA2 <= 2'b00;
		end

		if((rtE2 != 5'b0) & (rtE2 == WriteRegM) & RegWriteM) begin
			ForwardDiagB2 <= 2'b10;
		end
		else if((rtE2 != 5'b0) & (rtE2 == WriteRegW) & RegWriteW) begin
			ForwardDiagB2 <= 2'b01;
		end
		else begin
			ForwardDiagB2 <= 2'b00;
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


