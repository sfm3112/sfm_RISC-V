/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//												 		  Program Counter RISCV File															        //
//													Created by: Stephen Meyer (6/2/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_PC_sv # (parameter int WIDTH = 32)(input logic [WIDTH-1:0]D, input logic ld_pc, rst_n, stall, clk, output logic [WIDTH-1:0]Q);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n) begin	
	if (!rst_n) begin
		Q <= '0;	
	end else if (stall) begin
		Q <= Q;		
	end else if (ld_pc) begin
		Q <= D;
	end else begin
		Q <= Q + 4;											
	end
end

endmodule
