module regfile(input clk, rst, we3_top, we3_bot,
               input  [4:0]  ra1_top, ra2_top, ra1_bot, ra2_bot, wa3_top, wa3_bot, 
               input  [31:0] wd3_top, wd3_bot, 
               output [31:0] rd1_top, rd1_bot, rd2_top, rd2_bot);

  	reg [31:0] rf [31:0];

	always@(posedge rst) begin
		rf[0] <= 32'h00000000;
		rf[1] <= 32'h00000000;
		rf[2] <= 32'h00000000;
		rf[3] <= 32'h00000000;
		rf[4] <= 32'h00000000;
		rf[5] <= 32'h00000000;
		rf[6] <= 32'h00000000;
		rf[7] <= 32'h00000000;
		rf[8] <= 32'h00000000;						
		rf[9] <= 32'h00000000;						
		rf[10] <= 32'h00000000;
		rf[11] <= 32'h00000000;
		rf[12] <= 32'h00000000;
		rf[13] <= 32'h00000000;
		rf[14] <= 32'h00000000;
		rf[15] <= 32'h00000000;
		rf[16] <= 32'h00000000;
		rf[17] <= 32'h00000000;
		rf[18] <= 32'h00000000;					
		rf[19] <= 32'h00000000;					
		rf[20] <= 32'h00000000;					
		rf[21] <= 32'h00000000;
		rf[22] <= 32'h00000000;					
		rf[23] <= 32'h00000000;
		rf[24] <= 32'h00000000;
		rf[25] <= 32'h00000000;
		rf[26] <= 32'h00000000;
		rf[27] <= 32'h00000000;
		rf[28] <= 32'h00000000;
		rf[29] <= 32'h00000000;
		rf[30] <= 32'h00000000;
		rf[31] <= 32'h00000000;
	end

  	always @(posedge clk) begin
   		if (we3_top & rst == 0) begin
			rf[wa3_top] <= wd3_top;	
		end
		if (we3_bot & rst == 0) begin
			rf[wa3_bot] <= wd3_bot;
		end
	end
  	assign rd1_top = (ra1_top != 0) ? rf[ra1_top] : 0;
  	assign rd2_top = (ra2_top != 0) ? rf[ra2_top] : 0;
	assign rd1_bot = (ra1_bot != 0) ? rf[ra1_bot] : 0;
  	assign rd2_bot = (ra2_bot != 0) ? rf[ra2_bot] : 0;
endmodule