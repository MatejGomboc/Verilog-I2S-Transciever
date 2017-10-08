module signal_sync
(
	clk_i,
	rst_i,
	signal_i,
	signal_o,
	valid_o,
	edge_o,
	posedge_o,
	negedge_o
);

input clk_i;
input rst_i;
input signal_i;
output signal_o;
output valid_o;
output edge_o;
output posedge_o;
output negedge_o;

reg stage0;
reg stage1;
reg stage2;

assign valid_o = (stage0 == stage1);
assign edge_o = (stage1 != stage2) && valid_o;
assign posedge_o = (stage1 && !stage2) && valid_o;
assign negedge_o = (!stage1 && stage2) && valid_o;
assign signal_o = stage1;

always @ (posedge(clk_i) or posedge(rst_i)) begin
	if (rst_i) begin
		stage0 <= 0;
		stage1 <= 0;
		stage2 <= 0;
	end
	else begin
		stage0 <= signal_i;
		stage1 <= stage0;
		if (valid_o) begin
			stage2 <= stage1;
		end
	end
end

endmodule
