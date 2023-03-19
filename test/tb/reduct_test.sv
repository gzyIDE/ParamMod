/*
* <reduct_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

module reduct_test;
	parameter STEP = 10;
	parameter OPE = "or";	// Supported Operations ( "and", "or", "xor" )
	parameter NOT = `DISABLE;
	parameter IN = 4;
	parameter DATA = 16;

	reg [IN-1:0][DATA-1:0]	in;
	wire [DATA-1:0]			    out;

	reduct #(
		.OPE	( OPE ),
		.DATA	( DATA )
	) reduct (
		.*
	);

`ifndef VERILATOR
	task reduct_check;
		bit [DATA-1:0]		ans;
		int i;

		case ( OPE )
			"and" : begin
				ans = {DATA{1'b1}};
				for ( i = 0; i < IN; i = i + 1 ) begin
					ans = ans & in[i];
				end
				if ( NOT ) begin
					ans = ~ans;
				end
			end
			"or" : begin
				ans = {DATA{1'b0}};
				for ( i = 0; i < IN; i = i + 1 ) begin
					ans = ans | in[i];
				end
				if ( NOT ) begin
					ans = ~ans;
				end
			end
			"xor" : begin
				ans = {DATA{1'b0}};
				for ( i = 0; i < IN; i = i + 1 ) begin
					ans = ans ^ in[i];
				end
				if ( NOT ) begin
					ans = ~ans;
				end
			end
		endcase

		assert ( ans == out ) else begin
			`SetCharRedBold
			$display("Check failed");
			$display("    result: %0b", out);
			$display("    answer: %0b", ans);
			`ResetCharSetting
			$fatal(1);
		end
	endtask



	//***** test body
	int i, j;
	initial begin
		for ( j = 0; j < 100; j = j + 1 ) begin
			for ( i  = 0; i < IN; i = i + 1 ) begin
				in[i] = $random;
			end

			#(STEP);
			reduct_check;
		end

		`SetCharGreenBold
		$display("Check Complete");
		`ResetCharSetting

		$finish;
	end

	`include "waves.vh"
`endif

endmodule
