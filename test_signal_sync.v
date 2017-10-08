`timescale 1ns / 100ps

module test_signal_sync;

	localparam RST_DURATION = 50; //ns
	localparam CLK_PERIOD = 10; //ns
	localparam SIGNAL_PERIOD = 100; //ns

	// Inputs
	reg clk_i;
	reg rst_i;
	reg signal_i;

	// Outputs
	wire signal_o;
	wire valid_o;
	wire edge_o;
	wire posedge_o;
	wire negedge_o;

	// Instantiate the Unit Under Test (UUT)
	signal_sync uut
	(
		.clk_i(clk_i), 
		.rst_i(rst_i), 
		.signal_i(signal_i), 
		.signal_o(signal_o), 
		.valid_o(valid_o),
		.edge_o(edge_o),
		.posedge_o(posedge_o),
		.negedge_o(negedge_o)
	);

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
	
	// Main stimulus
	initial begin : stimulus_generator
		signal_i = 0;
		#(RST_DURATION);
		forever begin
			signal_i = #(SIGNAL_PERIOD/2) ~signal_i;
		end
	end
      
endmodule
