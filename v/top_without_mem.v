`include "controller.v"
`include "pipelined_conv.v"

module top_without_mem(input dut_run, reset_b, clk,
		       output dut_busy,
		       input[15:0] sram_dut_read_data, wmem_dut_read_data,
		       output[15:0] dut_sram_write_data, 
		       output[11:0] dut_sram_write_address, dut_sram_read_address,
		       output[11:0] dut_wmem_read_address, output dut_sram_write_enable
			);

wire[15:0] dim;
wire[13:0] conv_out;

controller u1(.reset_b(reset_b), .clk(clk), .dut_run(dut_run),
		.input_mdr(sram_dut_read_data), .busy(dut_busy),
		.weight_mar(dut_wmem_read_address),
		.input_mar(dut_sram_read_address),
		.output_mar(dut_sram_write_address),
		.dim(dim),
		.output_write_en(dut_sram_write_enable));

pipelined_conv u2(.input_row(sram_dut_read_data), .weights(wmem_dut_read_data[8:0]),
		 .dim(dim), .clk(clk), .conv_out(conv_out));

//conv_out is a 14 bit signal, needs to be padded by 2 for output
assign dut_sram_write_data = {2'b0, conv_out};

endmodule
