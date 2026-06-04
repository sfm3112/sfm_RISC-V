/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Top Level riscv core file
	Created by: Stephen Meyer (5/29/2026)
	
	Copyright (C) 2026 Stephen Meyer

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_core_sv # (parameter int WIDTH = 32)(input logic clk, rst, output logic OPD);
	
/////////////////////////////////////////////////////////WIRE NAMES/////////////////////////////////////////////////////////

logic [WIDTH-1:0] IW;
logic LDrd, LdPC, cntPC, LdIWR, WBsel, LdMAB, LdMAX, LdOPDR;

///////////////////////////////////////////////////COMPONENT INSTANTIATION//////////////////////////////////////////////////	
	sfm_riscv_DP_sv #(.WIDTH(WIDTH)) DataPath (.clk(clk), .rst(rst), .IW(IW), .LDrd(LDrd), .LdPC(LdPC), .cntPC(cntPC), 
															.LdIWR(LdIWR), .WBsel(WBsel), .LdMAB(LdMAB), .LdMAX(LdMAX), .LdOPDR(LdOPDR),
															.OPD(OPD));

	sfm_riscv_CU_sv #(.WIDTH(WIDTH)) ControlUnit (.clk(clk), .rst(rst), .IW(IW), .LDrd(LDrd), .LdPC(LdPC), .cntPC(cntPC), 
															.LdIWR(LdIWR), .WBsel(WBsel), .LdMAB(LdMAB), .LdMAX(LdMAX), .LdOPDR(LdOPDR));
endmodule
