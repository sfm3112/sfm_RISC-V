/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Data Path RISCV File
	Created by: Stephen Meyer (6/4/2026)

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_CU_sv # (parameter int WIDTH = 32)(input logic clk, rst, input logic [WIDTH-1:0]IW,
																	output logic LDrd, LdPC, cntPC, LdIWR, WBsel, LdMAB, LdMAX, LdOPDR);

/////////////////////////////////////////////////////////CONSTANTS//////////////////////////////////////////////////////////

//------------------------------------------------------OPCODE TYPES------------------------------------------------------//

localparam logic [6:0] TYPE_R  	=	7'b0110011;
localparam logic [6:0] TYPE_L  	=	7'b0000011;
localparam logic [6:0] TYPE_JR  	=	7'b1100111;
localparam logic [6:0] TYPE_S  	=	7'b1100011;
localparam logic [6:0] TYPE_B  	=	7'b1100011;
localparam logic [6:0] TYPE_UI	=	7'b0110111;
localparam logic [6:0] TYPE_UPC	=	7'b0010111;
localparam logic [6:0] TYPE_J  	=	7'b1101111;

//-----------------------------------------------------MACHINE CYCLES-----------------------------------------------------//

localparam logic [1:0] MC0 = 2'b00;
localparam logic [1:0] MC1 = 2'b01;
localparam logic [1:0] MC2 = 2'b10;
localparam logic [1:0] MC3 = 2'b11;

///////////////////////////////////////////////////////CONTROL UNIT/////////////////////////////////////////////////////////





