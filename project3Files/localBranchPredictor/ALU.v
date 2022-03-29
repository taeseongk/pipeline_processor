//ALU module
module ALU (input [31:0] inA, inB, input [2:0] ALUControl, output reg [31:0] out);
    wire [31:0] s;
    wire [31:0] BB;
    assign BB = (ALUControl[2]) ? ~inB : inB;
    assign {cout, s} = ALUControl[2] + inA + BB;
    always @ * begin
        case (ALUControl[2:0])
            3'b000: out <= inA & inB;
            3'b001: out <= inA | inB;
            3'b010: out <= s;
            3'b100: out <= inA ^ inB;
            3'b101: out <= inA ^~ inB;
            3'b110: out <= s;
            3'b111: out <= {31'b0, s[31]};
        endcase
	/*if(out == 32'b0) begin
		zero <= 1;
	end
	else begin
		zero <= 0;
	end*/
    end
endmodule

