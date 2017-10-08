`include "bus_cnt_width.v"

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

parameter WORD_WIDTH = 16;
localparam CNT_WIDTH = `CLOG2(WORD_WIDTH);

input clk_i;
input rst_i;
output [WORD_WIDTH-1:0] data_o;
output lr_chnl_o;
output write_o;
output sclk_o;
output wsel_o;
input sdat_i;

reg first_bit;
reg [CNT_WIDTH-1:0] bit_cnt;
reg lr_word;
reg [WORD_WIDTH-1:0] shift_reg;
reg lr_channel;

assign sclk_o = clk_i;
assign wsel_o = lr_word;
assign lr_chnl_o = lr_channel;
assign write_o = (bit_cnt == 0) && (!first_bit);
assign data_o = shift_reg;

always @ (negedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		first_bit <= 1'b1;
	end
	else begin
		first_bit <= 1'b0;
	end
end

always @ (negedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		lr_word <= 1'b0;
	end
	else if ((bit_cnt[0] == 1'b1) && (bit_cnt[CNT_WIDTH-1:1] == 0)) begin
		lr_word <= ~lr_word;
	end
end

always @ (negedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		bit_cnt <= 0;
	end
	else begin
		bit_cnt <= bit_cnt - 1;
	end
end

always @ (posedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		shift_reg <= 0;
	end
	else begin
		shift_reg <= {shift_reg[WORD_WIDTH-2:0], sdat_i};
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
