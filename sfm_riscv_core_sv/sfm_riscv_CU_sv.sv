/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Data Path RISCV File
	Created by: Stephen Meyer (6/4/2026)

	Copyright (C) 2026 Stephen Meyer

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_CU_sv # (parameter int WIDTH = 32)(input logic clk, rst, input logic [WIDTH-1:0]IW, output logic [1:0] WBsel,
																	output logic LDrd, LdPC, cntPC, LdIWR, LdMAB, LdMAX, LdOPDR);

/////////////////////////////////////////////////////////CONSTANTS//////////////////////////////////////////////////////////

//------------------------------------------------------OPCODE TYPES------------------------------------------------------//

localparam logic [6:0] TYPE_R  	=	7'b0110011;
localparam logic [6:0] TYPE_L  	=	7'b0000011;
localparam logic [6:0] TYPE_JR  	=	7'b1100111;
localparam logic [6:0] TYPE_S  	=	7'b0100011;
localparam logic [6:0] TYPE_B  	=	7'b1100011;
localparam logic [6:0] TYPE_UI	=	7'b0110111;
localparam logic [6:0] TYPE_UPC	=	7'b0010111;
localparam logic [6:0] TYPE_J  	=	7'b1101111;

//-----------------------------------------------------MACHINE CYCLES-----------------------------------------------------//

localparam logic [1:0] MC0 = 2'b00;
localparam logic [1:0] MC1 = 2'b01;
localparam logic [1:0] MC2 = 2'b10;
localparam logic [1:0] MC3 = 2'b11;

logic [1:0] MC;
logic [1:0] next_MC;

///////////////////////////////////////////////////////CONTROL UNIT/////////////////////////////////////////////////////////

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        MC <= MC0;
    else
        MC <= next_MC;
end

always_comb begin
	case (MC)
	
		MC0 : begin
			LdPC = 1'b0; cntPC = 1'b1; LDrd = 1'b0; LdIWR = 1'b1; WBsel = 2'b00; LdMAB = 1'b0; LdMAX = 1'b0; LdOPDR = 1'b0; next_MC = MC1;
		end
		
//		MC1 : begin
			//Experimenting if the "CU decodes IW" cycle is unnecessary
//		end
		
		MC1 : begin
		case (IW[6:0])
			TYPE_R : begin
			
			end
			
			TYPE_L : begin
			
			end
			
			TYPE_JR : begin
			
			end
			
			TYPE_S : begin
			
			end
			
			TYPE_B : begin
			
			end
			
			TYPE_UI : begin
			
			end
			
			TYPE_UPC : begin
			
			end
			
			TYPE_J : begin
			
			end
			
			default : begin
			
			end
			
		endcase
		end
		
		MC2 : begin
		case (IW[6:0])
			TYPE_R : begin
			
			end
			
			TYPE_L : begin
			
			end
			
			TYPE_JR : begin
			
			end
			
			TYPE_S : begin
			
			end
			
			TYPE_B : begin
			
			end
			
			TYPE_UI : begin
			
			end
			
			TYPE_UPC : begin
			
			end
			
			TYPE_J : begin
			
			end
			
			default : begin
			
			end
			
		endcase
		end
		
		default : begin
			
		end
		
	endcase

end
endmodule



