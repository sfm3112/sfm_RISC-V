/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Data Path RISCV File
	Created by: Stephen Meyer (5/29/2026)

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// WIDTH left undefined here so it must take the WIDTH defined in core, else compile error.                   NOT COMPLETED
module sfm_riscv_DP_sv # (parameter int WIDTH)(input logic clk, input logic [WIDTH-1:0]IW, 
									output logic OPD);
	
/////////////////////////////////////////////////////////WIRE NAMES/////////////////////////////////////////////////////////

logic [WIDTH-1:0]rsA, rsB, dW;	//Main busses
logic [WIDTH-1:0]ALUres, AluB;	//ALU wires
logic [WIDTH-1:0]Imm;


///////////////////////////////////////////////////COMPONENT INSTANTIATION//////////////////////////////////////////////////

////////////////////////////////////////////////////////ALU COMPONENTS//////////////////////////////////////////////////////

//----------------------------------------------------------ALU-----------------------------------------------------------//

	sfm_riscv_ALU_sv #(.WIDTH(WIDTH)) ArithmeticLogicUnit (.intA(rsA), .intB(AluB), .Func3(IW[14:12]), .Func7(IW[30]), .ALUres(ALUres));
	
//----------------------------------------------------ALU'S B INPUT MUX----------------RSB 1, IMM 0-----------------------//
	
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(2), .SelWidth(1)) RegMuxALU (.muxInput({rsB, Imm}), .Sel(IW[5]), .out(AluB));
	
/////////////////////////////////////////////////////REGISTER COMPONENTS////////////////////////////////////////////////////

//---------------------------------------------------WRITE BACK DECODEER--------------------------------------------------//

	sfm_riscv_WbDec_sv #(.WIDTH(WIDTH)) WriteBackDecoder (.DECsel(), .LDrd(), .WBsel());
	
//----------------------------------------------------REGISTERS x0:x31----------------------------------------------------//
	
	generate for (genvar i = 0; i < WIDTH; i = i + 1) 
		begin :
			register_stage sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) NbitRegister (.D(dW), .clk(WBsel[i]), .rst(rst), .Q(xQ));
		end
	endgenerate
	
//--------------------------------------------------MUX'S FOR RSA AND RSB-------------------------------------------------//	
	
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(WIDTH), .SelWidth(5)) RegMuxA (.muxInput(), .Sel(), .out());
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(WIDTH), .SelWidth(5)) RegMuxB (.muxInput(), .Sel(), .out());

///////////////////////////////////////////////////////MEMORY COMPONENTS////////////////////////////////////////////////////
	// NOTE ADDRESSES ARE 12-BIT NOT 32-BIT
	PM_DM PM_DM_RAM (.address_a(), .address_b(), .byteena_b(), .clock(), .data_a(), .data_b(), .wren_a(), .wren_b(), .q_a(), .q_b());
	sfm_riscv_PC_sv #(.WIDTH(WIDTH)) ProgramCounter (.D(), .ld(), .rst(), .cnt(), .clk(), .Q());
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) IWRreg (.D(), .clk(), .rst(), .Q());
	
	sfm_riscv_BMaskLogic_sv #(.WIDTH(WIDTH)) BitMaskLogic (.DM(), .LB(), .LH(), .LW(), .LBU(), .LHU());
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(5), .SelWidth(3)) LDmux (.muxInput(), .Sel(), .out());
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(5), .SelWidth(3)) WBmux (.muxInput(), .Sel(), .out());

	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) MABreg (.D(), .clk(), .rst(), .Q());
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) MAXreg (.D(), .clk(), .rst(), .Q());
	
	MARout = MABout + MAXout;
	
/////////////////////////////////////////////////////IMMEDIATE COMPONENTS///////////////////////////////////////////////////
	sfm_riscv_immPro_sv #(.WIDTH(.WIDTH)) immediateProcessor (.IW(), .I(), .S(), .B(), .U(), .J());
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(5), .SelWidth(4)) immMux (.muxInput(), .Sel(), .out());
	
////////////////////////////////////////////////////////IOP COMPONENTS//////////////////////////////////////////////////////
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) opdrReg (.D(), .clk(), .rst(), .Q());
	


	
endmodule
