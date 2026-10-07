module sfm_fpga_emulation_sv (input logic CLOCK_50, input logic [1:0] pb, input logic [3:0] sw, output logic [7:0] leds);

logic [31:0] opd_out;
logic [4:0] div;
   always_ff @(posedge CLOCK_50) div <= div + 1'b1;

sfm_riscv_core_sv dut (.clk(div[4]), .rst_n(pb[0]), .ipd({28'd0, sw}), .opd(opd_out));

assign leds = opd_out[7:0];

endmodule
