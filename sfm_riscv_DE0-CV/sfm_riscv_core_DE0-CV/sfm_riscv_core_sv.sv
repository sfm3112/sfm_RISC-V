/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//													 Top Level Pipelined RISC-V core file															  //
//													Created by: Stephen Meyer (5/29/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_core_sv # (parameter int WIDTH = 32, parameter int PIPELINE_WIDTH = 113)
									(input logic clk, rst_n, input logic [WIDTH-1:0] ipd, output logic [WIDTH-1:0] opd);
	
/////////////////////////////////////////////////////////WIRE NAMES/////////////////////////////////////////////////////////

logic [63:0] inst_word;
logic [PIPELINE_WIDTH-1:0] cu_code;

///////////////////////////////////////////////////COMPONENT INSTANTIATION//////////////////////////////////////////////////	
	sfm_riscv_DP_sv #(.WIDTH(WIDTH), .PIPELINE_WIDTH(PIPELINE_WIDTH)) 
		DataPath (.clk(clk), .rst_n(rst_n), .inst_word(inst_word), .cu_code(cu_code), .ipd(ipd), .opd(opd));

	sfm_riscv_CU_sv #(.WIDTH(WIDTH), .PIPELINE_WIDTH(PIPELINE_WIDTH)) 
		ControlUnit (.clk(clk), .rst_n(rst_n), .inst_word(inst_word[WIDTH-1:0]), .pc_out(inst_word[63:WIDTH]), .cu_code(cu_code));

endmodule
