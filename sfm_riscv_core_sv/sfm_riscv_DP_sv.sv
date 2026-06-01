/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Data Path RISCV File
	Created by: Stephen Meyer (5/29/2026)

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// WIDTH left undefined here so it must take the WIDTH defined in core, else compile error.                   NOT COMPLETED
module sfm_riscv_DP_sv # (parameter int WIDTH)(input logic clk, output logic OPD);
	
/////////////////////////////////////////////////////////WIRE NAMES/////////////////////////////////////////////////////////

//WbDec, PC, BMaskLogic, immPro --Modules left to be completed--

///////////////////////////////////////////////////COMPONENT INSTANTIATION//////////////////////////////////////////////////

////////////////////////////////////////////////////////ALU COMPONENTS//////////////////////////////////////////////////////

	sfm_riscv_ALU_sv #(.WIDTH(WIDTH)) ArithmeticLogicUnit ();
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(2), .SelWidth(1)) RegMuxALU ();
	
//////////////////////////////////////////////////////REGISTER COMPONENTS///////////////////////////////////////////////////

	sfm_riscv_WbDec_sv #(.WIDTH(WIDTH)) WriteBackDecoder ();
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) NbitRegister ();	// NEEDS TO BE GENERATE FOR LOOPED
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(WIDTH), .SelWidth(5)) RegMuxA ();
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(WIDTH), .SelWidth(5)) RegMuxB ();

///////////////////////////////////////////////////////MEMORY COMPONENTS////////////////////////////////////////////////////
	// NOTE ADDRESSES ARE 12-BIT NOT 32-BIT
	PM_DM PM_DM_RAM (.address_a(), .address_b(), .byteena_b(), .clock(), .data_a(), .data_b(), .wren_a(), .wren_b(), .q_a(), .q_b());
	sfm_riscv_PC_sv #(.WIDTH(WIDTH)) ProgramCounter ();
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) IWRreg ();
	
	sfm_riscv_BMaskLogic_sv #(.WIDTH(WIDTH)) BitMaskLogic ();
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(5), .SelWidth(3)) LDmux ();
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(5), .SelWidth(3)) WBmux ();

	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) MABreg ();
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) MAXreg ();
	
	MARout = MABout + MAXout;
	
/////////////////////////////////////////////////////IMMEDIATE COMPONENTS///////////////////////////////////////////////////
	sfm_riscv_immPro_sv #(.WIDTH(.WIDTH)) immediateProcessor ();
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(5), .SelWidth(4)) immMux ();
	
////////////////////////////////////////////////////////IOP COMPONENTS//////////////////////////////////////////////////////
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) opdrReg ();
	


	
endmodule
