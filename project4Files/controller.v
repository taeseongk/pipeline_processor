//controller module
module controller(input [5:0] OP, FN, OP2, FN2,
	output MultStart, MultStart2, MultSgn, MultSgn2,
	output Branch, Branch2, Jump, Jump2,
	output Regwrite, Regwrite2, Memwrite, Memwrite2,
	output ALUSrc, ALUSrc2,
	output RegDst, RegDst2,
	output [1:0] ImmOp, ImmOp2,	//added
	output reg [1:0] WBSrc, WBSrc2,
	output reg [2:0] AluControl, AluControl2,
	output reg brOp, brOp2);
	
    reg [7:0] controls, controls2;
    reg [1:0] mult, mult2;
    assign {Regwrite, Memwrite, Branch, Jump, ALUSrc, RegDst, ImmOp} = controls;	
    assign {Regwrite2, Memwrite2, Branch2, Jump2, ALUSrc2, RegDst2, ImmOp2} = controls2;
    assign {MultStart, MultSgn} = mult;
    assign {MultStart2, MultSgn2} = mult2;
    always @(*) begin
	case(OP)
	    6'b000000: begin
		controls <= 8'b10000100;
		case(FN)
		    6'b100000: begin //add
                        WBSrc <= 2'b00;
                        AluControl <= 3'b010;
			mult <= 2'b00;
	            end
		    6'b100101: begin //or
                        WBSrc <= 2'b00;
                        AluControl <= 3'b001;
			mult <= 2'b00;
		    end
	            6'b100100: begin //and
                        WBSrc <= 2'b00;
                        AluControl <= 3'b000;
			mult <= 2'b00;
		    end
		    6'b100010: begin //sub
                        WBSrc <= 2'b00;
                        AluControl <= 3'b110; //sub
			mult <= 2'b00;
		    end
		    6'b101010: begin //slt
                        WBSrc <= 2'b00;
                        AluControl <= 3'b111;
			mult <= 2'b00;
		    end
		    6'b100110: begin //xor
                        WBSrc <= 2'b00;
                        AluControl <= 3'b100;
			mult <= 2'b00;
		    end
		    6'b000101: begin //xnor
                        WBSrc <= 2'b00;
                        AluControl <= 3'b101;
			mult <= 2'b00;
		    end
			6'b011000: begin		//mult (signed)
                        WBSrc <= 2'b00;
			AluControl <= 3'b000;
                        mult <= 2'b11; 
			end
		    	6'b011001: begin		//multu
			WBSrc <= 2'b00;
			AluControl <= 3'b000;
			mult <= 2'b10; 
			end
		    	6'b010010: begin		//mflo
			WBSrc <= 2'b11;
			AluControl <= 3'b000;
			mult <= 2'b00; 
			end
		    	6'b010000: begin 	//mfhi
			WBSrc <= 2'b10;
			AluControl <= 3'b000;
			mult <= 2'b00; 
			end
		    default: begin
			WBSrc <= 2'bxx;
			AluControl <= 3'bxxx;
			mult <= 2'bxx;
		    end
		  
		endcase
            end
            6'b100011: begin //lw
                controls <= 8'b10001000;
                AluControl <= 3'b010;
                WBSrc <= 2'b01;
		mult <= 2'b00; 
            end
	    6'b101011: begin //sw
                controls <= 8'b01001000;
                AluControl <= 3'b010;
                WBSrc <= 2'b01;
		mult <= 2'b00; 
	    end
	    6'b000100: begin //beq
                controls <= 8'b00100000;
                AluControl <= 3'b110;
		brOp <= 0;
		mult <= 2'b00; 
            end
	    6'b001000: begin //addi
                controls <= 8'b10001000;
                AluControl <= 3'b010;
		WBSrc <= 2'b00;
		mult <= 2'b00; 
	    end
	  /*6'b000010: begin	//jal
		controls <= 9'b100101000; 
		AluControl <= 3'b010;
		WBSrc <= 3'b010;
		mult <= 2'b00; 
	    end*/
	    6'b001101: begin //ori
		controls <= 8'b10001001;
                AluControl <= 3'b001;
                WBSrc <= 2'b00;
		mult <= 2'b00; 
	    end
	    6'b000101: begin //bne
                controls <= 9'b001000000;
                AluControl <= 3'b110;
		brOp <= 1;
		mult <= 2'b00; 
	    end
            6'b001100: begin //andi
                controls <= 8'b10001001;
                AluControl <= 3'b000;
                WBSrc <= 2'b00;
		mult <= 2'b00; 
            end
	    6'b001110: begin //xori
                controls <= 9'b100010001;
                AluControl <= 3'b100;
                WBSrc <= 2'b00;
		mult <= 2'b00; 
            end
	    6'b001010: begin //slti
                controls <= 8'b10001000;
                AluControl <= 3'b111;
                WBSrc <= 2'b00; 
		mult <= 2'b00; 
	    end
		6'b001111: begin	//lui
		controls <= 8'b10001010;
                AluControl <= 3'b010;
		WBSrc <= 2'b00;
		mult <= 2'b00; 
		end
	
	    default: begin
            	controls <= 8'b00000000;
		AluControl <= 3'b000;
		WBSrc <= 2'b00;
		mult <= 2'b00; 
	    end
	endcase
	case(OP2)
	    6'b000000: begin
		controls2 <= 8'b10000100;
		case(FN2)
		    6'b100000: begin //add
                        WBSrc2 <= 2'b00;
                        AluControl2 <= 3'b010;
			mult2 <= 2'b00;
	            end
		    6'b100101: begin //or
                        WBSrc2 <= 2'b00;
                        AluControl2 <= 3'b001;
			mult2 <= 2'b00;
		    end
	            6'b100100: begin //and
                        WBSrc2 <= 2'b00;
                        AluControl2 <= 3'b000;
			mult2 <= 2'b00;
		    end
		    6'b100010: begin //sub
                        WBSrc2 <= 2'b00;
                        AluControl2 <= 3'b110; //sub
			mult2 <= 2'b00;
		    end
		    6'b101010: begin //slt
                        WBSrc2 <= 2'b00;
                        AluControl2 <= 3'b111;
			mult2 <= 2'b00;
		    end
		    6'b100110: begin //xor
                        WBSrc2 <= 2'b00;
                        AluControl2 <= 3'b100;
			mult2 <= 2'b00;
		    end
		    6'b000101: begin //xnor
                        WBSrc2 <= 2'b00;
                        AluControl2 <= 3'b101;
			mult2 <= 2'b00;
		    end
			6'b011000: begin		//mult (signed)
                        WBSrc2 <= 2'b00;
			AluControl2 <= 3'b000;
                        mult2 <= 2'b11; 
			end
		    	6'b011001: begin		//multu
			WBSrc2 <= 2'b00;
			AluControl2 <= 3'b000;
			mult2 <= 2'b10; 
			end
		    	6'b010010: begin		//mflo
			WBSrc2 <= 2'b11;
			AluControl2 <= 3'b000;
			mult2 <= 2'b00; 
			end
		    	6'b010000: begin 	//mfhi
			WBSrc2 <= 2'b10;
			AluControl2 <= 3'b000;
			mult2 <= 2'b00; 
			end
		    default: begin
			WBSrc2 <= 2'bxx;
			AluControl2 <= 3'bxxx;
			mult2 <= 2'bxx;
		    end
		  
		endcase
            end
            6'b100011: begin //lw
                controls2 <= 8'b10001000;
                AluControl2 <= 3'b010;
                WBSrc2 <= 2'b01;
		mult2 <= 2'b00; 
            end
	    6'b101011: begin //sw
                controls2 <= 8'b01001000;
                AluControl2 <= 3'b010;
                WBSrc2 <= 2'b01;
		mult2 <= 2'b00; 
	    end
	    6'b000100: begin //beq
                controls2 <= 8'b00100000;
                AluControl2 <= 3'b110;
		brOp2 <= 0;
		mult2 <= 2'b00; 
            end
	    6'b001000: begin //addi
                controls2 <= 8'b10001000;
                AluControl2 <= 3'b010;
		WBSrc2 <= 2'b00;
		mult2 <= 2'b00; 
	    end
	  /*6'b000010: begin	//jal
		controls <= 9'b100101000; 
		AluControl <= 3'b010;
		WBSrc <= 3'b010;
		mult <= 2'b00; 
	    end*/
	    6'b001101: begin //ori
		controls2 <= 8'b10001001;
                AluControl2 <= 3'b001;
                WBSrc2 <= 2'b00;
		mult2 <= 2'b00; 
	    end
	    6'b000101: begin //bne
                controls2 <= 8'b00100000;
                AluControl2 <= 3'b110;
		brOp2 <= 1;
		mult2 <= 2'b00; 
	    end
            6'b001100: begin //andi
                controls2 <= 8'b10001001;
                AluControl2 <= 3'b000;
                WBSrc2 <= 2'b00;
		mult2 <= 2'b00; 
            end
	    6'b001110: begin //xori
                controls2 <= 8'b10001001;
                AluControl2 <= 3'b100;
                WBSrc2 <= 2'b00;
		mult2 <= 2'b00; 
            end
	    6'b001010: begin //slti
                controls2 <= 8'b10001000;
                AluControl2 <= 3'b111;
                WBSrc2 <= 2'b00; 
		mult2 <= 2'b00; 
	    end
		6'b001111: begin	//lui
		controls2 <= 8'b10001010;
                AluControl2 <= 3'b010;
		WBSrc2 <= 2'b00;
		mult2 <= 2'b00; 
		end
	
	    default: begin
            	controls2 <= 8'b00000000;
		AluControl2 <= 3'b000;
		WBSrc2<= 2'b00;
		mult2 <= 2'b00; 
	    end
	endcase
    end
endmodule


