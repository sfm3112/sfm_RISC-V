/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//												     Binary to 7-Segment Display Module													        //
//													Created by: Stephen Meyer (10/7/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_bin_to_7_seg_disp_sv ( input logic rst_n, clk, input logic [19:0] binary, output logic [3:0] hundreds_thousands, tens_thousands, thousands, hundreds, tens, ones);

logic [23:0] bcd_stage[0:20];

assign bcd_stage[0] = 24'b0;

genvar k;
	generate for (k = 0; k < 20; k = k + 1) 
		begin : gen_bcd_stage
			sfm_bcd_stage_sv stage_inst (.bcd_in(bcd_stage[k]), .bit_in(binary[19-k]), .bcd_out(bcd_stage[k+1]));
		end
	endgenerate

    // Capture the fully converted result.
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			hundreds_thousands <= 4'd0;
			tens_thousands <= 4'd0;
			thousands <= 4'd0;
			hundreds <= 4'd0;
			tens <= 4'd0;
			ones <= 4'd0;
		end else begin
			if (binary <= 20'd999999) begin
				hundreds_thousands <= bcd_stage[20][23:20];
				tens_thousands <= bcd_stage[20][19:16];
				thousands <= bcd_stage[20][15:12];
				hundreds <= bcd_stage[20][11:8];
				tens <= bcd_stage[20][7:4];
				ones <= bcd_stage[20][3:0];
			end else begin
				hundreds_thousands <= 4'd0;
				tens_thousands <= 4'd0;
				thousands <= 4'd0;
				hundreds <= 4'd0;
				tens <= 4'd0;
				ones <= 4'd0;
			end
		end
	end

endmodule

module sfm_bcd_stage_sv (input logic [23:0] bcd_in, input logic bit_in, output logic [23:0] bcd_out);

	logic [23:0] corrected;

	always_comb begin
		corrected = bcd_in;
			//Uses indexed part select ( +: )
			//The i*4 increments by 4 each loop, and the +: selects the next 4 bits
			for (int i = 0; i < 6; i = i + 1) begin
				if (bcd_in[i*4 +: 4] >= 4'd5) begin
					corrected[i*4 +: 4] = bcd_in[i*4 +: 4] + 4'd3;
				end
			end

			bcd_out = {corrected[22:0], bit_in};
	end

endmodule
