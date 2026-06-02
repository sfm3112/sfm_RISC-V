/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Program Counter RISCV File
	Created by: Stephen Meyer (6/2/2026)

*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sfm_riscv_PC_sv # (parameter int WIDTH = 12)(input logic [WIDTH-1:0]D, input logic ld, rst, cnt, clk, output logic [WIDTH-1:0]Q);

///////////////////////////////////////////////////////INTERNAL LOGIC///////////////////////////////////////////////////////

always_ff @(posedge clk or posedge rst) begin	//activates on either rising edge of clock cycle or reset signal (reset async)
	if (rst) begin
		Q <= '0;												//If reset is high, set it to zero
	end else if (ld) begin
		Q <= D;												//If Load is high, load MAR
	end else if (cnt) begin
		Q <= Q + 1;											//If count is high, increment program counter
	end else begin
		Q <= Q;												//Anything else, hold current program address
	end
end

endmodule
