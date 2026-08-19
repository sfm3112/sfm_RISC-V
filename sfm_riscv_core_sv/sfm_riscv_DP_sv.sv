/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//																Data Path RISCV File																		  //
//													Created by: Stephen Meyer (5/29/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////TYPEDEF DECLARATION//////////////////////////////////////////////////////

typedef struct packed{
	logic invalid_iw;
	logic [4:0] rd;
	logic ld_rd;
	logic [1:0] wb_mux_sel;
	logic [31:0] pc_wb;
	logic stall;
	logic flush;
	logic ld_pc;
	logic p_wren;
	logic d_wren;
	logic ld_ipdr;
	logic ld_opdr;
	logic [2:0] ld_type;
	logic ipd_mux_sel;
	logic [2:0] mf_sel;
	logic [2:0] af_b_sel;
	logic [2:0] af_a_sel;
	logic [2:0] b_type;
	logic [4:0] alu_sel;
	logic op_b_sel;
	logic op_a_sel;
	logic [4:0] rs_2;
	logic [4:0] rs_1;
	logic [31:0] imm;
} cu_code_t;

///////////////////////////////////////////////////MODULE DECLARATION///////////////////////////////////////////////////////

module sfm_riscv_DP_sv # (parameter int WIDTH = 32, parameter int PIPELINE_WIDTH = 113)
								(input logic clk, rst_n, output logic [63:0]inst_word,
																	input cu_code_t cu_code, input logic [WIDTH-1:0]ipd, 
																	output logic [WIDTH-1:0]opd);
	
//////////////////////////////////////////////////////LOCALPARAM NAMES//////////////////////////////////////////////////////
	
localparam logic [WIDTH-1:0] STALL_IW = 32'h33; //should be the opcode for "add x0 x0 x0"
	
/////////////////////////////////////////////////////////WIRE NAMES/////////////////////////////////////////////////////////

logic [WIDTH-1:0]rs_a, rs_b, dw;	//Main busses
logic [WIDTH-1:0] pipeline_in;
cu_code_t ex_code, mem_code, wb_code;	//Pipeline Wires
logic b_check, b_taken, b_taken_held; 
logic [WIDTH-1:0] wb_dec_out; logic [WIDTH-1:0][WIDTH-1:0] x_q; //Register signals
logic [WIDTH-1:0]op_a, op_b, alu_res, alu_out, alu_wb;	//ALU wires
logic [WIDTH-1:0] arith_a_forward, arith_b_forward; //spare ALU related wires
logic [WIDTH-1:0] pm_out, dm_out; //memory outputs
logic [WIDTH-1:0] mem_forward, mem_wb;
logic [WIDTH-1:0] ld_out;
logic [WIDTH-1:0] ipdr_out, ipd_mux_out;
logic [3:0] byteena_b;
logic [WIDTH-1:0] pc_out;
logic [WIDTH-1:0] rs_b_held_a;

// Pipeline Wires

//////////////////////////////////////////////////////////PIPELINE//////////////////////////////////////////////////////////

//----------------------------------------------------PIPELINE SIGNALS----------------------------------------------------//


//	invalid_iw = wb_code.invalid_iw;
//	rd = wb_code.rd;
//	ld_rd = wb_code.ld_rd;
//	wb_mux_sel = wb_code.wb_mux_sel;
//	pc_wb = wb_code.pc_wb;
//	stall = mem_code.stall;
//	flush = mem_code.flush;
//	ld_pc = mem_code.ld_pc;
//	p_wren = mem_code.p_wren;
//	d_wren = mem_code.d_wren;
//	ld_ipdr = mem_code.ld_ipdr;
//	ld_opdr = mem_code.ld_opdr;
//	ld_type = mem_code.ld_type;
//	ipd_mux_sel = mem_code.ipd_mux_sel;
//	mf_sel = mem_code.mf_sel;
//	af_b_sel = ex_code.af_b_sel;
//	af_a_sel = ex_code.af_a_sel;
//	b_type = ex_code.b_type;
//	alu_sel = ex_code.alu_sel;
//	op_b_sel = ex_code.op_b_sel;
//	op_a_sel = ex_code.op_a_sel;
//	rs_2 = ex_code.rs_2;
//	rs_1 = ex_code.rs_1;
//	imm = ex_code.imm;

