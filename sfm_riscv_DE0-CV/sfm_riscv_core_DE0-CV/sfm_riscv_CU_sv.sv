/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//													 		Control Unit RISCV File																	     //
//													Created by: Stephen Meyer (6/4/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module sfm_riscv_CU_sv # (parameter int WIDTH = 32, parameter int PIPELINE_WIDTH = 113, parameter int ALU_SEL_WIDTH = 5,
									parameter int B_TYPE_WIDTH = 3, parameter int TYPE_WIDTH = 3)
									(input logic clk, rst_n, input logic [WIDTH-1:0]inst_word, pc_out, output logic [PIPELINE_WIDTH-1:0] cu_code);

/////////////////////////////////////////////////////////CONSTANTS//////////////////////////////////////////////////////////

//------------------------------------------------------OPCODE TYPES------------------------------------------------------//

localparam logic [6:0] TYPE_R  	=	7'b0110011;
localparam logic [6:0] TYPE_I  	=	7'b0010011;
localparam logic [6:0] TYPE_L  	=	7'b0000011;
localparam logic [6:0] TYPE_JR 	=	7'b1100111;
localparam logic [6:0] TYPE_S  	=	7'b0100011;
localparam logic [6:0] TYPE_B  	=	7'b1100011;
localparam logic [6:0] TYPE_UI	=	7'b0110111;
localparam logic [6:0] TYPE_UPC	=	7'b0010111;
localparam logic [6:0] TYPE_J  	=	7'b1101111;

//--------------------------------------------------------ALU TYPES-------------------------------------------------------//

localparam logic [ALU_SEL_WIDTH-1:0] ADD = 'd0; //also serves as NOP
localparam logic [ALU_SEL_WIDTH-1:0] SLL = 'd1;
localparam logic [ALU_SEL_WIDTH-1:0] SLT = 'd2;
localparam logic [ALU_SEL_WIDTH-1:0] SLTU = 'd3;
localparam logic [ALU_SEL_WIDTH-1:0] XOR = 'd4;
localparam logic [ALU_SEL_WIDTH-1:0] SRL = 'd5;
localparam logic [ALU_SEL_WIDTH-1:0] OR = 'd6;
localparam logic [ALU_SEL_WIDTH-1:0] AND = 'd7;
localparam logic [ALU_SEL_WIDTH-1:0] SUB = 'd8;
localparam logic [ALU_SEL_WIDTH-1:0] SRA = 'd9;

localparam logic [ALU_SEL_WIDTH-1:0] ADDI_LD_JALR_ST_LUI = 'd16;
localparam logic [ALU_SEL_WIDTH-1:0] SLLI = 'd17;
localparam logic [ALU_SEL_WIDTH-1:0] SLTI = 'd18;
localparam logic [ALU_SEL_WIDTH-1:0] SLTIU = 'd19;
localparam logic [ALU_SEL_WIDTH-1:0] XORI = 'd20;
localparam logic [ALU_SEL_WIDTH-1:0] SRLI = 'd21;
localparam logic [ALU_SEL_WIDTH-1:0] ORI = 'd22;
localparam logic [ALU_SEL_WIDTH-1:0] ANDI = 'd23;
localparam logic [ALU_SEL_WIDTH-1:0] SRAI = 'd24;

localparam logic [ALU_SEL_WIDTH-1:0] BEQ_BNE = 'd10;
localparam logic [ALU_SEL_WIDTH-1:0] BLT_BGE = 'd13;
localparam logic [ALU_SEL_WIDTH-1:0] BLTU_BGEU = 'd14;

localparam logic [ALU_SEL_WIDTH-1:0] AUIPC_JAL = 'd12;

//-------------------------------------------------------LOAD TYPES-------------------------------------------------------//

localparam logic [TYPE_WIDTH-1:0] LB = 'd0;
localparam logic [TYPE_WIDTH-1:0] LH = 'd1;
localparam logic [TYPE_WIDTH-1:0] LW = 'd2;
localparam logic [TYPE_WIDTH-1:0] LBU = 'd4;
localparam logic [TYPE_WIDTH-1:0] LHU = 'd5;

//------------------------------------------------------BRANCH TYPES------------------------------------------------------//

