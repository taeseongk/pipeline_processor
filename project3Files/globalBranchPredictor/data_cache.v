
module data_cache(input clk, rst, wren,
				input [31:0] addr,
				input [63:0] din_mem, 
				input [31:0] din_pipe, 
				input countdone,
				output hit_miss,
				output [31:0] dout);

	`define TAG 31:13		// position of tag in address
	`define INDEX 12:3		// position of index in address
	`define OFFSET 2:0		// position of offset in address

	parameter SIZE = 16*1024*8;
  	parameter NWAYS = 2;
  	parameter NSETS = 1024;
  	parameter BLOCK_SIZE = 64;
  	parameter WIDTH = 32;
  	// Memory related paramter, make sure it matches memory module
  	parameter MWIDTH = 64;  // same as block size
  	// More cache related parameters
  	parameter INDEX_WIDTH = 10;
  	parameter TAG_WIDTH = 19;
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

	reg r_hit_miss;
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
			mem0[k] = 64'h0;
			mem1[k] = 64'b0;
		end

		mem0[0] = 64'hFFFFFFFF;
		//tag0[0] = 15'hFFFF;
		valid0[0] = 1;
	end

	always@(posedge clk) begin
		
		if(wren == 0) begin //if read only, evaluate hit_miss
			r_hit_miss <= ((valid0[addr[`INDEX]] && (tag0[addr[`INDEX]] == addr[`TAG]) && dirty0[addr[`INDEX]] == 0)
					  ||  (valid1[addr[`INDEX]] && (tag1[addr[`INDEX]] == addr[`TAG]) && dirty1[addr[`INDEX]] == 0));
		end
		else begin //if read/write, 1 as write-through
			r_hit_miss <= 1;
		end

		
		if(wren == 0) begin //if read only, read from cache if hit
			if((valid0[addr[`INDEX]] && (tag0[addr[`INDEX]] == addr[`TAG]) && dirty0[addr[`INDEX]] == 0)
					  ||  (valid1[addr[`INDEX]] && (tag1[addr[`INDEX]] == addr[`TAG]) && dirty1[addr[`INDEX]] == 0)) begin
				if(valid0[addr[`INDEX]] && (tag0[addr[`INDEX]] == addr[`TAG])) begin
					//r_dout <= (addr[`OFFSET] <= WORD1) ? mem0[addr[`INDEX]][WIDTH-1:0] : mem0[addr[`INDEX]][2*WIDTH-1:WIDTH];
					if(addr[`OFFSET] == 0) begin //first word
						r_dout <= mem0[addr[`INDEX]][WIDTH-1:0];
					end
					else begin //second word
						r_dout <= mem0[addr[`INDEX]][2*WIDTH-1:WIDTH];
					end
					lru[addr[`INDEX]] <= 1;
				end
				else if(valid1[addr[`INDEX]] && (tag1[addr[`INDEX]] == addr[`TAG])) begin
					//r_dout <= (addr[`OFFSET] <= WORD1) ? mem1[addr[`INDEX]][WIDTH-1:0] : mem1[addr[`INDEX]][2*WIDTH-1:WIDTH];
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
				if(valid0[addr[`INDEX]] == 0) begin //if empty spot
					mem0[addr[`INDEX]] <= din_mem;
					if(countdone) begin
						valid0[addr[`INDEX]] <= 1;
						tag0[addr[`INDEX]] <= addr[`TAG];
						lru[addr[`INDEX]] <= 1;
						dirty0[addr[`INDEX]] <= 0;
					end
				end
				else if(valid1[addr[`INDEX]] == 0) begin
					mem1[addr[`INDEX]] <= din_mem;
					if(countdone) begin
						valid1[addr[`INDEX]] <= 1;
						tag1[addr[`INDEX]] <= addr[`TAG];
						lru[addr[`INDEX]] <= 1;
						dirty1[addr[`INDEX]] <= 0;
					end
				end
				else if(valid0[addr[`INDEX]] && valid1[addr[`INDEX]]) begin
					if(lru[addr[`INDEX]]) begin
						mem1[addr[`INDEX]] <= din_mem;
						if(countdone) begin
							valid1[addr[`INDEX]] <= 1;
							tag1[addr[`INDEX]] <= addr[`TAG];
							lru[addr[`INDEX]] <= 1;
							dirty1[addr[`INDEX]] <= 0;
						end
					end
					else begin
						mem0[addr[`INDEX]] <= din_mem;
						if(countdone) begin
							valid0[addr[`INDEX]] <= 1;
							tag0[addr[`INDEX]] <= addr[`TAG];
							lru[addr[`INDEX]] <= 1;
							dirty0[addr[`INDEX]] <= 0;
						end
					end
				end
			end
		end
		else begin //write 
			if(valid0[addr[`INDEX]] == 0 && (tag0[addr[`INDEX]] == addr[`TAG])) begin
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
			else if(valid1[addr[`INDEX]] == 0 && (tag1[addr[`INDEX]] == addr[`TAG])) begin
				valid1[addr[`INDEX]] <= 1;
				tag1[addr[`INDEX]] <= addr[`TAG];
				lru[addr[`INDEX]] <= 1;
				if(addr[`OFFSET] == 0) begin
					mem1[addr[`INDEX]] [31:0] <= din_pipe;	
				end
				else begin
					mem1[addr[`INDEX]] [63:32] <= din_pipe;
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


