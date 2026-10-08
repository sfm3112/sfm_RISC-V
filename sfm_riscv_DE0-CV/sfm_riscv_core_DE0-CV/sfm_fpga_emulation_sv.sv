module sfm_fpga_emulation_sv (input logic CLOCK_50, input logic [4:0] pb, input logic [9:0] sw, output logic [9:0] leds, output logic [41:0] seven_seg_leds);

logic [31:0] opd_out;
logic [4:0] div;
logic [3:0] BCD_100_000, BCD_10_000, BCD_1_000, BCD_100, BCD_10, BCD_1;

always_ff @(posedge CLOCK_50) div <= div + 1'b1;

	sfm_riscv_core_sv dut (.clk(div[4]), .rst_n(pb[4]), .ipd({18'd0, pb[3:0], sw}), .opd(opd_out));

	sfm_bin_to_7_seg_disp_sv bin_to_bcd ( .rst_n(pb[4]), .clk(div[4]), .binary(opd_out[19:0]), .hundreds_thousands(BCD_100_000), .tens_thousands(BCD_10_000), .thousands(BCD_1_000), .hundreds(BCD_100), .tens(BCD_10), .ones(BCD_1));
	sfm_bcd_to_seven_seg_str_sv bcd_to_sevseg (.bcd_string({BCD_100_000, BCD_10_000, BCD_1_000, BCD_100, BCD_10, BCD_1}), .seven_seg_string(seven_seg_leds));

assign leds = opd_out[9:0];

endmodule
