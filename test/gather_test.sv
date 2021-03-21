/*
* <gather_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module gather_test;
	parameter STEP = 10;
	parameter DATA = 32;		// Data Size
	parameter IN = 8;			// Input Data
	parameter ACT = `Low;		// Active High/Low (sel; valid)
	parameter OUT = 4;			// Gathered Output
	localparam ENABLE = ACT ? `Enable : `Enable_;
	localparam DISABLE = ACT ? `Disable : `Disable_;

	reg [IN-1:0][DATA-1:0]		in;
	reg [IN-1:0]				sel;
	wire [OUT-1:0]				valid;
	wire [OUT-1:0][DATA-1:0]	out;

	gather #(
		.DATA	( DATA ),
		.IN		( IN ),
		.ACT	( ACT ),
		.OUT	( OUT )
	) gather (
		.*
	);



	task calculate_ans (
		input [IN-1:0][DATA-1:0]	in,
		input [IN-1:0]				sel,
		input [OUT-1:0]				valid,
		input [OUT-1:0][DATA-1:0]	out
	);
		int							fi;
		int 						cnt;
		reg [OUT-1:0][DATA-1:0]		ans;
		reg [OUT-1:0]				ans_valid;

		ans = 0;
		cnt = 0;
		ans_valid = {OUT{DISABLE}};
		for ( fi = 0; fi < IN; fi = fi + 1 ) begin
			if ( sel[fi] == ENABLE ) begin
				ans[cnt] = in[fi];
				ans_valid[cnt] = ENABLE;
				cnt = cnt + 1;
			end
		end

		assert ( ( ans == out ) && ( valid== ans_valid ) ) else begin
			$error("Check Failed");
			$display("    output   : 0x%x", out);
			$display("    expected : 0x%x", ans);
			$display("    output valid   : 0x%x", valid);
			$display("    expected valid : 0x%x", ans_valid);
		end

	endtask



	//***** test body
	int i, j;
	initial begin
		for ( i = 0; i < IN; i = i + 1 ) begin
			in[i] = i + 1;
		end
		sel = {IN{DISABLE}};
		#(STEP);

		// output = {D, D, D, D, D, 6, 2, 1}
		sel[0] = ENABLE;
		sel[1] = ENABLE;
		sel[5] = ENABLE;

		#(STEP);
		calculate_ans(in, sel, valid,out);
		#(STEP);

		for ( i = 0; i < 1000; i = i + 1 ) begin
			sel = $random();
			for ( j = 0; j < IN; j = j + 1 ) begin
				in[j] = $random();
			end
			#(STEP);
			calculate_ans(in, sel, valid, out);
			#(STEP);
		end

		#(STEP);
		$finish;
	end

	`include "waves.vh"

endmodule
