/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Data Path RISCV File
	Created by: Stephen Meyer (5/29/2026)

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// WIDTH left undefined here so it must take the WIDTH defined in core, else compile error.                   NOT COMPLETED
module sfm_riscv_DP_sv # (parameter int WIDTH)(input logic clk, output logic OPD);
	
/////////////////////////////////////////////////////////WIRE NAMES/////////////////////////////////////////////////////////



///////////////////////////////////////////////////COMPONENT INSTANTIATION//////////////////////////////////////////////////

	sfm_riscv_ALU_sv #(.WIDTH(WIDTH)) ArithmeticLogicUnit ();
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(2), .SelWidth(1)) RegMuxALU ();

	sfm_riscv_WbDec_sv #(.WIDTH(WIDTH)) WriteBackDecoder ();
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) NbitRegister ();
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(WIDTH), .SelWidth(5)) RegMuxA ();
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(WIDTH), .SelWidth(5)) RegMuxB ();
	
	// NOTE ADDRESSES ARE 12-BIT NOT 32-BIT
	PM_DM PM_DM_RAM (.address_a(), .address_b(), .byteena_b(), .clock(), .data_a(), .data_b(), .wren_a(), .wren_b(), .q_a(), .q_b());


	
endmodule
