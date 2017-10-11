`timescale 1ns / 100ps

module test_i2s_top_trx;

	localparam RST_DURATION = 50; //ns
	localparam CLKT_PERIOD = 10; //ns
	localparam CLKR_PERIOD = 100; //ns
	
	localparam STIMULUS_DATA_COUNT = 10;

	// Inputs
	reg clk_i_t;
	reg clk_i_r;
	reg rst_i;
	reg [15:0] data_i_t;
	
	// Inouts
	wire sclk;
	wire wsel;
	wire sdat;

	// Outputs
	wire [15:0] data_o_r;
	wire lr_chnl_o_t;
	wire write_o_t;
	wire lr_chnl_o_r;
	wire write_o_r;
	
	// Received data
	reg [15:0] data_rx [0:1];
	
	// Transmitted data
	reg [15:0] data_tx [0:STIMULUS_DATA_COUNT-1];
	integer indx_tx;

	// Instantiate the Unit Under Test (UUT)
	i2s_top_tx uut_t
	(
		.clk_i(clk_i_t), 
		.rst_i(rst_i), 
		.data_i(data_i_t), 
		.lr_chnl_o(lr_chnl_o_t), 
		.write_o(write_o_t), 
		.sclk_i(sclk), 
		.wsel_i(wsel), 
		.sdat_o(sdat)
	);
	defparam uut_t.WORD_WIDTH = 16;
	
	// Instantiate the Unit Under Test (UUT)
	i2s_top_rx uut_r
	(
		.clk_i(clk_i_r), 
		.rst_i(rst_i), 
		.data_o(data_o_r), 
		.lr_chnl_o(lr_chnl_o_r), 
		.write_o(write_o_r), 
		.sclk_o(sclk), 
		.wsel_o(wsel), 
		.sdat_i(sdat)
	);
	defparam uut_r.WORD_WIDTH = 16;

	// Reset pulse generator
	initial begin : reset_generator
		rst_i = 1'b1;
		#(RST_DURATION);
		rst_i = 1'b0;
	end
	
	// Main oscillator TX
	initial begin : clk_generator_tx
		clk_i_t = 1'b0;
		#(RST_DURATION);
		forever begin
			clk_i_t = #(CLKT_PERIOD/2) ~clk_i_t;
		end
	end
	
	// Main oscillator RX
	initial begin : clk_generator_rx
		clk_i_r = 1'b0;
		#(RST_DURATION);
		forever begin
			clk_i_r = #(CLKR_PERIOD/2) ~clk_i_r;
		end
	end
	
	// Parallel transmitter
	always @ (posedge(clk_i_t) or posedge(rst_i)) begin : transmitter
		if (rst_i) begin
			data_i_t = 16'h0000;
			indx_tx = 0;
			read_from_file;
		end
		else begin
			if (write_o_t) begin
				if (indx_tx < STIMULUS_DATA_COUNT) begin
					$display("tx: %h", data_tx[indx_tx]);
					data_i_t = data_tx[indx_tx];
					indx_tx = indx_tx + 1;
				end
				else begin
					$stop;
				end
			end
		end
	end
	
	// Parallel receiver
	always @ (negedge(clk_i_r) or posedge(rst_i)) begin : receiver
		if (rst_i) begin
			data_rx[0] = 16'h0000;
			data_rx[1] = 16'h0000;
		end
		else begin
			if (write_o_r) begin
				$display("rx:     %h", data_o_r);
				if (lr_chnl_o_r) begin
					data_rx[1] = data_o_r;
				end
				else begin
					data_rx[0] = data_o_r;
				end
			end
		end
	end
	
	task read_from_file;
		integer stimulus_file;
	begin
		stimulus_file = $fopen("stimulus/stimulus.txt", "r");
		if (stimulus_file == 0) $finish;
		if ($fscanf(stimulus_file, "%b", data_tx) == 0) $finish;
	end
	endtask;
      
endmodule
