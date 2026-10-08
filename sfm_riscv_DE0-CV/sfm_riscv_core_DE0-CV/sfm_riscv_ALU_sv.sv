/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//												  32-Bit Arithmetic Logic Unit RISCV File													        //
//													Created by: Stephen Meyer (6/1/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_ALU_sv # (parameter int WIDTH = 32, parameter int ALU_SEL_WIDTH = 5)
								(input logic [WIDTH-1:0] pc_out, op_a, imm, op_b, input logic [ALU_SEL_WIDTH-1:0] alu_sel, output logic [WIDTH-1:0] alu_res, output logic b_check);

////////////////////////////////////////////////////////OPCODE NAMES////////////////////////////////////////////////////////

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

always_comb begin

	b_check = '0;
	
	case (alu_sel)
		ADD : begin
			alu_res = WIDTH'(op_a + op_b);
		end
		SUB : begin
			alu_res = WIDTH'(op_a - op_b);
		end
		SLL : begin
			alu_res = WIDTH'(op_a << op_b[4:0]);
		end
		SLT : begin
			alu_res = ($signed(op_a) < $signed(op_b)) ? WIDTH'(1) : WIDTH'(0);
		end
		SLTU : begin
			alu_res = ($unsigned(op_a) < $unsigned(op_b)) ? WIDTH'(1) : WIDTH'(0);
		end
		XOR : begin
			alu_res = WIDTH'(op_a ^ op_b);
		end
		SRL : begin
			alu_res = WIDTH'(op_a >> op_b[4:0]);
		end
		SRA : begin
			alu_res = WIDTH'($signed(op_a) >>> op_b[4:0]);
		end
		OR : begin
			alu_res = WIDTH'(op_a | op_b);
		end
		AND : begin
			alu_res = WIDTH'(op_a & op_b);
		end
		
		ADDI_LD_JALR_ST_LUI : begin
			alu_res = WIDTH'(op_a + $signed(imm));
		end
		SLTI : begin
			alu_res = ($signed(op_a) < $signed(imm)) ? WIDTH'(1) : WIDTH'(0);
		end
		SLTIU : begin
			alu_res = ($unsigned(op_a) < $unsigned(imm)) ? WIDTH'(1) : WIDTH'(0);
		end
		XORI : begin
			alu_res = WIDTH'(op_a ^ imm);
		end
		ORI : begin
			alu_res = WIDTH'(op_a | imm);
		end
		ANDI : begin
			alu_res = WIDTH'(op_a & imm);
		end
		SLLI : begin
			alu_res = WIDTH'(op_a << imm[4:0]);
		end
		SRLI : begin
			alu_res = WIDTH'(op_a >> imm[4:0]);
		end
		SRAI : begin
			alu_res = WIDTH'($signed(op_a) >>> imm[4:0]);
		end
		
		BEQ_BNE : begin
			b_check = (op_a - op_b) ? '0 : '1;
			alu_res = WIDTH'(pc_out + imm);
		end
		BLT_BGE : begin
			b_check = ($signed(op_a) < $signed(op_b)) ? '1 : '0;
			alu_res = WIDTH'(pc_out + imm);
		end
		BLTU_BGEU : begin
			b_check = ($unsigned(op_a) < $unsigned(op_b)) ? '1 : '0;
			alu_res = WIDTH'(pc_out + imm);
		end
		AUIPC_JAL : begin
			alu_res = WIDTH'(pc_out + imm);
		end
		default : begin
			alu_res = WIDTH'(0);
		end
	endcase
end


endmodule
