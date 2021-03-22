/*
* <block_shift.v>
* 
* Copyright (c) 2020-2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module block_shift #(
	parameter bit ROTATE = `Disable,	// rotate instead of shift
	parameter bit TO_RIGHT = `Disable,	// shift/rotate right
	parameter ELMS = 8,
	parameter DATA = 8,
	// constant
	parameter SHAMT = $clog2(ELMS+1)
)(
	input wire [ELMS-1:0][DATA-1:0]		in,
	input wire [SHAMT-1:0]				shamt,
	output wire [ELMS-1:0][DATA-1:0]	out
);

	//***** bit-wise shift for each elements
	generate
		genvar gi, gj;
		for ( gi = 0; gi < DATA; gi = gi + 1 ) begin : LP_data
			wire [ELMS-1:0]		bitwise;
			wire [ELMS-1:0]		bitwise_sft;
			for ( gj = 0; gj < ELMS; gj = gj + 1 ) begin : LP_elm
				assign bitwise[gj] = in[gj][gi];
				assign out[gj][gi] = bitwise_sft[gj];
			end

			shifter #(
				.BIT_VEC	( `Disable ),
				.ROTATE		( ROTATE ),
				.TO_RIGHT	( TO_RIGHT ),
				.DATA		( ELMS ),
				.SHAMT		( SHAMT )
			) shifter (
				.in			( bitwise ),
				.shamt		( shamt ),
				.out		( bitwise_sft )
			);
		end
	endgenerate

endmodule
