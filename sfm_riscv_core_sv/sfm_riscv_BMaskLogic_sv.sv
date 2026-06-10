/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Bit Mask Logic Module RISCV File
	Created by: Stephen Meyer (6/2/2026)
	Updated: (6/10/2026)
	
	Copyright (C) 2026 Stephen Meyer

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_BMaskLogic_sv # (parameter int WIDTH = 32)(input logic [WIDTH-1:0]DM, input logic [1:0]MAR2, input logic [2:0]Func3, output logic [WIDTH-1:0]LD);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

	always_comb begin
		case (Func3)
			000 : begin //LB
				unique case (MAR2)
					00 : LD = {{24{DM[7]}}, DM[7:0]};
					01 : LD = {{24{DM[15]}}, DM[15:8]};
					10 : LD = {{24{DM[23]}}, DM[23:16]};
					11 : LD = {{24{DM[31]}}, DM[31:24]};
					default : LD = '0;
				endcase
			end
			001 : begin
				unique case (MAR2)
					00 : LD = {{16{DM[15]}}, DM[15:0]};
					01 : LD = '0;
					10 : LD = {{16{DM[31]}}, DM[31:16]};
					11 : LD = '0;
					default : LD = '0;
				endcase
			end
			010 : begin
				LD = DM;
			end
			100 : begin
				unique case (MAR2)
					00 : LD = {24'b0, DM[7:0]};
					01 : LD = {24'b0, DM[15:8]};
					10 : LD = {24'b0, DM[23:16]};
					11 : LD = {24'b0, DM[31:24]};
					default : LD = '0;
				endcase
			end
			101 : begin
				unique case (MAR2)
					00 : LD = {16'b0, DM[15:0]};
					01 : LD = '0;
					10 : LD = {16'b0, DM[31:16]};
					11 : LD = '0;
					default : LD = '0;
				endcase
			end
			default : LD = '0;
		endcase		
	end

endmodule
