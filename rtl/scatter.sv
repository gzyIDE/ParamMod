/*
* <scatter.sv>
* 
* Copyright (c) 2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module scatter #(
	parameter DATA = 32,		// Data Size
	parameter IN = 8,			// Input Data
	parameter ACT = `High,		// Active High/Low (sel, valid)
	parameter OUT = IN			// Gathered Output
)(
	input wire [IN-1:0][DATA-1:0]	in,
	input wire [OUT-1:0]			sel,
	output wire [OUT-1:0]			valid,
	output wire [OUT-1:0][DATA-1:0]	out
);

	//***** internal parameters
	localparam ENABLE = ACT ? `Enable : `Enable_;
	localparam DISABLE = ACT ? `Disable : `Disable_;
	localparam IN_NUM = $clog2(IN);
	localparam NUM = $clog2(OUT);

	//***** internal wires
	wire [OUT-1:0][NUM-1:0]			order;



	//***** Calculate output order
	assign order[0] = 0;
	generate
		genvar gi;
		//*** count activated bits of former entries
		for ( gi = 1; gi < OUT; gi = gi + 1 ) begin : LP_order
			wire [$clog2(gi):0]		order_each;
			assign order[gi] = {{NUM-$clog2(gi){1'b0}}, order_each};

			cnt_bits #(
				.IN		( gi ),
				.ACT	( ACT )
			) cnt_bits (
				.in		( sel[gi-1:0] ),
				.out	( order_each )
			);
		end
	endgenerate



	//***** Select Output
	generate
		genvar gj;
		for ( gj = 0; gj < OUT; gj = gj + 1 ) begin : LP_sel
			wire				match;
			wire [DATA-1:0]		sel_res;

			assign match = ( order[gj] < IN ) && ( sel[gj] == ENABLE );
			assign valid[gj] = match ? ENABLE : DISABLE;
			assign out[gj] = match ? sel_res : 0;

			selector #(
				.BIT_MAP	( `Disable ),
				.DATA		( DATA ),
				.IN			( OUT ),
				.ACT		( ACT )
			) out_sel (
				.in		( in ),
				.sel	( order[gj] ),
				.valid	(),
				.pos	(),
				.out	( sel_res )
			);
		end
	endgenerate

endmodule
