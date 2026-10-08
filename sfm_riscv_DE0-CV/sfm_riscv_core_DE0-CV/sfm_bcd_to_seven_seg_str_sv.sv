/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//												       BCD to 7-Segment Display Module														        //
//													Created by: Stephen Meyer (10/8/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_bcd_to_seven_seg_str_sv ( input logic [23:0] bcd_string, output logic [41:0] seven_seg_string);

always_comb begin
	case (bcd_string[3:0])
		4'd0 : seven_seg_string[6:0] = 7'b0111111;
		4'd1 : seven_seg_string[6:0] = 7'b0000011;
		4'd2 : seven_seg_string[6:0] = 7'b1011011;
		4'd3 : seven_seg_string[6:0] = 7'b1001111;
		4'd4 : seven_seg_string[6:0] = 7'b1100110;
		4'd5 : seven_seg_string[6:0] = 7'b1011011;
		4'd6 : seven_seg_string[6:0] = 7'b1111101;
		4'd7 : seven_seg_string[6:0] = 7'b0000111;
		4'd8 : seven_seg_string[6:0] = 7'b1111111;
		4'd9 : seven_seg_string[6:0] = 7'b1100111;
		default : seven_seg_string[6:0] = 7'b0000000;
	endcase
	case (bcd_string[7:4])
		4'd0 : seven_seg_string[13:7] = 7'b0111111;
		4'd1 : seven_seg_string[13:7] = 7'b0000011;
		4'd2 : seven_seg_string[13:7] = 7'b1011011;
		4'd3 : seven_seg_string[13:7] = 7'b1001111;
		4'd4 : seven_seg_string[13:7] = 7'b1100110;
		4'd5 : seven_seg_string[13:7] = 7'b1011011;
		4'd6 : seven_seg_string[13:7] = 7'b1111101;
		4'd7 : seven_seg_string[13:7] = 7'b0000111;
		4'd8 : seven_seg_string[13:7] = 7'b1111111;
		4'd9 : seven_seg_string[13:7] = 7'b1100111;
		default : seven_seg_string[13:7] = 7'b0000000;
	endcase
	case (bcd_string[11:8])
		4'd0 : seven_seg_string[20:14] = 7'b0111111;
		4'd1 : seven_seg_string[20:14] = 7'b0000011;
		4'd2 : seven_seg_string[20:14] = 7'b1011011;
		4'd3 : seven_seg_string[20:14] = 7'b1001111;
		4'd4 : seven_seg_string[20:14] = 7'b1100110;
		4'd5 : seven_seg_string[20:14] = 7'b1011011;
		4'd6 : seven_seg_string[20:14] = 7'b1111101;
		4'd7 : seven_seg_string[20:14] = 7'b0000111;
		4'd8 : seven_seg_string[20:14] = 7'b1111111;
		4'd9 : seven_seg_string[20:14] = 7'b1100111;
		default : seven_seg_string[20:14] = 7'b0000000;
	endcase
	case (bcd_string[15:12])
		4'd0 : seven_seg_string[27:21] = 7'b0111111;
		4'd1 : seven_seg_string[27:21] = 7'b0000011;
		4'd2 : seven_seg_string[27:21] = 7'b1011011;
		4'd3 : seven_seg_string[27:21] = 7'b1001111;
		4'd4 : seven_seg_string[27:21] = 7'b1100110;
		4'd5 : seven_seg_string[27:21] = 7'b1011011;
		4'd6 : seven_seg_string[27:21] = 7'b1111101;
		4'd7 : seven_seg_string[27:21] = 7'b0000111;
		4'd8 : seven_seg_string[27:21] = 7'b1111111;
		4'd9 : seven_seg_string[27:21] = 7'b1100111;
		default : seven_seg_string[27:21] = 7'b0000000;
	endcase
	case (bcd_string[19:16])
		4'd0 : seven_seg_string[34:28] = 7'b0111111;
		4'd1 : seven_seg_string[34:28] = 7'b0000011;
		4'd2 : seven_seg_string[34:28] = 7'b1011011;
		4'd3 : seven_seg_string[34:28] = 7'b1001111;
		4'd4 : seven_seg_string[34:28] = 7'b1100110;
		4'd5 : seven_seg_string[34:28] = 7'b1011011;
		4'd6 : seven_seg_string[34:28] = 7'b1111101;
		4'd7 : seven_seg_string[34:28] = 7'b0000111;
		4'd8 : seven_seg_string[34:28] = 7'b1111111;
		4'd9 : seven_seg_string[34:28] = 7'b1100111;
		default : seven_seg_string[34:28] = 7'b0000000;
	endcase
	case (bcd_string[23:20])
		4'd0 : seven_seg_string[41:35] = 7'b0111111;
		4'd1 : seven_seg_string[41:35] = 7'b0000011;
		4'd2 : seven_seg_string[41:35] = 7'b1011011;
		4'd3 : seven_seg_string[41:35] = 7'b1001111;
		4'd4 : seven_seg_string[41:35] = 7'b1100110;
		4'd5 : seven_seg_string[41:35] = 7'b1011011;
		4'd6 : seven_seg_string[41:35] = 7'b1111101;
		4'd7 : seven_seg_string[41:35] = 7'b0000111;
		4'd8 : seven_seg_string[41:35] = 7'b1111111;
		4'd9 : seven_seg_string[41:35] = 7'b1100111;
		default : seven_seg_string[41:35] = 7'b0000000;
	endcase
end

endmodule
