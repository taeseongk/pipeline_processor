//instruction memory module
module instr_mem (input [31:0] PC_F, PC_F2, output [31:0] Instr_F1, Instr_F2);
    reg [31:0] imem [399:0];
    initial begin
        $readmemh("memfile.dat",imem);
    end
    assign Instr_F1 = imem[PC_F[31:2]]; //word aligned
    assign Instr_F2 = imem[PC_F2[31:2]];
endmodule


