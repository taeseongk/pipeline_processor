//instruction memory module
module instr_mem (input [31:0] PC_F, output [31:0] Instr_F);
    reg [31:0] imem [1999:0];
    initial begin
        $readmemh("memfile.dat",imem);
    end
    assign Instr_F = imem[PC_F[31:2]]; //word aligned
endmodule
