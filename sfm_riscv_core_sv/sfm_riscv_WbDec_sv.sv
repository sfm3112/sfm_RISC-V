/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//													 	Write Back Decoder RISCV File																     //
//													Created by: Stephen Meyer (6/2/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_WbDec_sv # (parameter int WIDTH = 32)(input logic [4:0]dec_sel, input logic ld_rd, output logic [WIDTH-1:0]wb_dec_out);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

always_comb begin
	if (ld_rd) begin
		unique case (dec_sel)
			5'd0 : wb_dec_out = 32'h0;
			5'd1 : wb_dec_out = 32'h2;
			5'd2 : wb_dec_out = 32'h4;
			5'd3 : wb_dec_out = 32'h8;
			5'd4 : wb_dec_out = 32'h10;
			5'd5 : wb_dec_out = 32'h20;
			5'd6 : wb_dec_out = 32'h40;
			5'd7 : wb_dec_out = 32'h80;
			5'd8 : wb_dec_out = 32'h100;
			5'd9 : wb_dec_out = 32'h200;
			5'd10 : wb_dec_out = 32'h400;
			5'd11 : wb_dec_out = 32'h800;
			5'd12 : wb_dec_out = 32'h1000;
			5'd13 : wb_dec_out = 32'h2000;
			5'd14 : wb_dec_out = 32'h4000;
			5'd15 : wb_dec_out = 32'h8000;
			5'd16 : wb_dec_out = 32'h10000;
			5'd17 : wb_dec_out = 32'h20000;
			5'd18 : wb_dec_out = 32'h40000;
			5'd19 : wb_dec_out = 32'h80000;
			5'd20 : wb_dec_out = 32'h100000;
			5'd21 : wb_dec_out = 32'h200000;
			5'd22 : wb_dec_out = 32'h400000;
			5'd23 : wb_dec_out = 32'h800000;
			5'd24 : wb_dec_out = 32'h1000000;
			5'd25 : wb_dec_out = 32'h2000000;
			5'd26 : wb_dec_out = 32'h4000000;
			5'd27 : wb_dec_out = 32'h8000000;
			5'd28 : wb_dec_out = 32'h10000000;
			5'd29 : wb_dec_out = 32'h20000000;
			5'd30 : wb_dec_out = 32'h40000000;
			5'd31 : wb_dec_out = 32'h80000000;
			default : wb_dec_out = 32'h0;
		endcase
	end else begin
		wb_dec_out = 32'h0;
	end
end

endmodule
