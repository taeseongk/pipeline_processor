module cache(input clk, rst, wren,
				input [31:0] addr,
				input [63:0] din_mem, 
				input [31:0] din_pipe, 
				input countdone,
				input [2:0] wbsrcm,
				output hit_miss,
				output [31:0] dout);

	`define TAG 31:12		// position of tag in address
	`define INDEX 11:3		// position of index in address
	`define OFFSET 2:0		// position of offset in address

  	parameter NWAYS = 2;
  	parameter NSETS = 512;
  	parameter WIDTH = 32;
  	parameter MWIDTH = 64;  // same as block size
  	parameter INDEX_WIDTH = 9;
  	parameter TAG_WIDTH = 20;
  	parameter OFFSET_WIDTH = 3;

	// WAY 0 cache data
	reg	valid0 [0:NSETS-1];
	reg	dirty0 [0:NSETS-1];
	reg [TAG_WIDTH-1:0] tag0 [0:NSETS-1];
	reg [MWIDTH-1:0] mem0 [0:NSETS-1];
	
	// WAY 1 cache data
	reg	valid1 [0:NSETS-1];
	reg 	dirty1 [0:NSETS-1];
	reg [TAG_WIDTH-1:0] tag1 [0:NSETS-1];
	reg [MWIDTH-1:0] mem1 [0:NSETS-1];

	reg r_hit_miss, r_misslatch;
	reg [31:0] r_dout;
	reg lru [0:NSETS-1];

	integer k;
	initial begin
		for(k = 0; k < NSETS; k = k +1) begin //initialize values
			valid0[k] = 0;
			valid1[k] = 0;
			dirty0[k] = 0;
			dirty1[k] = 0;
			lru[k] = 0;
			tag0[k] = 15'b0;
			tag1[k] = 15'b0;
			mem0[k] = 64'b0;
			mem1[k] = 64'b0;
		end
		r_misslatch = 0;
	end

	always@(posedge clk) begin
		
		if(wbsrcm[0]) begin //if read only, evaluate hit_miss
			r_hit_miss <= ((valid0[addr[`INDEX]] && (tag0[addr[`INDEX]] == addr[`TAG]) && dirty0[addr[`INDEX]] == 0)
					  ||  (valid1[addr[`INDEX]] && (tag1[addr[`INDEX]] == addr[`TAG]) && dirty1[addr[`INDEX]] == 0));
		end

		if(wbsrcm[0]) begin //if read only, read from cache if hit
			if((valid0[addr[`INDEX]] && (tag0[addr[`INDEX]] == addr[`TAG]) && dirty0[addr[`INDEX]] == 0)
					  ||  (valid1[addr[`INDEX]] && (tag1[addr[`INDEX]] == addr[`TAG]) && dirty1[addr[`INDEX]] == 0)) begin
				if(valid0[addr[`INDEX]] && (tag0[addr[`INDEX]] == addr[`TAG])) begin
					if(addr[`OFFSET] == 0) begin //first word
						r_dout <= mem0[addr[`INDEX]][WIDTH-1:0];
					end
					else begin //second word
						r_dout <= mem0[addr[`INDEX]][2*WIDTH-1:WIDTH];
					end
					lru[addr[`INDEX]] <= 1;
				end
				else if(valid1[addr[`INDEX]] && (tag1[addr[`INDEX]] == addr[`TAG])) begin
					if(addr[`OFFSET] == 0) begin
						r_dout <= mem1[addr[`INDEX]][WIDTH-1:0];
					end
					else begin
						r_dout <= mem1[addr[`INDEX]][2*WIDTH-1:WIDTH];
					end
					lru[addr[`INDEX]] <= 0;
				end
			end
			else begin //if miss
				r_misslatch <= 1;
			end
		end
		if(r_misslatch) begin
			if(valid0[addr[`INDEX]] == 0) begin //if empty spot
				if(countdone) begin
					mem0[addr[`INDEX]] <= din_mem;
					valid0[addr[`INDEX]] <= 1;
					tag0[addr[`INDEX]] <= addr[`TAG];
					lru[addr[`INDEX]] <= 1;
					dirty0[addr[`INDEX]] <= 0;
					r_misslatch <= 0;
				end
			end
			else if(valid1[addr[`INDEX]] == 0) begin
				if(countdone) begin
					mem1[addr[`INDEX]] <= din_mem;
					valid1[addr[`INDEX]] <= 1;
					tag1[addr[`INDEX]] <= addr[`TAG];
					lru[addr[`INDEX]] <= 0;
					dirty1[addr[`INDEX]] <= 0;
					r_misslatch <= 0;
				end
			end
			else if(valid0[addr[`INDEX]] && valid1[addr[`INDEX]]) begin
				if(lru[addr[`INDEX]]) begin
					if(countdone) begin
						mem1[addr[`INDEX]] <= din_mem;
						valid1[addr[`INDEX]] <= 1;
						tag1[addr[`INDEX]] <= addr[`TAG];
						lru[addr[`INDEX]] <= 0;
						dirty1[addr[`INDEX]] <= 0;
						r_misslatch <= 0;
					end
				end
				else begin
					if(countdone) begin
						mem0[addr[`INDEX]] <= din_mem;
						valid0[addr[`INDEX]] <= 1;
						tag0[addr[`INDEX]] <= addr[`TAG];
						lru[addr[`INDEX]] <= 1;
						dirty0[addr[`INDEX]] <= 0;
						r_misslatch <= 0;
					end
				end
			end
		end
		if(wren) begin //write 
			if(valid0[addr[`INDEX]] == 0) begin
				valid0[addr[`INDEX]] <= 1;
				tag0[addr[`INDEX]] <= addr[`TAG];
				lru[addr[`INDEX]] <= 1;
				if(addr[`OFFSET] == 0) begin
					mem0[addr[`INDEX]] [31:0]<= din_pipe;
				end
				else begin
					mem0[addr[`INDEX]] [63:32]<= din_pipe;
				end
			end	
			else if(valid1[addr[`INDEX]] == 0) begin
				if(~(addr[`OFFSET] == 0 && mem0[addr[`INDEX]][31:0] == din_pipe) && ~(addr[`OFFSET] == 1 && mem0[addr[`INDEX]][63:32] == din_pipe)) begin
					valid1[addr[`INDEX]] <= 1;
					tag1[addr[`INDEX]] <= addr[`TAG];
					lru[addr[`INDEX]] <= 1;
					if(addr[`OFFSET] == 0) begin
						mem1[addr[`INDEX]] [31:0] <= din_pipe;
					end
					else begin
						mem1[addr[`INDEX]] [63:32] <= din_pipe;
						if(mem0[addr[`INDEX]] [31:0] != 0) begin
							dirty1[addr[`INDEX]] <= 1;
						end 
					end	
				end
				
			end
			else if(valid0[addr[`INDEX]] && (tag0[addr[`INDEX]] == addr[`TAG]) && dirty0[addr[`INDEX]] == 0) begin
				 if((addr[`OFFSET] == 0 && mem0[addr[`INDEX]][31:0] == din_pipe) || (addr[`OFFSET] == 4 && mem0[addr[`INDEX]][63:32] == din_pipe)) begin
					dirty0[addr[`INDEX]] <= 0;
				end 
				else begin
					dirty0[addr[`INDEX]] <= 1;
				end
			end
			else if(valid1[addr[`INDEX]] && (tag1[addr[`INDEX]] == addr[`TAG]) && dirty1[addr[`INDEX]] == 0) begin
				 if((addr[`OFFSET] == 0 && mem1[addr[`INDEX]][31:0] == din_pipe) || (addr[`OFFSET] == 4 && mem1[addr[`INDEX]][63:32] == din_pipe)) begin
					dirty1[addr[`INDEX]] <= 0;
				end 
				else begin
					dirty1[addr[`INDEX]] <= 1;
				end
			end
		end
	end

	assign dout = r_dout;
	assign hit_miss = r_hit_miss;
	
endmodule

