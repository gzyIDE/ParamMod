/*
* <selector.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module sel_minmax #(
	parameter MINMAX_ =	0,		// 0: Max, 1: Min
	parameter IN = 8,			// Number of Inputs
	parameter DATA = 8,			// data bit width
	parameter ACT = `High,		// Polarity
	// constant
	parameter OUT = $clog2(IN)	// Output bit width
)(
	input wire [IN-1:0][DATA-1:0]	in,			// input data
	output wire [OUT-1:0]			out_idx,	// position of min/max ( index )
	output wire [IN-1:0]			out_vec,	// position of min/max ( bit vector )
	output wire [DATA-1:0]			out			// min/max element
);

	//***** internal parameters
	localparam bit ENABLE = ACT ? `Enable : `Enable_;
	localparam bit DISABLE = ACT ? `Disable : `Disable_;
	localparam EIN = 1 << OUT;		// align to 2^n
	localparam STAGE = OUT;
	localparam ELMS = EIN - 1;

	//***** Internal wires
	wire [ELMS-1:0][DATA-1:0]	res;
	wire [ELMS-1:0][OUT-1:0]	idx_res;



	//***** output
	assign out = res[ELMS-1];
	assign out_idx = idx_res[ELMS-1];

	bin_dec #(
		.IN		( OUT ),
		.ACT	( ACT )
	) scl2vec (
		.in		( out_idx ),
		.out	( out_vec )
	);



	//***** element select function
	generate
		genvar gi, gj;
		//*** Input Stage ( = stage 1 )
		for ( gi = 0; gi < EIN / 2; gi = gi + 1 ) begin : ST1

			if ( 2*gi+1 < IN ) begin : elm
				wire [OUT-1:0]	pos1;
				wire [OUT-1:0]	pos2;
				wire [DATA-1:0]	data1;
				wire [DATA-1:0]	data2;
				assign pos1 = gi * 2;
				assign pos2 = gi * 2 + 1;
				assign data1 = in[pos1];
				assign data2 = in[pos2];

				if ( MINMAX_ ) begin : min
					assign {idx_res[gi], res[gi]} =
						( data1 <= data2 ) ? {pos1, data1} : {pos2, data2};
				end else begin : max
					assign {idx_res[gi], res[gi]} =
						( data1 >= data2 ) ? {pos1, data1} : {pos2, data2};
				end
			end else if ( 2 * gi < IN ) begin : elmh
				//* one element is valid
				wire [OUT-1:0]	pos;
				assign pos = gi * 2;
				assign idx_res[gi] = pos;
				assign res[gi] = in[pos];
			end else begin : zero
				assign idx_res[gi] = 0;
				if ( MINMAX_ ) begin : min
					assign res[gi] = {DATA{1'b1}};
				end else begin : max
					assign res[gi] = {DATA{1'b0}};
				end
			end
		end

		//*** middle to output stages
		for ( gi = 2; gi <= STAGE; gi = gi + 1 ) begin : ST
			for ( gj = 0; gj < EIN >> gi; gj = gj + 1 ) begin : elm
				wire [OUT-1:0]	idx1;
				wire [OUT-1:0]	idx2;
				wire [DATA-1:0]	data1;
				wire [DATA-1:0]	data2;
				assign idx1 = idx_res[(gj*2) + (EIN-(EIN>>(gi-2)))];
				assign idx2 = idx_res[(gj*2+1) + (EIN-(EIN>>(gi-2)))];
				assign data1 = res[(gj*2) + (EIN-(EIN>>(gi-2)))];
				assign data2 = res[(gj*2+1) + (EIN-(EIN>>(gi-2)))];
				if ( MINMAX_ ) begin : min
					assign {idx_res[gj+(EIN-(EIN>>(gi-1)))], 
								res[gj+(EIN-(EIN>>(gi-1)))] } = 
						( data1 <= data2 ) ? {idx1, data1} : {idx2, data2};
				end else begin : max
					assign {idx_res[gj+(EIN-(EIN>>(gi-1)))],
								res[gj+(EIN-(EIN>>(gi-1)))] } = 
						( data1 >= data2 ) ? {idx1, data1} : {idx2, data2};
				end
			end
		end
	endgenerate

endmodule