//------------------------------------------------------PIPELINE MUX------------------------------------------------------//
										 
	sfm_riscv_Pipeline_Reg_sv #(.PIPELINE_WIDTH(64)) IF_ID_Reg (.d({pc_out, pipeline_in}), .clk(clk), .flush(mem_code.flush | b_taken_held), .rst_n(rst_n), .q(inst_word));
	sfm_riscv_Pipeline_Reg_sv #(.PIPELINE_WIDTH($bits(cu_code_t))) ID_EX_Reg (.d(cu_code), .clk(clk), .flush(mem_code.flush | b_taken_held), .rst_n(rst_n), .q(ex_code));
	sfm_riscv_Pipeline_Reg_sv #(.PIPELINE_WIDTH($bits(cu_code_t))) EX_MEM_Reg (.d(ex_code), .clk(clk), .flush(mem_code.flush | b_taken_held), .rst_n(rst_n), .q(mem_code));
	sfm_riscv_Pipeline_Reg_sv #(.PIPELINE_WIDTH($bits(cu_code_t))) Mem_Wb_Reg (.d(mem_code), .clk(clk), .flush('0), .rst_n(rst_n), .q(wb_code));
	
//-------------------------------------------------------STALL MUX--------------------------------------------------------//

	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(2), .SEL_WIDTH(1)) StallMux (.mux_input({STALL_IW, pm_out}), .sel(mem_code.stall), .out(pipeline_in));
	
/////////////////////////////////////////////////////REGISTER COMPONENTS////////////////////////////////////////////////////

//---------------------------------------------------WRITE BACK DECODER---------------------------------------------------//

	sfm_riscv_WbDec_sv #(.WIDTH(WIDTH)) WriteBackDecoder (.dec_sel(wb_code.rd), .ld_rd(wb_code.ld_rd), .wb_dec_out(wb_dec_out));
	
//----------------------------------------------------REGISTERS x0:x31----------------------------------------------------//
genvar i;
	generate for (i = 0; i < WIDTH; i = i + 1) 
		begin : register_stage
			sfm_riscv_NbitReg_ld_rst_sv #(.WIDTH(WIDTH)) NbitRegister (.d(dw), .clk(clk), .ld(wb_dec_out[i]), .rst_n(rst_n), .q(x_q[i]));
		end
	endgenerate

//--------------------------------------------------MUX'S FOR RSA AND RSB-------------------------------------------------//	

	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(WIDTH), .SEL_WIDTH(5)) RegMuxA (.mux_input(x_q), .sel(ex_code.rs_1), .out(rs_a));
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(WIDTH), .SEL_WIDTH(5)) RegMuxB (.mux_input(x_q), .sel(ex_code.rs_2), .out(rs_b));

////////////////////////////////////////////////////////ALU COMPONENTS//////////////////////////////////////////////////////

//----------------------------------------------------------ALU-----------------------------------------------------------//

	sfm_riscv_ALU_sv #(.WIDTH(WIDTH)) ArithmeticLogicUnit 
							(.pc_out(ex_code.pc_wb), .op_a(op_a), .imm(ex_code.imm), .op_b(op_b), .alu_sel(ex_code.alu_sel), .alu_res(alu_res), .b_check(b_check));
	
//----------------------------------------------------ALU'S INPUT MUX's----------------RSB 1, IMM 0-----------------------//
	
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(2), .SEL_WIDTH(1)) OpAMux (.mux_input({arith_a_forward, rs_a}), .sel(ex_code.op_a_sel), .out(op_a));
	
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(2), .SEL_WIDTH(1)) OpBMux (.mux_input({arith_b_forward, rs_b}), .sel(ex_code.op_b_sel), .out(op_b));
	
//------------------------------------------------Branch Conditional Logic------------------------------------------------//

	sfm_riscv_BCondLogic_sv #(.B_TYPE_WIDTH(3)) BranchConditionalLogicUnit (.condition_in(b_check), .b_type(ex_code.b_type), .b_taken(b_taken));
	
//-------------------------------------------------ALU PIPELINE REGISTERS-------------------------------------------------//

	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) AluOutRegister (.d(alu_res), .clk(clk), .q(alu_out));
	
	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) AluWriteBackRegister (.d(alu_out), .clk(clk), .q(alu_wb));
	
//-----------------------------------------------B_CHECK PIPELINE REGISTER------------------------------------------------//
	
	sfm_riscv_NbitReg_sv #(.WIDTH(1)) BranchCheckRegister (.d(b_taken), .clk(clk), .q(b_taken_held));
	

