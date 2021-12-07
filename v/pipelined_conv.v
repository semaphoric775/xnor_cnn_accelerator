module pipelined_conv(
	input[15:0] input_row,
	input [8:0] weights,
	input[15:0] dim,
	input clk,
	output[13:0] conv_out);

reg[15:0] R1, R2, R3;
wire[15:0] sign_acts;

//shift registers
always @(posedge clk) begin
	R1 <= input_row;
	R2 <= R1;
	R3 <= R2;
end

//Connect single convolution unit to every 3x3 window
//ideally, a generate block could replace this
//the Design Compiler marked it as not synthesizeable
conv_single u0(.kernel(weights), .window({R1[2:0], R2[2:0], R3[2:0]}), .act_sign(sign_acts[0]));
conv_single u1(.kernel(weights), .window({R1[3:1], R2[3:1], R3[3:1]}), .act_sign(sign_acts[1]));
conv_single u2(.kernel(weights), .window({R1[4:2], R2[4:2], R3[4:2]}), .act_sign(sign_acts[2]));
conv_single u3(.kernel(weights), .window({R1[5:3], R2[5:3], R3[5:3]}), .act_sign(sign_acts[3]));
conv_single u4(.kernel(weights), .window({R1[6:4], R2[6:4], R3[6:4]}), .act_sign(sign_acts[4]));
conv_single u5(.kernel(weights), .window({R1[7:5], R2[7:5], R3[7:5]}), .act_sign(sign_acts[5]));
conv_single u6(.kernel(weights), .window({R1[8:6], R2[8:6], R3[8:6]}), .act_sign(sign_acts[6]));
conv_single u7(.kernel(weights), .window({R1[9:7], R2[9:7], R3[9:7]}), .act_sign(sign_acts[7]));
conv_single u8(.kernel(weights), .window({R1[10:8], R2[10:8], R3[10:8]}), .act_sign(sign_acts[8]));
conv_single u9(.kernel(weights), .window({R1[11:9], R2[11:9], R3[11:9]}), .act_sign(sign_acts[9]));
conv_single u10(.kernel(weights), .window({R1[12:10], R2[12:10], R3[12:10]}), .act_sign(sign_acts[10]));
conv_single u11(.kernel(weights), .window({R1[13:11], R2[13:11], R3[13:11]}), .act_sign(sign_acts[11]));
conv_single u12(.kernel(weights), .window({R1[14:12], R2[14:12], R3[14:12]}), .act_sign(sign_acts[12]));
conv_single u13(.kernel(weights), .window({R1[15:13], R2[15:13], R3[15:13]}), .act_sign(sign_acts[13]));

//mux the single convolution outputs to account for differently sized inputs
assign conv_out = (dim == 16'd10) ?  {6'b0, sign_acts[7:0]} : ((dim == 16'd12) ? {4'b0, sign_acts[9:0]} : sign_acts);

endmodule
