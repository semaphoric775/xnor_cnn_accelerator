module conv_single(input[8:0] kernel, input[8:0] window, output act_sign);

reg[8:0] conv_out;
reg[3:0] num_ones;
integer i;

always@(*) begin
	conv_out = kernel ~^ window;
	num_ones = 4'b0;
	for(i = 0; i < 9; i = i + 1)
		num_ones = num_ones + conv_out[i];
end

assign act_sign = (num_ones > 4'd4) ? 1'b1: 1'b0; 

endmodule
