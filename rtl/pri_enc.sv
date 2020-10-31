/*
* <pri_enc.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

// Priority Encoder
module pri_enc #(
	parameter IN = 16,
	parameter OUT = $clog2(IN),
	parameter ACT = `High
)(
	input wire [IN-1:0]		in,
	output wire				valid,
	output wire [OUT-1:0]	out
);

	//***** internal parameter
	localparam ENABLE = ACT ? `Enable : `Enable_;
	localparam DISABLE = ACT ? `Disable : `Disable_;



	//***** assign output
	assign valid 
		= ACT
			? |in ? ENABLE : DISABLE
			: &in ? ENABLE : DISABLE;


	//***** Generate Mask (Output Constant)
	function [IN-1:0] gen_mask;
		input int		blk;
		input int		ofs;
		int			i, j;
		begin
			for ( i = 0; i < IN; i = i + ( blk * 2 ) ) begin
				for ( j = 0; j < blk; j = j + 1 ) begin
					if ( i + j > ofs ) begin
						gen_mask[i+j] = ENABLE;
					end else begin
						gen_mask[i+j] = DISABLE;
					end
				end
				for ( j = 0; j < blk; j = j + 1 ) begin
					gen_mask[i+j+blk] = DISABLE;
				end
			end
		end
	endfunction



	//***** body of priority encoder
	generate
		genvar gi, gj;
		for (gi = 0; gi < OUT; gi = gi + 1 ) begin : LP_out
			wor			out_wor;
			assign out[gi] = out_wor;

			for ( gj = 1; gj < IN; gj = gj + 1 ) begin : LP_in
				if ( (gj >> gi) & 1'b1 ) begin : IF_Act
					bit [IN-1:0]			mask;
					assign mask = gen_mask((1<<(gi)), gj);
					assign out_wor = 
						ACT 
							? !( |( mask & in ) ) && in[gj]
							: ( &( mask | in ) ) && !in[gj];
							// !( !( &(mask | in ) ) || in[gj] )
				end
			end
		end
	endgenerate

endmodule
