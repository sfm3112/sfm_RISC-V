/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//													 	Control Code Pipeline Register																  //
//													Created by: Stephen Meyer (8/3/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_Pipeline_Reg_sv # (parameter int PIPELINE_WIDTH = 32)
											(input logic [PIPELINE_WIDTH-1:0]d, input logic clk, flush, rst_n, output logic [PIPELINE_WIDTH-1:0]q);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n) begin	//activates on either rising edge of clock cycle or reset signal (reset async)
	if (!rst_n) begin
		q <= '0;
	end else if (flush) begin
		q <= '0;
	end else begin
		q <= d;
	end
end

endmodule