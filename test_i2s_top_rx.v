`timescale 1ns / 100ps

module test_i2s_top_rx;

	parameter RST_DURATION = 50; //ns
	parameter CLK_PERIOD = 20; //ns

	// Inputs
	reg clk_i;
	reg rst_i;
	reg sdat_i;

	// Outputs
	wire [15:0] data_o;
	wire lr_chnl_o;
	wire write_o;
	wire sclk_o;
	wire wsel_o;
	
	// Received data
	reg [15:0] data_rx [0:1];
	
	// Transmitted data
	reg [99:0] data_tx;
	integer indx_tx;

	// Instantiate the Unit Under Test (UUT)
	i2s_top_rx uut
	(
		.clk_i(clk_i), 
		.rst_i(rst_i), 
		.data_o(data_o), 
		.lr_chnl_o(lr_chnl_o), 
		.write_o(write_o), 
		.sclk_o(sclk_o), 
		.wsel_o(wsel_o), 
		.sdat_i(sdat_i)
	);

	// Reset pulse generator
	initial begin
		rst_i = 1'b1;
		sdat_i = 1'b0;
		#(RST_DURATION);
		rst_i = 1'b0;
	end
	
	// Main oscillator
	initial begin
		clk_i = 1'b0;
		#(RST_DURATION);
		forever begin
			clk_i = #(CLK_PERIOD) ~clk_i;
		end
	end
	
	// I2S transmitter
	initial begin
		indx_tx = 0;
		read_from_file(data_tx);
		sdat_i = 1'b0;
		#(RST_DURATION);
		forever begin
			@(negedge(clk_i)) begin
				if (indx_tx < 100) begin
					sdat_i = data_tx[indx_tx];
					indx_tx = indx_tx + 1;
				end
				else begin
					$finish;
				end
			end
		end
	end
	
	// Parallel receiver
	always @ (negedge(clk_i) or posedge(rst_i)) begin
		if (rst_i) begin
			data_rx[0] = 16'h0000;
			data_rx[1] = 16'h0000;
		end
		else begin
			if (write_o) begin
				if (lr_chnl_o) begin
					data_rx[1] = data_o;
				end
				else begin
					data_rx[0] = data_o;
				end
			end
		end
	end
	
	task read_from_file;
		integer stimulus_file;
		output [99:0] read_value;
	begin
		stimulus_file = $fopen("stimulus/stimulus.txt", "r");
		if (stimulus_file == 0) $finish;
		if ($fscanf(stimulus_file, "%b", read_value) == 0) $finish;
	end
	endtask;
      
endmodule
