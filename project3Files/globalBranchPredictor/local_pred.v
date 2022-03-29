module local_pred(input clk, input [31:0] pcf, input [31:0] pcd, input pcsrcd, input [31:0] instrf, input [31:0] instrd,
					output [31:0] bta, output bpredsel, output found);

	`define TAG 31:9		// position of tag in address
	`define INDEX 8:2		// position of index in address

	parameter entries = 128;
	parameter snt = 0;	//strongly not taken
	parameter wnt = 1;	//weak not taken
	parameter wt = 2;		//weak taken
	parameter st = 3;		//strongly taken

	reg [21:0] tag_table[0:entries-1];

	reg [1:0] fsm [0:entries-1];
	reg [31:0] pc_branch [0:entries-1];
	reg valid [0:entries-1];
	reg [31:0] r_bta;
	reg r_muxsel;
	reg r_found;

	integer i;
	integer statecount;

	reg [2:0] CurrentState;
	reg [2:0] NextState;

	parameter Find = 0;
	parameter Outcome = 1;

	integer k;
	initial begin
		for(k = 0; k < entries; k = k +1) begin //initialize values
			fsm[k] = 0;
			pc_branch[k] = 0;
			valid[k] = 0;
		end
		r_bta = 0;
		r_muxsel = 0;
		r_found = 0;
		i = 0;
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
					if(tag_table[pcf[`INDEX]] == pcf[`TAG] && valid[pcf[`INDEX]] == 1) begin
						if(fsm[pcf[`INDEX]] == snt || fsm[pcf[`INDEX]] == wnt) begin	//predict not taken
							r_muxsel <= 0;
						end
						else begin	//predict taken
							r_bta <= pc_branch[pcf[`INDEX]];
							r_muxsel <= 1;
						end
						r_found <= 1;
					end
					else if(tag_table[pcf[`INDEX]] != pcf[`TAG] && valid[pcf[`INDEX]] == 1) begin
						tag_table[pcf[`INDEX]] <= pcf[`TAG];
						valid[pcf[`INDEX]] <= 1;
						fsm[pcf[`INDEX]] <= 0;
						pc_branch[pcf[`INDEX]] <= pcf + 4 + instrf[15:0] * 4;
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
							if(fsm[pcd[`INDEX]] == snt) begin
								fsm[pcd[`INDEX]] <= wnt;
							end
							else if(fsm[pcd[`INDEX]] == wnt) begin
								fsm[pcd[`INDEX]] <= wt;
							end
							else if(fsm[pcd[`INDEX]] == wt) begin
								fsm[pcd[`INDEX]] <= st;
							end
						end
						else begin
							if(fsm[pcd[`INDEX]] == st) begin
								fsm[pcd[`INDEX]] <= wt;
							end
							else if(fsm[pcd[`INDEX]] == wt) begin
								fsm[pcd[`INDEX]] <= wnt;
							end
							else if(fsm[pcd[`INDEX]] == wnt) begin
								fsm[pcd[`INDEX]] <= snt;
							end
						end
						r_found <= 0;
					end
					else begin
						tag_table[pcd[`INDEX]] <= pcd[`TAG];
						valid[pcd[`INDEX]] <= 1;
						fsm[pcd[`INDEX]] <= 0;
						pc_branch[pcd[`INDEX]] <= pcd + 4 + instrd[15:0] * 4;
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