localparam logic [B_TYPE_WIDTH-1:0] NOT_B = 'd0;
localparam logic [B_TYPE_WIDTH-1:0] BEQ = 'd1;
localparam logic [B_TYPE_WIDTH-1:0] BNE = 'd2;
localparam logic [B_TYPE_WIDTH-1:0] BLT = 'd3;
localparam logic [B_TYPE_WIDTH-1:0] BGE = 'd4;
localparam logic [B_TYPE_WIDTH-1:0] BLTU = 'd5;
localparam logic [B_TYPE_WIDTH-1:0] BGEU = 'd6;

//-----------------------------------------------------CU_CODE PARTS------------------------------------------------------//

logic [WIDTH-1:0] imm, pc_wb;
logic [4:0] rs1, rs2, rd, alu_sel;
logic op_a_sel, op_b_sel, ipd_mux_sel, ld_opdr, ld_ipdr, d_wren, p_wren, ld_pc, ld_rd, flush, stall, invalid_iw;
logic [2:0] b_type, ld_type, mf_sel;
logic [2:0] af_a_sel, af_b_sel;
logic [1:0] wb_mux_sel; 

///////////////////////////////////////////////////////CONTROL UNIT/////////////////////////////////////////////////////////

logic [6:0] haz_flg_z, haz_flg_a, haz_flg_b; 
// logic [6:0] haz_flg_c;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		  haz_flg_a <= '0;
		  haz_flg_b <= '0;
		  //haz_flg_c <= '0;
    end else begin
        haz_flg_a <= haz_flg_z;
		  haz_flg_b <= haz_flg_a;
		  //haz_flg_c <= haz_flg_b;
	end
end

always_comb begin


				
invalid_iw = 1'b0;

