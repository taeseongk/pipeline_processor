
module global_pred(input clk, input [31:0] pcf, input [31:0] pcd, input pcsrcd, input [31:0] instrf, input [31:0] instrd, 
			output [31:0] bta, output bpredsel, output found);
	//`define TAG 31:9
	//`define INDEX 8:2

	parameter entries = 64;
	parameter snt = 0;	//strongly not taken
	parameter wnt = 1;	//weak not taken
	parameter wt = 2;		//weak taken
	parameter st = 3;	


	reg [2:0] CurrentState;
	reg [2:0] NextState;

	parameter Find = 0;
	parameter Outcome = 1;

	reg [1:0] fsm [0:entries-1]; //fsm of global branch predictor
	reg [1:0] tag_table[0:entries-1]; //tag check table
	reg [31:0] pc_branch [0:entries-1]; //pc branch table

	reg valid [0:entries-1]; //valid bits

	reg [31:0] r_bta;
	reg r_muxsel;
	reg r_found;

	reg [3:0] BHR;
	reg [5:0] index;

	integer k;
	integer i;
	integer statecount;

	initial begin
		//initialize 
		for (k = 0; k < entries; k = k + 1) begin
			//tag_table[i] = 0;
			fsm[k] = snt;
			pc_branch[k] = 0;
			valid[k] = 0;
		end
		r_bta = 0;
		r_muxsel = 0;
		r_found = 0;
		index = 0;
		i = 0;
		BHR = 0;
		statecount = 0;
		assign NextState = Find;
		assign CurrentState = Find;
	end

	always@(posedge clk, negedge clk) begin
		assign CurrentState = NextState;
		case (CurrentState)
			Find: begin
				statecount = 0;
				if(instrf[31:26] == 6'b000100 || instrf[31:26] == 6'b000101) begin
					index[5:4] = pcf[1:0];
					index[3:0] = BHR;
					if(tag_table[index] == pcf[1:0] && valid[index] == 1) begin
						if(fsm[index] == snt || fsm[index] == wnt) begin	//predict not taken
							r_muxsel <= 0;
						end
						else begin	//predict taken
							r_bta <= pc_branch[index];
							r_muxsel <= 1;
						end
						r_found <= 1;
					end
					else if(tag_table[index] != pcf[1:0] && valid[index] == 1) begin
						tag_table[index] <= pcf[1:0];
						valid[index] <= 1;
						fsm[index] <= 0;
						pc_branch[index] <= pcf + 4 + instrf[15:0] * 4;
					end
					statecount = statecount + 1;
					assign NextState = Outcome;
				end
				else begin
					assign NextState = Find;
				end
			end

			Outcome: begin
				if(statecount == 3) begin
					if(r_found == 1) begin
						if(pcsrcd == 1) begin
							if(fsm[index] == snt) begin
								fsm[index] <= wnt;
							end
							else if(fsm[index] == wnt) begin
								fsm[index] <= wt;
							end
							else if(fsm[index] == wt) begin
								fsm[index] <= st;
							end
							assign BHR = BHR << 1;
							assign BHR = BHR | 4'b0001;
						end
						else begin
							if(fsm[index] == st) begin
								fsm[index] <= wt;
							end
							else if(fsm[index] == wt) begin
								fsm[index] <= wnt;
							end
							else if(fsm[index] == wnt) begin
								fsm[index] <= snt;
							end
							assign BHR = BHR << 1;
							assign BHR = BHR | 4'b0000;
						end
						r_found <= 0;
					end
					else begin
						tag_table[index] <= pcd[1:0];
						valid[index] <= 1;
						fsm[index] <= 0;
						pc_branch[index] <= pcd + 4 + instrd[15:0] * 4;
					end
					r_muxsel <= 0;
				end
				
				if(statecount == 3) begin
					statecount = 0;
					assign NextState = Find;
				end
				else begin
					statecount = statecount + 1;
					assign NextState = Outcome;
				end
			end
		endcase
	end
		
	assign bta = r_bta;
	assign bpredsel = r_muxsel;
	assign found = r_found;
endmodule
