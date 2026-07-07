/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Baseline Modelsim-altera Test Bench
	Created by: Stephen Meyer (7/07/2026)
	
	Copyright (C) 2026 Stephen Meyer

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module sfm_riscv_testbench_sv;

	localparam WIDTH = 32;
	logic clk_tb, rst_tb;
	logic [WIDTH-1:0] OPD_tb;
	
sfm_riscv_core_sv # (.WIDTH(WIDTH)) dut (.clk(clk_tb), .rst(rst_tb), .OPD(OPD_tb));

initial begin

	localparam time period = 10ns;
	
//reset period
	for (int i = 0; i <= 2; i++) begin
        rst_tb = 1'b1; clk_tb = 1'b0; OPD_tb = 32'd0;
        #period;
		  clk_tb = 1'b1;
		  #period;
    end
//post reset period

    for (int i = 0; i <= 1000; i++) begin
        rst_tb = 1'b0; clk_tb = 1'b0; OPD_tb = 32'd0;
        #period;
		  clk_tb = 1'b1;
		  $display("[Time %0t] Loop: %0d | PC: 0x%0h | IR: 0x%0h", 
             $time, i, dut.DataPath.PCout, dut.DataPath.IW);
		  #period;
    end
end
endmodule
