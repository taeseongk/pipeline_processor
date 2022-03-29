module MultSerial(input clk, rst, mst, msgn,
               input  [31:0] srcA, srcB, 
               output [63:0] prod,
		output prodv);

reg [31:0] intA, intB, latchA, latchB;
reg [63:0] intprod;
integer i;
reg state, done, sign, start_latch, msgn_latch, negate;

initial begin
	state = 0;
	done = 0;
	start_latch = 0;
	sign = 0;
	msgn_latch = 0;
	negate = 0;
end

always@(posedge rst) begin
	if(rst) begin
		state = 0;
		done = 0;
		intA <= 32'b0;
		intB <= 32'b0;
		intprod <= 64'b0;
		i = 0;
		
	end
end

always@(posedge clk) begin
	if(mst & rst == 0 & start_latch == 0) begin
		start_latch <= 1;
		latchA <= srcA;
		latchB <= srcB;
		msgn_latch <= msgn;
		done <= 0;
	end

	if(start_latch & state == 0 & rst == 0) begin
		intA <= latchA;
		intB <= latchB;
		i = 31;
		state <= 1;
		intprod <= 64'b0;
	end
	if(state == 1 & rst == 0) begin
		if(msgn_latch == 0) begin
			if(intB != 0) begin
				if(intB[0]) begin
					intprod[i-:32] <= intprod[i-:32] + intA;
				end
				intB = intB >> 1;
				i <= i + 1;
			end
			else begin
				done <= 1;
				state <= 0;
				start_latch <= 0;
			end
		end
		else begin
			intB[31] <= 0;
			intA[31] <= 0;
			if(intB[31] == 0 & intA[31] == 0) begin
			if(intB != 0) begin
				if(intB[0]) begin
					intprod[i-:32] <= intprod[i-:32] + intA;
				end
				intB = intB >> 1;
				i <= i + 1;
			end
			else begin
				if((latchA[31] ^ latchB[31]) & negate == 0) begin
					intprod <= ~(intprod) + {63'b0, 1'b1};
					negate <= 1;
				end
				else begin
				done <= 1;
				state <= 0;
				start_latch <= 0;
				intprod <= intprod | {latchA[31] ^ latchB[31], 63'b0};
				negate <= 0;
				end
			end
			end
		end
	end
end

assign prod = intprod;
assign prodv = done;

endmodule