case (inst_word[6:0]) 
	TYPE_R : begin //-------------------------------------TYPE_R-----------------------------------------------------------//
		//basic controls
		imm = '0;
		rs1 = inst_word[19:15];
		rs2 = inst_word[24:20];
		rd = inst_word[11:7];
		b_type = '0;
		ipd_mux_sel = '0;
		ld_type = '0;
		ld_opdr = '0;
		ld_ipdr = '0;
		d_wren = '0;
		p_wren ='0;
		ld_pc = '0;
		pc_wb = pc_out;
		wb_mux_sel = '0;
		ld_rd = 1'b1;
		haz_flg_z = (rd != 5'd0) ? {2'b0, inst_word[11:7]} : '0;
		
		//alu_sel
		case ({inst_word[30], inst_word[14:12]})
			4'b0000 : alu_sel = ADD;
			4'b1000 : alu_sel = SUB;
			4'b0001 : alu_sel = SLL;
			4'b0010 : alu_sel = SLT;
			4'b0011 : alu_sel = SLTU;
			4'b0100 : alu_sel = XOR;
			4'b0101 : alu_sel = SRL;
			4'b1101 : alu_sel = SRA;
			4'b0110 : alu_sel = OR;
			4'b0111 : alu_sel = AND;
			default : alu_sel = ADD;
		endcase
		
		//hazard detection
		if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_a)) begin //rs1 needs rd from last arith op
			af_a_sel = 3'd0;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_a)) begin //rs1 needs rd from last mem op
			af_a_sel = 3'd1;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 arith ops ago
			af_a_sel = 3'd2;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 mem ops ago
			af_a_sel = 3'd3;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_a)) begin //rs1 needs rd from 1 pc ops ago
			af_a_sel = 3'd4;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 pc ops ago
			af_a_sel = 3'd5;
			op_a_sel = 1'b1;
		end else begin
			af_a_sel = 3'd0;
			op_a_sel = 1'b0;
		end
		
		if ((rs2 != 5'd0) && ({2'b0, rs2} == haz_flg_a)) begin //rs2 needs rd from last arith op
			af_b_sel = 3'd0;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b01, rs2} == haz_flg_a)) begin //rs2 needs rd from last mem op
			af_b_sel = 3'd1;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b0, rs2} == haz_flg_b)) begin //rs2 needs rd from 2 arith ops ago
			af_b_sel = 3'd2;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b01, rs2} == haz_flg_b)) begin //rs2 needs rd from 2 mem ops ago
			af_b_sel = 3'd3;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b10, rs2} == haz_flg_a)) begin //rs2 needs rd from 1 pc ops ago
			af_b_sel = 3'd4;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b10, rs2} == haz_flg_b)) begin //rs2 needs rd from 2 pc ops ago
			af_b_sel = 3'd5;
			op_b_sel = 1'b1;
		end else begin
			af_b_sel = 3'd0;
			op_b_sel = 1'b0;
		end
		
		mf_sel = 'b0;
		
		flush = 'b0;
		stall = 'b0; //may need later
			
	end
	TYPE_I : begin //-------------------------------------TYPE_I-----------------------------------------------------------//
	
		//basic controls
		imm = {{20{inst_word[31]}}, inst_word[31:20]};
		rs1 = inst_word[19:15];
		rs2 = 'b0;
		rd = inst_word[11:7];
		b_type = '0;
		ipd_mux_sel = '0;
		ld_type = '0;
		ld_opdr = '0;
		ld_ipdr = '0;
		d_wren = '0;
		p_wren ='0;
		ld_pc = '0;
		pc_wb = pc_out;
		wb_mux_sel = '0;
		ld_rd = 1'b1;
		haz_flg_z = (rd != 5'd0) ? {1'b0, inst_word[11:7]} : '0;
		
		//alu_sel
		case (inst_word[14:12])
			3'b000 : alu_sel = ADDI_LD_JALR_ST_LUI;
			3'b001 : alu_sel = SLLI;
			3'b010 : alu_sel = SLTI;
			3'b011 : alu_sel = SLTIU;
			3'b100 : alu_sel = XORI;
			3'b110 : alu_sel = ORI;
			3'b111 : alu_sel = ANDI;
			default : begin
				case ({inst_word[30], inst_word[14:12]})
					4'b0101 : alu_sel = SRLI;
					4'b1101 : alu_sel = SRAI;
					default : alu_sel = ADD;
				endcase
			end
		endcase

		//hazard detection
		if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_a)) begin //rs1 needs rd from last arith op
			af_a_sel = 3'd0;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_a)) begin //rs1 needs rd from last mem op
			af_a_sel = 3'd1;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 arith ops ago
			af_a_sel = 3'd2;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 mem ops ago
			af_a_sel = 3'd3;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_a)) begin //rs1 needs rd from 1 pc ops ago
			af_a_sel = 3'd4;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 pc ops ago
			af_a_sel = 3'd5;
			op_a_sel = 1'b1;
		end else begin
			af_a_sel = 3'd0;
			op_a_sel = 1'b0;
		end
		
		af_b_sel = 2'b00;
		op_b_sel = 1'b0;
		mf_sel = 'b0;
		
		flush = 'b0;
		stall = 'b0; //may need later
	
	end
	TYPE_L : begin //------------------------------------TYPE_LD-----------------------------------------------------------//
	
		//basic controls
		imm = {{20{inst_word[31]}},inst_word[31:20]};
		rs1 = inst_word[19:15];
		rs2 = 'b0;
		rd = inst_word[11:7];
		b_type = '0;
		ipd_mux_sel = 'd1; // tie it with addresses outside the range of onboard memory 
		ld_opdr = '0;
		ld_ipdr = 'd1; // tie it with addresses outside the range of onboard memory
		d_wren = '0;
		p_wren ='0;
		ld_pc = '0;
		pc_wb = pc_out;
		wb_mux_sel = 2'b01;
		ld_rd = 1'b1;
		haz_flg_z = (rd != 5'd0) ? {1'b1, inst_word[11:7]} : '0;
		
		//Bit Mask logic ld type
		case (inst_word[14:12])
			3'b000 : ld_type = LB;
			3'b001 : ld_type = LH;
			3'b010 : ld_type = LW;
			3'b100 : ld_type = LBU;
			3'b101 : ld_type = LHU;
			default : ld_type = '0;
		endcase
		
		//alu_sel
		alu_sel = ADDI_LD_JALR_ST_LUI;
		
		//hazard detection
		if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_a)) begin //rs1 needs rd from last arith op
			af_a_sel = 3'd0;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_a)) begin //rs1 needs rd from last mem op
			af_a_sel = 3'd1;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 arith ops ago
			af_a_sel = 3'd2;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 mem ops ago
			af_a_sel = 3'd3;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_a)) begin //rs1 needs rd from 1 pc ops ago
			af_a_sel = 3'd4;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 pc ops ago
			af_a_sel = 3'd5;
			op_a_sel = 1'b1;
		end else begin
			af_a_sel = 3'd0;
			op_a_sel = 1'b0;
		end
			
		af_b_sel = 2'b00;
		op_b_sel = 1'b0;
		mf_sel = 'b0;
		
		flush = 'b0;
		stall = 'b0; //may need later
	
	end
	TYPE_JR : begin //-----------------------------------TYPE_JR-----------------------------------------------------------//
	
	//basic controls
		imm = {{20{inst_word[31]}},inst_word[31:20]};
		rs1 = inst_word[19:15];
		rs2 = '0;
		rd = inst_word[11:7];
		b_type = '0;
		ipd_mux_sel = '0;
		ld_type = '0;
		ld_opdr = '0;
		ld_ipdr = '0;
		d_wren = '0;
		p_wren ='0;
		ld_pc = 1'b1;
		pc_wb = pc_out;
		wb_mux_sel = 2'd2;
		ld_rd = 1'b1;
		haz_flg_z = (rd != 5'd0) ? {1'b0, inst_word[11:7]} : '0;
		
		//alu_sel
		alu_sel = ADDI_LD_JALR_ST_LUI;
		
		//hazard detection
		if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_a)) begin //rs1 needs rd from last arith op
			af_a_sel = 3'd0;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_a)) begin //rs1 needs rd from last mem op
			af_a_sel = 3'd1;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 arith ops ago
			af_a_sel = 3'd2;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 mem ops ago
			af_a_sel = 3'd3;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_a)) begin //rs1 needs rd from 1 pc ops ago
			af_a_sel = 3'd4;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 pc ops ago
			af_a_sel = 3'd5;
			op_a_sel = 1'b1;
		end else begin
			af_a_sel = 3'd0;
			op_a_sel = 1'b0;
		end

		af_b_sel = 2'b00;
		op_b_sel = 1'b0;
		
		mf_sel = 3'd4; //either 4 or 5?
		
		flush = 'b1;
		stall = 'b0; //may need later
			
	
	end
	TYPE_S : begin //-------------------------------------TYPE_S-----------------------------------------------------------//
	
	//basic controls
		imm = {{20{inst_word[31]}}, inst_word[31:25], inst_word[11:7]};
		rs1 = inst_word[19:15];
		rs2 = inst_word[24:20];
		rd = '0;
		b_type = '0;
		ipd_mux_sel = '0;
		
		//used for the byteena
		case (inst_word[14:12])
			3'b000 : ld_type = LB;
			3'b001 : ld_type = LH;
			3'b010 : ld_type = LW;
			default : ld_type = '0;
		endcase
		
		ld_opdr = 'd1;
		ld_ipdr = '0;
		d_wren = 'd1;
		p_wren ='0;
		ld_pc = '0;
		pc_wb = pc_out;
		wb_mux_sel = '0;
		ld_rd = 1'b0;
		haz_flg_z = 7'b1000000; 
		
		//alu_sel
		alu_sel = ADDI_LD_JALR_ST_LUI;
		
		//hazard detection
		if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_a)) begin //rs1 needs rd from last arith op
			af_a_sel = 3'd0;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_a)) begin //rs1 needs rd from last mem op
			af_a_sel = 3'd1;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 arith ops ago
			af_a_sel = 3'd2;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 mem ops ago
			af_a_sel = 3'd3;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_a)) begin //rs1 needs rd from 1 pc ops ago
			af_a_sel = 3'd4;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 pc ops ago
			af_a_sel = 3'd5;
			op_a_sel = 1'b1;
		end else begin
			af_a_sel = 3'd0;
			op_a_sel = 1'b0;
		end
		
