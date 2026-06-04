/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	N-Bit Register RISCV File
	Created by: Stephen Meyer (6/1/2026)
	
	Copyright (C) 2026 Stephen Meyer

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_NbitReg_sv # (parameter int WIDTH = 32)(input logic [WIDTH-1:0]D, input logic clk, rst, output logic [WIDTH-1:0]Q);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

always_ff @(posedge clk or posedge rst) begin	//activates on either rising edge of clock cycle or reset signal (reset async)
	if (rst) begin
		Q <= '0;												//If reset is high, set it to zero
	end else begin
		Q <= D;												//If reset is not high, set Q equal to D
	end
end

endmodule
