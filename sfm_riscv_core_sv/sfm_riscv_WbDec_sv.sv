/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Write Back Decoder RISCV File
	Created by: Stephen Meyer (6/2/2026)

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_WbDec_sv # (parameter int WIDTH)(input logic [4:0]DECsel, input logic LDrd, output logic [WIDTH-1:0]WBout);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

always_comb begin
	if (LDrd) begin
		unique case (DECsel)
			5'd0 : WBout = 32'h0;
			5'd1 : WBout = 32'h2;
			5'd2 : WBout = 32'h4;
			5'd3 : WBout = 32'h8;
			5'd4 : WBout = 32'h10;
			5'd5 : WBout = 32'h20;
			5'd6 : WBout = 32'h40;
			5'd7 : WBout = 32'h80;
			5'd8 : WBout = 32'h100;
			5'd9 : WBout = 32'h200;
			5'd10 : WBout = 32'h400;
			5'd11 : WBout = 32'h800;
			5'd12 : WBout = 32'h1000;
			5'd13 : WBout = 32'h2000;
			5'd14 : WBout = 32'h4000;
			5'd15 : WBout = 32'h8000;
			5'd16 : WBout = 32'h10000;
			5'd17 : WBout = 32'h20000;
			5'd18 : WBout = 32'h40000;
			5'd19 : WBout = 32'h80000;
			5'd20 : WBout = 32'h100000;
			5'd21 : WBout = 32'h200000;
			5'd22 : WBout = 32'h400000;
			5'd23 : WBout = 32'h800000;
			5'd24 : WBout = 32'h1000000;
			5'd25 : WBout = 32'h2000000;
			5'd26 : WBout = 32'h4000000;
			5'd27 : WBout = 32'h8000000;
			5'd28 : WBout = 32'h10000000;
			5'd29 : WBout = 32'h20000000;
			5'd30 : WBout = 32'h40000000;
			5'd31 : WBout = 32'h80000000;
			default : WBout = 32'h0;
		endcase
	end else begin
		WBout = 32'h0;
	end
end

endmodule
