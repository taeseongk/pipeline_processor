
module mux21_32(port0, port1, sel, out);
	input wire [31:0] port0, port1;
	input wire sel;
	output reg [31:0] out;

	always @(port0 or port1 or sel)
	begin

	if(sel) 
		out = port1;
	else
		out = port0;
	end
endmodule

module mux21_5(port0, port1, sel, out);
	input wire [4:0] port0, port1;
	input wire sel;
	output reg [4:0] out;

	always @(port0 or port1 or sel)
	begin

	if(sel) 
		out = port1;
	else
		out = port0;
	end
endmodule

module mux21_4(port0, port1, sel, out);
	input wire [3:0] port0, port1;
	input wire sel;
	output reg [3:0] out;

	always @(port0 or port1 or sel)
	begin

	if(sel) 
		out = port1;
	else
		out = port0;
	end
endmodule

module mux41_32(port0, port1, port2, port3, sel, out);
	input wire [31:0] port0, port1, port2, port3;
	input wire [1:0] sel;
	output reg [31:0] out;

	always @(port0 or port1 or port2 or port3 or sel)
	begin

	if(sel == 2'b00) 
		out = port0;
	else if(sel == 2'b01)
		out = port1;
	else if(sel == 2'b10)
		out = port2;
	else	
		out = port3;
	end
endmodule

module mux51_32(port0, port1, port2, port3, port4, sel, out);
	input wire [31:0] port0, port1, port2, port3, port4;
	input wire [2:0] sel;
	output reg [31:0] out;

	always @(port0 or port1 or port2 or port3 or port4 or sel)
	begin

	if(sel == 3'b000) 
		out = port0;
	else if(sel == 3'b001)
		out = port1;
	else if(sel == 3'b010)
		out = port2;
	else	if(sel == 3'b011)
		out = port3;
	else
		out = port4;
	end
endmodule

module mux71_32(port0, port1, port2, port3, port4, port5, port6, sel, out);
	input wire [31:0] port0, port1, port2, port3, port4, port5, port6;
	input wire [2:0] sel;
	output reg [31:0] out;

	always @(port0 or port1 or port2 or port3 or port4 or port5 or port6 or sel)
	begin

	if(sel == 3'b000) 
		out = port0;
	else if(sel == 3'b001)
		out = port1;
	else if(sel == 3'b010)
		out = port2;
	else	if(sel == 3'b011)
		out = port3;
	else if(sel == 3'b100)
		out = port4;
	else if(sel == 3'b101)
		out = port5;
	else
		out = port6;
	end
endmodule

module mux31_32(port0, port1, port2, sel, out);
	input wire [31:0] port0, port1, port2;
	input wire [1:0] sel;
	output reg [31:0] out;

	always @(port0 or port1 or port2 or sel)
	begin

	if(sel == 2'b00) 
		out = port0;
	else if(sel == 2'b01)
		out = port1;
	else
		out = port2;
	end
endmodule

module mux31_5(port0, port1, port2, sel, out);
	input wire [4:0] port0, port1, port2;
	input wire [1:0] sel;
	output reg [4:0] out;

	always @(port0 or port1 or port2 or sel)
	begin

	if(sel == 2'b00) 
		out = port0;
	else if(sel == 2'b01)
		out = port1;
	else
		out = port2;
	end
endmodule

module sign_ext (unextend, extended);
	input  [15:0] unextend;
	output [31:0] extended;
	assign extended = {{16{unextend[15]}}, unextend};
endmodule

module register #(parameter WIDTH = 8)
              (input clk, reset, enable,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  	always @(posedge clk, posedge reset)
    		if (reset) q <= 0;
    		else       q <= d;
endmodule

module reg_en #(parameter WIDTH = 8)
              (input clk, reset, clear, enable,
               input [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk, posedge reset, posedge enable)
	if(enable) begin
		if (reset | clear) 
			q <= 0;
		else 
			q <= d;
	end
endmodule


module shifter32(input [31:0] toshift, output [31:0] shifted);
	assign shifted = toshift << 2;
endmodule

module shifter28(input [25:0] toshift, output [27:0] shifted);
	assign shifted = toshift << 2;
endmodule

module adder(inputA, inputB, result);
	parameter N = 32;
	input [N-1:0] inputA, inputB;
	output [N-1:0] result;
  	wire [N-1:0] carry;
   	genvar i;
   	generate 
   		for(i = 0; i < N; i = i+1)
     			begin
   			if(i == 0) 
  			half_adder f(inputA[0], inputB[0], result[0], carry[0]);
  			else
  			full_adder f(inputA[i], inputB[i], carry[i-1], result[i], carry[i]);
     			end
   	endgenerate
endmodule 

module half_adder(inA, inB, sum, carry);
	input inA, inB;
	output sum, carry;
	assign sum = inA ^ inB;
	assign carry = inA & inB;
endmodule 

module full_adder(inA, inB, c_in, sum, c_out);
	input inA, inB, c_in;
   	output sum, c_out;
 	assign sum = (inA ^ inB) ^ c_in;
	assign c_out = (inB & c_in) | (inA & inB) | (inA & c_in);
endmodule

module AND_2 (input A, B, output Y);
	assign Y = A & B;
endmodule

module zero_ext (unextend, extended);
	input  [15:0] unextend;
	output [31:0] extended;
	assign extended = {16'b0, unextend};
endmodule

module zero_pad (unextend, extended);
	input  [15:0] unextend;
	output [31:0] extended;
	assign extended = {unextend, 16'b0};
endmodule

module br_comp (srcA_D, srcB_D, opcode_D, equal_D);
	input [31:0] srcA_D;
	input [31:0] srcB_D;
	input opcode_D; //0: beq  1: bne
	output reg equal_D;
	always @(srcA_D or srcB_D or opcode_D) begin
		if (!opcode_D)
			equal_D = (srcA_D == srcB_D) ? 1 : 0;
		else 
			equal_D = (srcA_D != srcB_D) ? 1 : 0;
	end
endmodule

module NOT (A, B);
	input A;
	output B;
	assign B = ~A;
endmodule