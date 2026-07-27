/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Data Path RISCV File
	Created by: Stephen Meyer (5/29/2026)
	
	Copyright (C) 2026 Stephen Meyer

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// WIDTH left undefined here so it must take the WIDTH defined in core, else compile error.                   NOT COMPLETED
module sfm_riscv_DP_sv # (parameter int WIDTH = 32)(input logic clk, rst, output logic [WIDTH-1:0]IW, output logic [2:0]CNZres, input logic [2:0]WBsel, input logic LDrd, LdPC, cntPC, LdIWR, LdMAB, LdMAX, pR_W, dR_W, LdOPDR, MAXsel,
									output logic [WIDTH-1:0]OPD);
	
/////////////////////////////////////////////////////////WIRE NAMES/////////////////////////////////////////////////////////

logic [WIDTH-1:0]rsA, rsB, dW;	//Main busses
logic [WIDTH-1:0]ALUres, AluB;	//ALU wires
logic [WIDTH-1:0]Imm;
logic [WIDTH-1:0]WBout;
logic [WIDTH-1:0][WIDTH-1:0]xQ;
logic [WIDTH-1:0]MAXin, MAXout, MABout, MARout;
logic [WIDTH-1:0]PCout, PMout, DMout;
logic [WIDTH-1:0]LD;
logic [WIDTH-1:0]I, S, B, U, J;
logic [3:0]byteEnable;

///////////////////////////////////////////////////COMPONENT INSTANTIATION//////////////////////////////////////////////////

////////////////////////////////////////////////////////ALU COMPONENTS//////////////////////////////////////////////////////

//----------------------------------------------------------ALU-----------------------------------------------------------//

	sfm_riscv_ALU_sv #(.WIDTH(WIDTH)) ArithmeticLogicUnit (.intA(rsA), .intB(AluB), .Func3(IW[14:12]), .add_sub(((IW[30] & IW[5]) | IW[6])), .SHsel(IW[30]), .ALUres(ALUres), .CNZres(CNZres));
	
//----------------------------------------------------ALU'S B INPUT MUX----------------RSB 1, IMM 0-----------------------//
	
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(2), .SelWidth(1)) RegMuxALU (.muxInput({rsB, Imm}), .Sel(IW[5]), .out(AluB));
	
/////////////////////////////////////////////////////REGISTER COMPONENTS////////////////////////////////////////////////////

//---------------------------------------------------WRITE BACK DECODER---------------------------------------------------//

	sfm_riscv_WbDec_sv #(.WIDTH(WIDTH)) WriteBackDecoder (.DECsel(IW[11:7]), .LDrd(LDrd), .WBout(WBout));
	
//----------------------------------------------------REGISTERS x0:x31----------------------------------------------------//
genvar i;
	generate for (i = 0; i < WIDTH; i = i + 1) 
		begin : register_stage
			sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) NbitRegister (.D(dW), .clk(WBout[i]), .rst(rst), .Q(xQ[i]));
		end
	endgenerate
	
//--------------------------------------------------MUX'S FOR RSA AND RSB-------------------------------------------------//	
	
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(WIDTH), .SelWidth(5)) RegMuxA (.muxInput(xQ), .Sel(IW[19:15]), .out(rsA));
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(WIDTH), .SelWidth(5)) RegMuxB (.muxInput(xQ), .Sel(IW[24:20]), .out(rsB));

///////////////////////////////////////////////////////MEMORY COMPONENTS////////////////////////////////////////////////////

//--------------------------------------------------BYTE ENABLE DATA LOGIC------------------------------------------------//

	sfm_riscv_byteEnLogic_sv byteEnLogic (.func3(IW[14:12]), .MAR2(MARout[1:0]), .byteEnable(byteEnable[3:0]));

//--------------------------------------------------COMBINED PM-DM MODULE-------------------------------------------------//
// NOTE ADDRESSES ARE 12-BIT NOT 32-BIT, PCOUT USES BITS [13:2] SINCE PC INCREMENTS BY 4
	PM_DM PM_DM_RAM (.address_a(PCout[13:2]), .address_b(MARout[13:2]), .byteena_b(byteEnable), .clock(clk), .data_a(32'b0), .data_b(rsB), .wren_a(pR_W), .wren_b(dR_W), .q_a(PMout), .q_b(DMout));

//--------------------------------------------------PROGRAM COUNTER MODULE------------------------------------------------//

	sfm_riscv_PC_sv #(.WIDTH(WIDTH)) ProgramCounter (.D(MARout), .ld(LdPC), .rst(rst), .cnt(cntPC), .clk(clk), .Q(PCout));
	
//-------------------------------------------------INSTRUCTION WORD REGISTER----------------------------------------------//
	
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) IWRreg (.D(PMout), .clk(LdIWR), .rst(rst), .Q(IW));
	
//----------------------------------------------------BIT MASK LOGIC BLOCK------------------------------------------------//
	
	sfm_riscv_BMaskLogic_sv #(.WIDTH(WIDTH)) BitMaskLogic (.DM(DMout), .Func3(IW[14:12]), .MAR2(MARout[1:0]), .LD(LD));
	
//---------------------------------------------------WRITE BACK MULTIPLEXER-----------------------------------------------//
	
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(8), .SelWidth(3)) WBmux (.muxInput({32'b0, 32'b0, PCout, MARout, IW, Imm, LD, ALUres}), .Sel(WBsel), .out(dW));

//---------------------------------------------------MAB AND MAX REGISTERS------------------------------------------------//
	
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) MABreg (.D(Imm), .clk(LdMAB), .rst(rst), .Q(MABout));
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) MAXreg (.D(MAXin), .clk(LdMAX), .rst(rst), .Q(MAXout));
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SelNum(2), .SelWidth(1)) MAXmux (.muxInput({PCout, rsA}), .Sel(MAXsel), .out(MAXin));
	
	assign MARout = MABout + MAXout;
	
/////////////////////////////////////////////////////IMMEDIATE COMPONENTS///////////////////////////////////////////////////

	sfm_riscv_immPro_sv #(.WIDTH(WIDTH)) immediateProcessor (.IW(IW), .I(I), .S(S), .B(B), .U(U), .J(J));

//-------------------------------------------------IMMEDIATE SELECT STRUCTURE---------------------------------------------//

	sfm_riscv_ImmSelMux_sv #(.WIDTH(WIDTH)) ImmediateSelectMultiplexer (.ImmIW({IW[6:5], IW[3:2]}), .I(I), .S(S), .B(B), .U(U), .J(J), .Imm(Imm));
	
////////////////////////////////////////////////////////IOP COMPONENTS//////////////////////////////////////////////////////

	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) opdrReg (.D(rsB), .clk(LdOPDR), .rst(rst), .Q(OPD));
	
endmodule
