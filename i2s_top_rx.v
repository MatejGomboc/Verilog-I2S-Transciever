module i2s_top_rx
(
	clk_i,
	rst_i,
	
	data_o,
	lr_chnl_o,
	write_o,
	
	sclk_o,
	wsel_o,
	sdat_i
);

input clk_i;
input rst_i;
output [15:0] data_o;
output lr_chnl_o;
output write_o;
output sclk_o;
output wsel_o;
input sdat_i;

reg [3:0] bit_cnt;
reg lr_word;
reg [15:0] shift_reg;
reg lr_channel;

assign sclk_o = clk_i;
assign wsel_o = lr_word;
assign lr_chnl_o = lr_channel;
assign write_o = (bit_cnt[0] == 1'b1) && (bit_cnt[3:1] == 3'b000);
assign data_o = shift_reg;

always @ (negedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		lr_word <= 1'b0;
	end
	else if (write_o) begin
		lr_word <= ~lr_word;
	end
end

always @ (negedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		bit_cnt <= 4'b0000;
	end
	else begin
		bit_cnt <= bit_cnt - 1;
	end
end

always @ (posedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		shift_reg <= 16'h0000;
	end
	else begin
		shift_reg <= {shift_reg[14:0], sdat_i};
	end
end

always @ (negedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		lr_channel <= 1'b0;
	end
	else begin
		lr_channel <= lr_word;
	end
end

endmodule