// THIS WILL NEED TESTING // TEST CONSECUTIVE LD, ST; ADD, ST; LD, NOP, ST; //
		if ((rs2 != 5'd0) && ({2'd0, rs2} == haz_flg_a)) begin //rs2 needs rd from last arith op
			mf_sel = 3'd2;
		end else if ((rs2 != 5'd0) && ({2'd1, rs2} == haz_flg_a)) begin //rs2 needs rd from last mem op***
			mf_sel = 3'd3;
		end else if ((rs2 != 5'd0) && ({2'b0, rs2} == haz_flg_b)) begin //rs2 needs rd from 2 arith ops ago
			mf_sel = 3'd7;// 
		end else if ((rs2 != 5'd0) && ({2'd1, rs2} == haz_flg_b)) begin //rs2 needs rd from 2 mem ops ago
			mf_sel = 3'd3;
		end else if ((rs2 != 5'd0) && ({2'd2, rs2} == haz_flg_a)) begin //rs2 needs rd from last PC op
			mf_sel = 3'd5;
		end else if ((rs2 != 5'd0) && ({2'd2, rs2} == haz_flg_b)) begin //rs2 needs rd from 2 PC ops ago
			mf_sel = 3'd6;
		end else begin
			mf_sel = 3'b0;
		end
		
		
		af_b_sel = 2'b00;
		op_b_sel = 1'b0;
		
		flush = 'b0;
		stall = 'b0; //may need later
		
	end
	TYPE_B : begin //-------------------------------------TYPE_B-----------------------------------------------------------//
	
	//basic controls
		imm = {{20{inst_word[31]}}, inst_word[7], inst_word[30:25], inst_word[11:8], 1'b0};
		rs1 = inst_word[19:15];
		rs2 = inst_word[24:20];
		rd = 'b0;
		//b_type moved with alu_sel
		ipd_mux_sel = '0;
		ld_type = '0;
		ld_opdr = '0;
		ld_ipdr = '0;
		d_wren = '0;
		p_wren ='0;
		ld_pc = '0; //Supplement with b_check_held
		pc_wb = pc_out;
		wb_mux_sel = '0;
		ld_rd = 1'b0;
		haz_flg_z = '0;
		
		//alu_sel, also does b_type
		case (inst_word[14:12])
			3'b000 : begin
				alu_sel = BEQ_BNE;
				b_type = BEQ;
			end
			3'b001 : begin
				alu_sel = BEQ_BNE;
				b_type = BNE;
			end
			3'b100 : begin
				alu_sel = BLT_BGE;
				b_type = BLT;
			end
			3'b101 : begin
				alu_sel = BLT_BGE;
				b_type = BGE;
			end
			3'b110 : begin
				alu_sel = BLTU_BGEU;
				b_type = BLTU;
			end
			3'b111 : begin
				alu_sel = BLTU_BGEU;
				b_type = BGEU;
			end
			default : begin
				alu_sel = ADD;
				b_type = NOT_B;
			end
		endcase

		
		//hazard detection
		if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_a)) begin //rs1 needs rd from last arith op
			af_a_sel = 3'd0;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_a)) begin //rs1 needs rd from last mem op
			af_a_sel = 3'd1;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b0, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 arith ops ago
			af_a_sel = 3'd2;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b01, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 mem ops ago
			af_a_sel = 3'd3;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_a)) begin //rs1 needs rd from 1 pc ops ago
			af_a_sel = 3'd4;
			op_a_sel = 1'b1;
		end else if ((rs1 != 5'd0) && ({2'b10, rs1} == haz_flg_b)) begin //rs1 needs rd from 2 pc ops ago
			af_a_sel = 3'd5;
			op_a_sel = 1'b1;
		end else begin
			af_a_sel = 3'd0;
			op_a_sel = 1'b0;
		end
		
		if ((rs2 != 5'd0) && ({2'b0, rs2} == haz_flg_a)) begin //rs2 needs rd from last arith op
			af_b_sel = 3'd0;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b01, rs2} == haz_flg_a)) begin //rs2 needs rd from last mem op
			af_b_sel = 3'd1;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b0, rs2} == haz_flg_b)) begin //rs2 needs rd from 2 arith ops ago
			af_b_sel = 3'd2;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b01, rs2} == haz_flg_b)) begin //rs2 needs rd from 2 mem ops ago
			af_b_sel = 3'd3;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b10, rs2} == haz_flg_a)) begin //rs2 needs rd from 1 pc ops ago
			af_b_sel = 3'd4;
			op_b_sel = 1'b1;
		end else if ((rs2 != 5'd0) && ({2'b10, rs2} == haz_flg_b)) begin //rs2 needs rd from 2 pc ops ago
			af_b_sel = 3'd5;
			op_b_sel = 1'b1;
		end else begin
			af_b_sel = 3'd0;
			op_b_sel = 1'b0;
		end
		
		mf_sel = 'd4; //probably 4 not 5?
		
		flush = 'b0; //Supplement with b_taken_held
		stall = 'b0; //may need later
		
	end
	TYPE_UI : begin //-----------------------------------TYPE_UI-----------------------------------------------------------//
		
		//basic controls
		imm = {inst_word[31:12], 12'b0};
		rs1 = '0;
		rs2 = '0;
		rd = inst_word[11:7];
		b_type = '0;
		ipd_mux_sel = '0;
		ld_type = '0;
		ld_opdr = '0;
		ld_ipdr = '0;
		d_wren = '0;
		p_wren ='0;
		ld_pc = '0;
		pc_wb = pc_out;
		wb_mux_sel = '0;
		ld_rd = 1'b1;
		haz_flg_z = (rd != 5'd0) ? {1'b0, inst_word[11:7]} : '0;
		
		//alu_sel
		alu_sel = ADDI_LD_JALR_ST_LUI;
		
		//Shouldn't need hazard detection at all
		af_a_sel = 2'b00;
		op_a_sel = 1'b0;
		af_b_sel = 2'b00;
		op_b_sel = 1'b0;
		mf_sel = 'b0;
		
		flush = 'b0;
		stall = 'b0; //may need later
	
	end
	TYPE_UPC : begin //---------------------------------TYPE_UPC-----------------------------------------------------------//
	
	//basic controls
		imm = {inst_word[31:12], 12'b0};
		rs1 = '0;
		rs2 = '0;
		rd = inst_word[11:7];
		b_type = '0;
		ipd_mux_sel = '0;
		ld_type = '0;
		ld_opdr = '0;
		ld_ipdr = '0;
		d_wren = '0;
		p_wren ='0;
		ld_pc = '0;
		pc_wb = pc_out;
		wb_mux_sel = '0;
		ld_rd = 1'b1;
		haz_flg_z = (rd != 5'd0) ? {1'b0, inst_word[11:7]} : '0;
		
		//alu_sel
		alu_sel = AUIPC_JAL;
		
		//Shouldn't need hazard detection at all
		af_a_sel = 2'b00;
		op_a_sel = 1'b0;
		af_b_sel = 2'b00;
		op_b_sel = 1'b0;
		mf_sel = 'b0;
		
		flush = 'b0;
		stall = 'b0; //may need later
	
	end
	TYPE_J : begin //-------------------------------------TYPE_J-----------------------------------------------------------//

	//basic controls
		imm = {{12{inst_word[31]}}, inst_word[19:12], inst_word[20], inst_word[30:21], 1'b0};
		rs1 = '0;
		rs2 = '0;
		rd = inst_word[11:7];
		b_type = '0;
		ipd_mux_sel = '0;
		ld_type = '0;
		ld_opdr = '0;
		ld_ipdr = '0;
		d_wren = '0;
		p_wren ='0;
		ld_pc = '1; //make sure this doesn't break with cond branches
		pc_wb = pc_out;
		wb_mux_sel = 2'd2;
		ld_rd = 1'b1;
		haz_flg_z = (rd != 5'd0) ? {1'b0, inst_word[11:7]} : '0;
		
		//alu_sel
		alu_sel = AUIPC_JAL;
		
		//Shouldn't need hazard detection at all
		af_a_sel = 2'b00;
		op_a_sel = 1'b0;
		af_b_sel = 2'b00;
		op_b_sel = 1'b0;
		mf_sel = 3'd4;
		
		flush = 'b1;
		stall = 'b0; //may need later
	
	end
	default : begin //-------------------------------------DEFAULT----------------------------------------------------------//
	
	//basic controls
		imm = '0;
		rs1 = '0;
		rs2 = '0;
		rd = '0;
		b_type = '0;
		ipd_mux_sel = '0;
		ld_type = '0;
		ld_opdr = '0;
		ld_ipdr = '0;
		d_wren = '0;
		p_wren ='0;
		ld_pc = '0;
		pc_wb = pc_out;
		wb_mux_sel = '0;
		ld_rd = '0;
		haz_flg_z = (rd != 5'd0) ? {1'b0, inst_word[11:7]} : '0;
		
		//alu_sel
		alu_sel = ADD;
		
		//hazard detection

		af_a_sel = 2'b00;
		op_a_sel = 1'b0;
		af_b_sel = 2'b00;
		op_b_sel = 1'b0;
		mf_sel = 'b0;
		
		flush = 'b0;
		stall = 'b0; //may need later
		
		invalid_iw = 1'b1;
	
	end
endcase

//cu_code = {imm, rs1, rs2, op_a_sel, op_b_sel, alu_sel, b_type, af_a_sel, af_b_sel, 
//				mf_sel, ipd_mux_sel, ld_type, ld_opdr, ld_ipdr, d_wren, p_wren, ld_pc, 
//				pc_wb, wb_mux_sel, ld_rd, rd, 
//				flush, stall, invalid_iw};
				
cu_code = {invalid_iw, rd, ld_rd, wb_mux_sel, pc_wb, stall, flush, ld_pc, p_wren, d_wren,
				ld_ipdr, ld_opdr, ld_type, ipd_mux_sel, mf_sel, af_b_sel, af_a_sel, b_type, alu_sel, op_b_sel, op_a_sel, rs2, rs1, imm};
				
end
endmodule



