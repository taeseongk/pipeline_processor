//instruction memory module
module instr_mem (input clk, hit_miss, input [31:0] PC_F, output [31:0] Instr_F1, Instr_F0, Instr_F, output countdone);
    reg [63:0] imem [1999:0];
    reg [31:0] instr_f, instr_f1, instr_f0;
    reg r_countdone;
    integer count;
    initial begin
	count = 0;
	r_countdone <= 0;
        $readmemh("memfile.dat",imem);
    end
    always @ (posedge clk) begin
	if (!hit_miss) begin
		count = count + 1;
		r_countdone <= 0;
		if (count == 20) begin
			r_countdone <= 1;
			if (PC_F[2] == 0) begin//if block offset is 0
				instr_f <= imem[PC_F[31:3]][31:0];
			end
			else if (PC_F[2] == 1) begin
				instr_f <= imem[PC_F[31:3]][63:32];
			end
			instr_f1 <= imem[PC_F[31:3]][63:32]; 
			instr_f0 <= imem[PC_F[31:3]][31:0];
			count <= 0;
		end
	end
    end
    assign Instr_F =  instr_f;
    assign Instr_F1 = instr_f1;
    assign Instr_F0 = instr_f0;
    assign countdone = r_countdone;
endmodule


