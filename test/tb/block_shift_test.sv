/*
* <block_shift_test.v>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "sim.vh"

module block_shift_test;
	parameter STEP = 10;
	parameter bit ROTATE = `Disable;	// rotate instead of shift
	parameter bit TO_RIGHT = `Disable;	// shift/rotate right
	parameter ELMS = 8;
	parameter DATA = 8;
	parameter SHAMT = $clog2(ELMS+1);

	reg [ELMS-1:0][DATA-1:0]	in;
	reg [SHAMT-1:0]				shamt;
	wire [ELMS-1:0][DATA-1:0]	out;

	block_shift #(
		.ROTATE		( ROTATE ),
		.TO_RIGHT	( TO_RIGHT ),
		.ELMS		( ELMS ),
		.DATA		( DATA )
	) block_shift (
		.*
	);



	task check_result (
		input [ELMS-1:0][DATA-1:0]	in,
		input [SHAMT-1:0]			shamt,
		input [ELMS-1:0][DATA-1:0]	out
	);
		int ti;
		int idx;
		reg [ELMS-1:0][DATA-1:0]	ans;

		if ( ROTATE ) begin
			if ( TO_RIGHT ) begin
				// rotate right
				for ( ti = 0; ti < ELMS; ti = ti + 1 ) begin
					idx = ti + shamt;
					if ( idx > ELMS - 1 ) begin
						ans[ti] = in[idx-ELMS];
					end else begin
						ans[ti] = in[idx];
					end
				end
			end else begin
				// rotate left
				for ( ti = 0; ti < ELMS; ti = ti + 1 ) begin
					idx = ti - shamt;
					if ( idx < 0 ) begin
						ans[ti] = in[idx+ELMS];
					end else begin
						ans[ti] = in[idx];
					end
				end
			end
		end else begin
			if ( TO_RIGHT ) begin
				// shift right
				for ( ti = 0; ti < ELMS; ti = ti + 1 ) begin
					idx = ti + shamt;
					if ( idx > ELMS - 1 ) begin
						ans[ti] = 0;
					end else begin
						ans[ti] = in[idx];
					end
				end
			end else begin
				// shift left
				for ( ti = 0; ti < ELMS; ti = ti + 1 ) begin
					idx = ti - shamt;
					if ( idx < 0 ) begin
						ans[ti] = 0;
					end else begin
						ans[ti] = in[idx];
					end
				end
			end
		end

		assert ( ans == out ) else begin
			`SetCharRedBold
			$display("Check Error");
			`ResetCharSetting
			$display("    result : 0x%x", out);
			$display("    expected : 0x%x", ans);
		end
	endtask



	//***** test body
	int i;
	initial begin
		in = 0;
		shamt = 0;
		#(STEP);
		for ( i = 0; i < ELMS; i = i + 1 ) begin
			in[i] = i + 1;
		end

		#(STEP);
		for ( i = 0; i <= ELMS; i = i + 1 ) begin
			shamt = i;
			#(STEP);
			check_result(in, shamt, out);
		end

		#(STEP);
	end

	`include "waves.vh"

endmodule
