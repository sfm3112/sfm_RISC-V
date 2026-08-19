/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//												 	  Bit Mask Logic Module RISCV File														        //
//													Created by: Stephen Meyer (6/2/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_BMaskLogic_sv # (parameter int WIDTH = 32, parameter int PART_WIDTH = 2, parameter int TYPE_WIDTH = 3)
											(input logic [WIDTH-1:0]ipd_mux_out, input logic [1:0]ld_part, input logic [2:0]ld_type, output logic [WIDTH-1:0]ld);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

localparam logic [TYPE_WIDTH-1:0] LB = 'd0;
localparam logic [TYPE_WIDTH-1:0] LH = 'd1;
localparam logic [TYPE_WIDTH-1:0] LW = 'd2;
localparam logic [TYPE_WIDTH-1:0] LBU = 'd4;
localparam logic [TYPE_WIDTH-1:0] LHU = 'd5;


	always_comb begin
		case (ld_type)
			LB : begin
				unique case (ld_part)
					'b00 : ld = WIDTH'($signed(ipd_mux_out[7:0]));
					'b01 : ld = WIDTH'($signed(ipd_mux_out[15:8]));
					'b10 : ld = WIDTH'($signed(ipd_mux_out[23:16]));
					'b11 : ld = WIDTH'($signed(ipd_mux_out[31:24]));
					default : ld = 'b0;
				endcase
			end
			LH : begin
				unique case (ld_part)
					'b00 : ld = WIDTH'($signed(ipd_mux_out[15:0]));
					'b01 : ld = 'b0;
					'b10 : ld = WIDTH'($signed(ipd_mux_out[31:16]));
					'b11 : ld = 'b0;
					default : ld = 'b0;
				endcase
			end
			LW : begin
				unique case (ld_part)
					'b00 : ld = WIDTH'(ipd_mux_out);
					'b01 : ld = 'b0;
					'b10 : ld = 'b0;
					'b11 : ld = 'b0;
					default : ld = 'b0;
				endcase
			end
			LBU : begin
				unique case (ld_part)
					'b00 : ld = WIDTH'($unsigned(ipd_mux_out[7:0]));
					'b01 : ld = WIDTH'($unsigned(ipd_mux_out[15:8]));
					'b10 : ld = WIDTH'($unsigned(ipd_mux_out[23:16]));
					'b11 : ld = WIDTH'($unsigned(ipd_mux_out[31:24]));
					default : ld = 'b0;
				endcase
			end
			LHU : begin
				unique case (ld_part)
					'b00 : ld = WIDTH'($unsigned(ipd_mux_out[15:0]));
					'b01 : ld = 'b0;
					'b10 : ld = WIDTH'($unsigned(ipd_mux_out[31:16]));
					'b11 : ld = 'b0;
					default : ld = 'b0;
				endcase
			end
			default : ld = 'b0;
		endcase
	end
endmodule
