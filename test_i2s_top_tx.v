`timescale 1ns / 100ps

module test_i2s_top_tx;

	localparam RST_DURATION = 50; //ns
	localparam CLK_PERIOD = 10; //ns
	localparam SCLK_PERIOD = 200; //ns
	
	localparam STIMULUS_DATA_COUNT = 10;

	// Inputs
	reg clk_i;
	reg rst_i;
	reg [15:0] data_i;
	reg sclk_i;
	reg wsel_i;

	// Outputs
	wire lr_chnl_o;
	wire write_o;
	wire sdat_o;
	
	// Received data
	reg [15:0] data_rx [0:1];
	reg indx_rx;
	integer indx_bit_rx;
	
	// Transmitted data
	reg [15:0] data_tx [0:STIMULUS_DATA_COUNT-1];
	integer indx_tx;

	// Instantiate the Unit Under Test (UUT)
	i2s_top_tx uut
	(
		.clk_i(clk_i), 
		.rst_i(rst_i), 
		.data_i(data_i), 
		.lr_chnl_o(lr_chnl_o), 
		.write_o(write_o), 
		.sclk_i(sclk_i), 
		.wsel_i(wsel_i), 
		.sdat_o(sdat_o)
	);
	defparam uut.WORD_WIDTH = 16;

	// Reset pulse generator
	initial begin : reset_generator
		rst_i = 1'b1;
		#(RST_DURATION);
		rst_i = 1'b0;
	end
	
	// Main oscillator
	initial begin : clk_generator
		clk_i = 1'b0;
		#(RST_DURATION);
		forever begin
			clk_i = #(CLK_PERIOD/2) ~clk_i;
		end
	end
	
	// SCLK oscillator
	initial begin : sclk_generator
		sclk_i = 1'b0;
		#(RST_DURATION);
		forever begin
			sclk_i = #(SCLK_PERIOD/2) ~sclk_i;
		end
	end
	
	// WSEL generator
	always @ (negedge(sclk_i) or posedge(rst_i)) begin : wsel_generator
		if (rst_i) begin
			wsel_i = 0;
		end
		else begin
			if (indx_bit_rx == 1) begin
				wsel_i = ~wsel_i;
			end
		end
	end

	// I2S receiver
	always @ (posedge(sclk_i) or posedge(rst_i)) begin : receiver
		if (rst_i) begin
			indx_rx = 1'b1;
			indx_bit_rx = 0;
			data_rx[0] = 0;
			data_rx[1] = 0;
		end
		else begin
			if (indx_bit_rx == 0) begin
				indx_bit_rx = 15;
				indx_rx = ~indx_rx;
			end
			else begin
				indx_bit_rx = indx_bit_rx - 1;
			end
			data_rx[indx_rx][indx_bit_rx] = sdat_o;
		end
	end
	
	// Parallel transmitter
	always @ (posedge(clk_i) or posedge(rst_i)) begin : transmitter
		if (rst_i) begin
			data_i = 16'h0000;
			indx_tx = 0;
			read_from_file;
		end
		else begin
			if (write_o) begin
				if (indx_tx < STIMULUS_DATA_COUNT) begin
					data_i = data_tx[indx_tx];
					indx_tx = indx_tx + 1;
				end
				else begin
					$stop;
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
