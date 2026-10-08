/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																																								  //
//														N-Bit Multiplexer RISCV File													              //
//													Created by: Stephen Meyer (6/1/2026)															  //
//																																								  //
//														Copyright (C) 2026 Stephen Meyer																  //
//																																								  //
*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_NbitMux_sv # (parameter int WIDTH = 32, SEL_NUM = 4, SEL_WIDTH = 2)
										(input logic [SEL_NUM-1:0][WIDTH-1:0]mux_input, input logic [SEL_WIDTH-1:0]sel, output logic [WIDTH-1:0]out);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

always_comb begin
	if (sel < SEL_NUM) begin	//Ensures select is valid
		out = mux_input[sel];		//Selects
	end else begin					//If it's not valid
		out = '0;					//Set to 0
	end								//Modules list signals as (n, n-1, ... 1, 0)
end									

endmodule