/////////////////////////////////////////////////////////FORWARD MUX'S//////////////////////////////////////////////////////

	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(6), .SEL_WIDTH(3)) 
			AluForwardMuxA (.mux_input({mem_code.pc_wb, ex_code.pc_wb, mem_wb, alu_wb, ld_out, alu_out}), .sel(ex_code.af_a_sel), .out(arith_a_forward));
	
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(6), .SEL_WIDTH(3)) 
			AluForwardMuxB (.mux_input({mem_code.pc_wb, ex_code.pc_wb, mem_wb, alu_wb, ld_out, alu_out}), .sel(ex_code.af_b_sel), .out(arith_b_forward));
	
	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(8), .SEL_WIDTH(3)) 
			MemForwardMux (.mux_input({rs_b_held_a, mem_code.pc_wb, ex_code.pc_wb, alu_out, mem_wb, alu_wb, ld_out, rs_b}), .sel(mem_code.mf_sel), .out(mem_forward));
			
//-------------------------------------------------------RS_B REGISTER----------------------------------------------------//

	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) RsBRegisterA (.d(alu_wb), .clk(clk), .q(rs_b_held_a));

///////////////////////////////////////////////////////MEMORY COMPONENTS////////////////////////////////////////////////////

//--------------------------------------------------COMBINED PM-DM MODULE-------------------------------------------------//
	// NOTE ADDRESSES ARE 12-BIT NOT 32-BIT, PCOUT USES BITS [13:2] SINCE PC INCREMENTS BY 4
	// Had to not the clock so it wouldn't turn the IF stage into 2 clock cycles. Not ideal
	
	PM_DM PM_DM_RAM (.address_a(pc_out[13:2]), .address_b(alu_out[13:2]), .byteena_b(byteena_b), .clock(~clk), .data_a(32'b0),
							.data_b(mem_forward), .wren_a(mem_code.p_wren), .wren_b(mem_code.d_wren && !(alu_out[31:14])), .q_a(pm_out), .q_b(dm_out));

//------------------------------------------------------BYTEENA MODULE----------------------------------------------------//

	sfm_riscv_Byteena_sv ByteenaB (.addr_lsb_in(alu_out[1:0]), .st_type(mem_code.ld_type[1:0]), .decode_out(byteena_b));

//--------------------------------------------------PROGRAM COUNTER MODULE------------------------------------------------//

	sfm_riscv_PC_sv #(.WIDTH(WIDTH)) 
		ProgramCounter (.D(mem_forward), .ld_pc(mem_code.ld_pc | b_taken_held), .rst_n(rst_n), .stall(mem_code.stall), .clk(clk), .Q(pc_out));
	
//------------------------------------------------------IPD/DmOut MUX-----------------------------------------------------//

	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(2), .SEL_WIDTH(1)) 
						IpdMux (.mux_input({dm_out, ipdr_out}), .sel(mem_code.ipd_mux_sel && !(alu_out[31:14])), .out(ipd_mux_out));

//----------------------------------------------------BIT MASK LOGIC BLOCK------------------------------------------------//
	
	sfm_riscv_BMaskLogic_sv #(.WIDTH(WIDTH)) BitMaskLogic (.ipd_mux_out(ipd_mux_out), .ld_part(alu_out[1:0]), .ld_type(mem_code.ld_type), .ld(ld_out));
	
//------------------------------------------------------MEMORY REGISTER---------------------------------------------------//

	sfm_riscv_NbitReg_sv #(.WIDTH(WIDTH)) MemWriteBackRegister (.d(ld_out), .clk(clk), .q(mem_wb));
		
////////////////////////////////////////////////////////IOP COMPONENTS//////////////////////////////////////////////////////

	sfm_riscv_NbitReg_ld_rst_sv #(.WIDTH(WIDTH)) OpdrReg (.d(mem_forward), .clk(~clk), .ld(mem_code.ld_opdr && (alu_out[31:14])), .rst_n(rst_n), .q(opd));
	sfm_riscv_NbitReg_ld_rst_sv #(.WIDTH(WIDTH)) IpdrReg (.d(ipd), .clk(~clk), .ld(mem_code.ld_ipdr), .rst_n(rst_n), .q(ipdr_out));
	
/////////////////////////////////////////////////////////WITE BACK MUX//////////////////////////////////////////////////////

	sfm_riscv_NbitMux_sv #(.WIDTH(WIDTH), .SEL_NUM(3), .SEL_WIDTH(2)) 
				WriteBackMux (.mux_input({(wb_code.pc_wb + 'h4), mem_wb, alu_wb}), .sel(wb_code.wb_mux_sel), .out(dw));
	
endmodule
