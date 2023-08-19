/*
* <lsfr_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "parammod_stddef.vh"
`include "sim.vh"

module lsfr_test;
	parameter STEP = 10;
	parameter DATA = 8;
	parameter PATTERNS = ( 1 << DATA ) - 1;

	//***** signals
	reg					clk;
	reg					reset;
	wire [DATA-1:0]		out;

	//***** output status
	int					out_stat [PATTERNS-1:0];

	lsfr #(
		.DATA	( DATA )
	) lsfr (
		.*
	);



	//***** clock generation
	always #(STEP/2) begin
		clk = ~clk;
	end



	//***** test body
	int i;
	initial begin : test_body
		clk = `LOW;
		reset = `ENABLE;
		#(STEP);
		reset = `DISABLE;

		out_stat[0] = 1;
		for ( i = 0; i < PATTERNS; i = i + 1 ) begin
			@( posedge clk );
			out_stat[out] = out_stat[out] + 1;
			#(STEP);
		end

		foreach ( out_stat[i] ) begin
			assert ( out_stat[i] == 1 ) else begin
				`SetCharRedBold
				$error("Sequence is not maximum-length");
				`ResetCharSetting
				$display("    out_stat[%d] : %d", i, out_stat[i]);
				$fatal(1);
			end
		end

		$finish;
	end

	`include "waves.vh"

endmodule
