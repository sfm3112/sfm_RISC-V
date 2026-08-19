/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//												  Minimalistic Modelsim-altera Test Bench													        //
//													Created by: Stephen Meyer (7/7/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module sfm_riscv_testbench_sv;

	localparam WIDTH = 32;
	logic clk_tb, rst_n_tb;
	logic [WIDTH-1:0] ipd_tb, opd_tb;
	
sfm_riscv_core_sv # (.WIDTH(WIDTH)) dut (.clk(clk_tb), .rst_n(rst_n_tb), .ipd(ipd_tb), .opd(opd_tb));

initial begin 

	localparam time period = 10ns;
	
//reset period
	for (int i = 0; i <= 2; i++) begin
		rst_n_tb = 1'b0; clk_tb = 1'b0; ipd_tb = 32'd0;
		#period;
		clk_tb = 1'b1;
		#period;
	end
//post reset period

	for (int i = 0; i <= 1000; i++) begin
		rst_n_tb = 1'b1; clk_tb = 1'b0; ipd_tb = 32'h55555555;
		#period;
		clk_tb = 1'b1;
		$display("[Time %0t] Loop: %0d || x0: 0x%0h | x1: 0x%0h | x2: 0x%0h | x3: 0x%0h | x4: 0x%0h || PC: 0x%0h | IR: 0x%0h | cu_code: 0x%0h",
			$time, i, dut.DataPath.x_q[0], dut.DataPath.x_q[1], dut.DataPath.x_q[2], dut.DataPath.x_q[3], dut.DataPath.x_q[4], dut.DataPath.pc_out, dut.DataPath.inst_word, dut.DataPath.cu_code);
		#period;
	end
end
endmodule
