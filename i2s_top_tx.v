`include "bus_cnt_width.v"

module i2s_top_tx
(
	clk_i,
	rst_i,
	
	data_i,
	lr_chnl_o,
	write_o,
	
	sclk_i,
	wsel_i,
	sdat_o
);

parameter WORD_WIDTH = 16;
localparam CNT_WIDTH = `CLOG2(WORD_WIDTH);

input clk_i;
input rst_i;
input [WORD_WIDTH-1:0] data_i;
output lr_chnl_o;
output write_o;
input sclk_i;
input wsel_i;
output sdat_o;

wire sclk_negedge;
wire wsel_edge;
wire wsel_sync;

reg [CNT_WIDTH-1:0] bit_cnt;
reg [WORD_WIDTH-1:0] shift_reg;

signal_sync sync_sclk
(
    .clk_i(clk_i), 
    .rst_i(rst_i), 
    .signal_i(sclk_i), 
    .signal_o(), 
    .valid_o(),
	.edge_o(),
    .posedge_o(), 
    .negedge_o(sclk_negedge)
);

signal_sync wsel_sclk
(
    .clk_i(clk_i), 
    .rst_i(rst_i), 
    .signal_i(wsel_i), 
    .signal_o(wsel_sync), 
    .valid_o(),
	.edge_o(wsel_edge),
    .posedge_o(), 
    .negedge_o()
);

assign write_o = (bit_cnt == 0) && sclk_negedge;
assign sdat_o = shift_reg[WORD_WIDTH-1];
assign lr_chnl_o = wsel_sync;

always @ (posedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		bit_cnt <= 0;
	end
	else begin
		if (wsel_edge) begin
			bit_cnt <= 0;
		end
		else if (sclk_negedge) begin
			bit_cnt <= bit_cnt - 1;
		end
	end
end

always @ (posedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		shift_reg <= 0;
	end
	else begin
		if (write_o) begin
			shift_reg <= data_i;
		end
		else if (sclk_negedge) begin
			shift_reg <= {shift_reg[WORD_WIDTH-2:0], 1'b0};
		end
	end
end

endmodule
