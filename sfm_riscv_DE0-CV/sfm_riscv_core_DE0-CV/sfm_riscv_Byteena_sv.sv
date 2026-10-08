/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//															Byte Enable RISCV File																		  //
//													Created by: Stephen Meyer (8/10/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_Byteena_sv (input logic [1:0] addr_lsb_in, st_type, output logic [3:0] decode_out);

localparam logic [1:0] B = 'd0;
localparam logic [1:0] H = 'd1;
localparam logic [1:0] W = 'd2;

always_comb begin
case (st_type)
	B : begin
		unique case (addr_lsb_in)
			2'b00 : decode_out = 4'b0001;
			2'b01 : decode_out = 4'b0010;
			2'b10 : decode_out = 4'b0100;
			2'b11 : decode_out = 4'b1000;
			default : decode_out = 4'b0;
		endcase
	end
	H : begin
		unique case (addr_lsb_in)
			2'b00 : decode_out = 4'b0011;
			2'b01 : decode_out = 4'b0000; //Throw Error Misaligned
			2'b10 : decode_out = 4'b1100;
			2'b11 : decode_out = 4'b0000; //Throw Error Misaligned
			default : decode_out = 4'b0;
		endcase
	end
	W : begin
		unique case (addr_lsb_in)
			2'b00 : decode_out = 4'b1111;
			2'b01 : decode_out = 4'b0000; //Throw Error Misaligned
			2'b10 : decode_out = 4'b0000; //Throw Error Misaligned
			2'b11 : decode_out = 4'b0000; //Throw Error Misaligned
			default : decode_out = 4'b0;
		endcase
	end
	default : decode_out = 4'b0;
endcase
end
endmodule
