/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Immediate Processor Module RISCV File
	Created by: Stephen Meyer (6/2/2026)
	
	Copyright (C) 2026 Stephen Meyer

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_immPro_sv # (parameter int WIDTH = 32)(input logic [WIDTH-1:0]IW, output logic [WIDTH-1:0]I, S, B, U, J);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

assign I = {{20{IW[31]}}, IW[31:20]};										//I type used in the ALU
assign S = {{20{IW[31]}}, IW[31:25], IW[11:7]};							//S type used in the store offset
assign B = {{19{IW[31]}}, IW[7], IW[30:25], IW[11:8], 1'b0};		//B type used in branch jump offsets
assign U = {IW[31:12], 12'b0};												//U type for upper 20 bits of address or register data 
assign J = {{12{IW[31]}}, IW[19:12], IW[20], IW[30:21], 1'b0};		//J type used for unconditional jump offset

endmodule
