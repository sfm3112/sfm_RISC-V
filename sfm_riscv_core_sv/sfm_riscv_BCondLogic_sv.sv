/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//												  Branch Conditional Logic Unit RISCV File												        //
//													Created by: Stephen Meyer (8/6/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_BCondLogic_sv # (parameter int B_TYPE_WIDTH = 3)
								(input logic condition_in, input logic [B_TYPE_WIDTH-1:0] b_type, output logic b_taken);

////////////////////////////////////////////////////////OPCODE NAMES////////////////////////////////////////////////////////

localparam logic [B_TYPE_WIDTH-1:0] NOT_B = 'd0;
localparam logic [B_TYPE_WIDTH-1:0] BEQ = 'd1;
localparam logic [B_TYPE_WIDTH-1:0] BNE = 'd2;
localparam logic [B_TYPE_WIDTH-1:0] BLT = 'd3;
localparam logic [B_TYPE_WIDTH-1:0] BGE = 'd4;
localparam logic [B_TYPE_WIDTH-1:0] BLTU = 'd5;
localparam logic [B_TYPE_WIDTH-1:0] BGEU = 'd6;

always_comb begin
case (b_type)
	NOT_B : begin
		b_taken = 1'b0;
	end
	BEQ : begin
		b_taken = condition_in ? 1'b1 : 1'b0;
	end
	BNE : begin
		b_taken = condition_in ? 1'b0 : 1'b1;
	end
	BLT : begin
		b_taken = condition_in ? 1'b1 : 1'b0;
	end
	BGE : begin
		b_taken = condition_in ? 1'b0 : 1'b1;
	end
	BLTU : begin
		b_taken = condition_in ? 1'b1 : 1'b0;
	end
	BGEU : begin
		b_taken = condition_in ? 1'b0 : 1'b1;
	end
	default begin
		b_taken = 1'b0;
	end
endcase
end

endmodule
