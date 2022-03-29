//controller module
module controller(input [5:0] OP, FN,
	output MultStart, MultSgn,
	output Branch, Jump,
	output Regwrite, Memwrite,
	output ALUSrc, 
	output [1:0] RegDst,
	output [1:0] ImmOp,	//added
	output reg [2:0] WBSrc,
	output reg [2:0] AluControl,
	output reg brOp);
	
    reg [8:0] controls;
    reg [1:0] mult;
    assign {Regwrite, Memwrite, Branch, Jump, ALUSrc, RegDst, ImmOp} = controls;	//added
    assign {MultStart, MultSgn} = mult;
    always @(*) begin
	case(OP)
	    6'b000000: begin
		controls <= 9'b100000100;
		case(FN)
		    6'b100000: begin //add
                        WBSrc <= 3'b000;
                        AluControl <= 3'b010;
			mult <= 2'b00;
	            end
		    6'b100101: begin //or
                        WBSrc <= 3'b000;
                        AluControl <= 3'b001;
			mult <= 2'b00;
		    end
	            6'b100100: begin //and
                        WBSrc <= 3'b000;
                        AluControl <= 3'b000;
			mult <= 2'b00;
		    end
		    6'b100010: begin //sub
                        WBSrc <= 3'b000;
                        AluControl <= 3'b110; //sub
			mult <= 2'b00;
		    end
		    6'b101010: begin //slt
                        WBSrc <= 3'b000;
                        AluControl <= 3'b111;
			mult <= 2'b00;
		    end
		    6'b100110: begin //xor
                        WBSrc <= 3'b000;
                        AluControl <= 3'b100;
			mult <= 2'b00;
		    end
		    6'b000101: begin //xnor
                        WBSrc <= 3'b000;
                        AluControl <= 3'b101;
			mult <= 2'b00;
		    end
			6'b011000: begin		//mult (signed)
                        WBSrc <= 3'b000;
			AluControl <= 3'b000;
                        mult <= 2'b11; 
			end
		    	6'b011001: begin		//multu
			WBSrc <= 3'b000;
			AluControl <= 3'b000;
			mult <= 2'b10; 
			end
		    	6'b010010: begin		//mflo
			WBSrc <= 3'b100;
			AluControl <= 3'b000;
			mult <= 2'b00; 
			end
		    	6'b010000: begin 	//mfhi
			WBSrc <= 3'b011;
			AluControl <= 3'b000;
			mult <= 2'b00; 
			end
		    default: begin
			WBSrc <= 3'bxxx;
			AluControl <= 3'bxxx;
			mult <= 2'bxx;
		    end
		  
		endcase
            end
            6'b100011: begin //lw
                controls <= 9'b100010000;
                AluControl <= 3'b010;
                WBSrc <= 3'b001;
		mult <= 2'b00; 
            end
	    6'b101011: begin //sw
                controls <= 9'b010010000;
                AluControl <= 3'b010;
                WBSrc <= 3'b001;
		mult <= 2'b00; 
	    end
	    6'b000100: begin //beq
                controls <= 9'b001000000;
                AluControl <= 3'b110;
		brOp <= 0;
		mult <= 2'b00; 
            end
	    6'b001000: begin //addi
                controls <= 9'b100010000;
                AluControl <= 3'b010;
		WBSrc <= 3'b000;
		mult <= 2'b00; 
	    end
	  6'b000010: begin	//jal
		controls <= 9'b100101000; 
		AluControl <= 3'b010;
		WBSrc <= 3'b010;
		mult <= 2'b00; 
	end
	    6'b001101: begin //ori
		controls <= 9'b100010001;
                AluControl <= 3'b001;
                WBSrc <= 3'b000;
		mult <= 2'b00; 
	    end
	    6'b000101: begin //bne
                controls <= 9'b001000000;
                AluControl <= 3'b110;
		brOp <= 1;
		mult <= 2'b00; 
	    end
            6'b001100: begin //andi
                controls <= 9'b100010001;
                AluControl <= 3'b000;
                WBSrc <= 3'b000;
		mult <= 2'b00; 
            end
	    6'b001110: begin //xori
                controls <= 9'b100010001;
                AluControl <= 3'b100;
                WBSrc <= 3'b000;
		mult <= 2'b00; 
            end
	    6'b001010: begin //slti
                controls <= 9'b100010000;
                AluControl <= 3'b111;
                WBSrc <= 3'b000; 
		mult <= 2'b00; 
	    end
		6'b001111: begin	//lui
		controls <= 9'b100010010;
                AluControl <= 3'b010;
		WBSrc <= 3'b000;
		mult <= 2'b00; 
		end
	
	    default: begin
            	controls <= 9'b000000000;
		AluControl <= 3'b000;
		WBSrc <= 3'b000;
		mult <= 2'b00; 
	    end
	endcase
    end
endmodule

