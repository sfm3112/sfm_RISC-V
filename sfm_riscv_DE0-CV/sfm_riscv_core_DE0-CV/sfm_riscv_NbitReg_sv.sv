/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//												 		  N-Bit Register RISCV File															        //
//													Created by: Stephen Meyer (8/6/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_NbitReg_sv # (parameter int WIDTH = 32)(input logic [WIDTH-1:0]d, input logic clk, output logic [WIDTH-1:0]q);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

always_ff @(posedge clk) begin	//activates on either rising edge of clock cycle or reset signal (reset async)
		q <= d;												//If reset is not high, set Q equal to D
end

endmodule
