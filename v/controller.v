module controller(input reset_b,
		  input clk,
		  input dut_run,
		  input[15:0] input_mdr,
		  output reg busy, output_write_en,
		  output reg[11:0] weight_mar, input_mar, output_mar,
		  output reg[15:0] dim
		 );

reg[2:0] current_state;
reg[2:0] next_state;
reg[3:0] conv_count;
reg conv_count_in;

parameter Size10x10 = 2'b00;
parameter Size12x12 = 2'b01;
parameter Size16x16 = 2'b10;

reg[15:0] dim_in;
reg[15:0] input_mar_in;
reg[15:0] output_mar_in;
reg reset_conv_count;

//state encodings
parameter [2:0]
	RESTING = 3'b000,
	SU1 = 3'b001,
	SU2 = 3'b010,
	SU3 = 3'b011,
	SU4 = 3'b100,
	CONV_RUNNING = 3'b101;

//register the new dimension when input_mar is at the right location
always@(posedge clk)
	if(current_state == SU1) dim <= input_mdr;

always@(posedge clk or negedge reset_b)
	if(!reset_b) current_state <= RESTING;
	else current_state <= next_state;

//register input MAR
always@(posedge clk or negedge reset_b)
	if(!reset_b) input_mar <= 12'h0;
	else input_mar <= input_mar_in;

//register convolution count
always@(posedge clk or negedge reset_b)
	if(!reset_b) conv_count <= 4'b0;
	else conv_count <= reset_conv_count ? 4'b0 : conv_count + conv_count_in;

//register output MAR
always@(posedge clk or negedge reset_b)
	if(!reset_b) output_mar <= 12'b0;
	else output_mar <= output_mar_in;

always@(current_state or dut_run or conv_count)
begin
busy = 1'b1;
output_write_en = 1'b0;
output_mar_in = 0;
input_mar_in = 0;
conv_count_in = 0;
reset_conv_count = 0;
weight_mar = 12'h01;
case(current_state)
RESTING:
	begin
	input_mar_in = 0;
	reset_conv_count = 1;
	busy = 1'b0;
	if(dut_run) begin
		next_state = SU1;
		input_mar_in = 2;
	end
	else next_state = RESTING;
	end
SU1:
	begin
	input_mar_in = input_mar+1;
	output_mar_in = output_mar;
	if(input_mdr == 16'h00) next_state = RESTING;
	else next_state = SU2;
	end
SU2: begin
	input_mar_in = input_mar+1;
	output_mar_in = output_mar;
	next_state = SU3;
    end
SU3: begin
	input_mar_in = input_mar+1;
	output_mar_in = output_mar;
	next_state = SU4;
    end
SU4: begin
	input_mar_in = input_mar+1;
	output_mar_in = output_mar;
	next_state = CONV_RUNNING;
    end
CONV_RUNNING: begin
	input_mar_in = input_mar+1;
	output_mar_in = output_mar+1;
	output_write_en = 1;
	if(conv_count < dim - 3) begin
		conv_count_in = 1;
		next_state = CONV_RUNNING;
	end
	else begin
		reset_conv_count = 1;
		conv_count_in = 0;
		next_state = SU1;
	end
    end
default: next_state = RESTING;
endcase
end

endmodule
