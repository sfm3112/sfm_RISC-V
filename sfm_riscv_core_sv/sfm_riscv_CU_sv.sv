/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Data Path RISCV File
	Created by: Stephen Meyer (6/4/2026)

	Copyright (C) 2026 Stephen Meyer

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_CU_sv # (parameter int WIDTH = 32)(input logic clk, rst, input logic [WIDTH-1:0]IW, input logic [2:0] CNZres, output logic [2:0] WBsel,
																	output logic LDrd, LdPC, cntPC, LdIWR, LdMAB, LdMAX, pR_W, dR_W, LdOPDR);

/////////////////////////////////////////////////////////CONSTANTS//////////////////////////////////////////////////////////

//------------------------------------------------------OPCODE TYPES------------------------------------------------------//

localparam logic [6:0] TYPE_R  	=	7'b0110011;
localparam logic [6:0] TYPE_I  	=	7'b0010011;
localparam logic [6:0] TYPE_L  	=	7'b0000011;
localparam logic [6:0] TYPE_JR 	=	7'b1100111;
localparam logic [6:0] TYPE_S  	=	7'b0100011;
localparam logic [6:0] TYPE_B  	=	7'b1100011;
localparam logic [6:0] TYPE_UI	=	7'b0110111;
localparam logic [6:0] TYPE_UPC	=	7'b0010111;
localparam logic [6:0] TYPE_J  	=	7'b1101111;

//-----------------------------------------------------MACHINE CYCLES-----------------------------------------------------//

localparam logic [1:0] MC0 = 2'b00;
localparam logic [1:0] MC1 = 2'b01;
localparam logic [1:0] MC2 = 2'b10;
localparam logic [1:0] RESET = 2'b11;

logic [1:0] MC;
logic [1:0] next_MC;

//-----------------------------------------------------WB_SEL SIGNALS-----------------------------------------------------//

localparam logic [2:0] ALU_RES	= 3'd0;
localparam logic [2:0] LD_WB 		= 3'd1;
localparam logic [2:0] IMM 		= 3'd2;
localparam logic [2:0] IW_SEL 	= 3'd3;
localparam logic [2:0] MAROUT		= 3'd4;
localparam logic [2:0] PCOUT 		= 3'd5;
localparam logic [2:0] INPUT 		= 3'd6;
localparam logic [2:0] NA 			= 3'd7;


///////////////////////////////////////////////////////CONTROL UNIT/////////////////////////////////////////////////////////

//--------------------------------------------------CLOCK EDGE CONTROL----------------------------------------------------//

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        MC <= RESET;
    else
        MC <= next_MC;
end

//-----------------------------------------------COMBINATIONAL LOGIC BLOCKS-----------------------------------------------//

always_comb begin
	case (MC)
//----------------------------------------------------------RESET---------------------------------------------------------//

		RESET : begin
			LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;


//-----------------------------------------------------------MC0----------------------------------------------------------//	
		MC0 : begin
			LdPC = 1'b0; cntPC = 1'b1; LDrd = 1'b0; LdIWR = 1'b1; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC1;
		end
		
//-----------------------------------------------------------MC1----------------------------------------------------------//		
		MC1 : begin
		case (IW[6:0])
			TYPE_R : begin
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b1; LdIWR = 1'b0; WBsel = ALU_RES; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
			end
			
			TYPE_I : begin		//Same as TYPE_R
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b1; LdIWR = 1'b0; WBsel = ALU_RES; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
			end
			
			TYPE_L : begin
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b1; LdMAX = 1'b1; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC2;
			end
			
			TYPE_JR : begin	//Should be same as Type L mc1? If they are, could possibly be combined
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b1; LdMAX = 1'b1; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC2;
			end
			
			TYPE_S : begin		//Appears to be the same as L as well
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b1; LdMAX = 1'b1; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC2;
			end
			
			TYPE_B : begin		//Also same as L
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b1; LdMAX = 1'b1; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC2;
			end
			
			TYPE_UI : begin
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b1; LdIWR = 1'b0; WBsel = IMM; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
			end
			
			TYPE_UPC : begin
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b1; LdMAX = 1'b1; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC2;
			end
			
			TYPE_J : begin		//Same as UPC
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b1; LdMAX = 1'b1; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC2;
			end
			
			default : begin
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
			end
			
		endcase
		end
		
//-----------------------------------------------------------MC2----------------------------------------------------------//	
	
		MC2 : begin
		case (IW[6:0])
			
			TYPE_L : begin
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b1; LdIWR = 1'b0; WBsel = LD_WB; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
			end
			
			TYPE_JR : begin
				LdPC = 1'b1; cntPC = 1'b0; LDrd = 1'b1; LdIWR = 1'b0; WBsel = PCOUT; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
			end
			
			TYPE_S : begin
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b1; LdOPDR = 1'b0; next_MC = MC0;
			end
			
			TYPE_B : begin
				case (IW[14:12])
					3'b000 : begin
						if (CNZres[0]) begin //branch
							LdPC = 1'b1; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end else begin		//dont branch
							LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end
					end
					
					3'b001 : begin
						if (! CNZres[0]) begin	//branch
							LdPC = 1'b1; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end else begin		//dont branch
							LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end
					end
					
					3'b100 : begin
						if (CNZres[1]) begin		//branch
							LdPC = 1'b1; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end else begin		//dont branch
							LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end
					end
					
					3'b101 : begin
						if (! CNZres[1]) begin	//branch
							LdPC = 1'b1; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end else begin			//dont branch
							LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end
					end
					
					3'b110 : begin
						if (! CNZres[2]) begin	//branch
							LdPC = 1'b1; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end else begin		//dont branch
							LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end
					end
					
					3'b111 : begin
						if (CNZres[2]) begin		//branch
							LdPC = 1'b1; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end else begin		//dont branch
							LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
						end
					end
					
					default : begin
						LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
					end
					
				endcase
			end
			
			TYPE_UPC : begin
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b1; LdIWR = 1'b0; WBsel = MAROUT; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
			end
			
			TYPE_J : begin
				LdPC = 1'b1; cntPC = 1'b0; LDrd = 1'b1; LdIWR = 1'b0; WBsel = PCOUT; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;

			end
			
			default : begin
				LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
			end
			
		endcase
		end
		
		default : begin
			LdPC = 1'b0; cntPC = 1'b0; LDrd = 1'b0; LdIWR = 1'b0; WBsel = NA; LdMAB = 1'b0; LdMAX = 1'b0; pR_W = 1'b0; dR_W = 1'b0; LdOPDR = 1'b0; next_MC = MC0;
		end
		
	endcase

end
endmodule



