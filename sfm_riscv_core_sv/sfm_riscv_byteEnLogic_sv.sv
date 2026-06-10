/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Byte Enable Logic RISCV File
	Created by: Stephen Meyer (6/10/2026)
	
	Copyright (C) 2026 Stephen Meyer

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_byteEnLogic_sv (input logic [2:0]func3, input logic [1:0]MAR2, output logic [3:0]byteEnable);

	always_comb begin
		case (func3)
			3'b000 : begin
				unique case (MAR2)
					2'b00 : byteEnable = 4'b0001;
					2'b01 : byteEnable = 4'b0010;
					2'b10 : byteEnable = 4'b0100;
					2'b11 : byteEnable = 4'b1000;
					default : byteEnable = 4'b0000;
				endcase
			end
			3'b001 : begin
				unique case (MAR2)
					2'b00 : byteEnable = 4'b0011;
					2'b01 : byteEnable = 4'b0000;
					2'b10 : byteEnable = 4'b1100;
					2'b11 : byteEnable = 4'b0000;
					default : byteEnable = 4'b0000;
				endcase
			end
			3'b010 : byteEnable = 4'b1111;
			default : byteEnable = 4'b0000;
		endcase		
	end

endmodule
