/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//												N-Bit Register with load and reset RISCV File													  //
//													Created by: Stephen Meyer (6/1/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_NbitReg_ld_rst_sv # (parameter int WIDTH = 32)(input logic [WIDTH-1:0]d, input logic clk, ld, rst_n, output logic [WIDTH-1:0]q);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n) begin	//activates on either rising edge of clock cycle or reset signal (reset async)
	if (!rst_n) begin
		q <= '0;												//If reset is high, set it to zero
	end else if (ld) begin
		q <= d;												//If reset is not high, set Q equal to D
	end
end

endmodule
