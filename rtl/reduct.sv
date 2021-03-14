/*
* <reduct.sv>
* 
* Copyright (c) 2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

// Parameterized Data Reduction Module 
module reduct #(
	parameter OPE = "or",		// Supported Operations : "and", "or", "xor"
	parameter NOT = `Disable,	// Bit Flip             : "nand", "nor", "xnor"
	parameter IN = 4,			// Number of inputs
	parameter DATA = 16			// Size of input data
)(
	input wire [IN-1:0][DATA-1:0]	in,
	output wire [DATA-1:0]			out
);

	//***** internal parameters
	localparam LOG2_IN = $clog2(IN);
	localparam EIN = 1 << LOG2_IN;
	localparam STAGE = LOG2_IN;
	localparam ELMS = EIN - 1;

	//***** internal wires
	wire [ELMS-1:0][DATA-1:0]	res;



	//***** assign output
	generate
		if ( NOT ) begin : IF_inv
			assign out = ~res[ELMS-1];
		end else begin : IF_thr
			assign out = res[ELMS-1];
		end
	endgenerate



	//***** assign internal
	generate
		genvar gi, gj;
		// input Stage ( = stage 1 )
		for ( gi = 0; gi < EIN / 2; gi = gi + 1 ) begin : ST1

			if ( 2*gi+1 < IN ) begin : elm
				sub_reduct #(
					.OPE	( OPE ),
					.DATA	( DATA )
				) sub_reduct (
					.in1	( in[gi*2] ), 
					.in2	( in[gi*2+1] ),
					.out	( res[gi] )
				);

			end else if ( 2 * gi < IN ) begin : elmh
				assign res[gi] = in[gi*2];
			end else begin : zero
				case ( OPE )
					"and" : begin : C_high
						assign res[gi] = {DATA{1'b1}};
					end
					default : begin : C_low
						assign res[gi] = {DATA{1'b0}};
					end
				endcase
			end
		end

		//*** middle to output stages
		for ( gi = 2; gi <= STAGE; gi = gi + 1 ) begin : ST
			for ( gj = 0; gj < EIN >> gi; gj = gj + 1 ) begin : elm
				sub_reduct #(
					.OPE	( OPE ),
					.DATA	( DATA )
				) sub_reduct (
					.in1	( res[(gj*2)+(EIN-(EIN>>(gi-2)))] ),
					.in2	( res[(gj*2+1)+(EIN-(EIN>>(gi-2)))] ),
					.out	( res[gj+(EIN-(EIN>>(gi-1)))] )
				);
			end
		end
	endgenerate

endmodule

module sub_reduct #(
	parameter OPE = "or",
	parameter DATA = 16
)(
	input wire [DATA-1:0]		in1,
	input wire [DATA-1:0]		in2,
	output wire [DATA-1:0]		out
);

	generate
		case ( OPE )
			"and" : begin : C_and
				assign out = in1 & in2;
			end
			"or" : begin : C_or
				assign out = in1 | in2;
			end
			"xor" : begin : C_xor
				assign out = in1 ^ in2;
			end
			default : begin
				assign out = {DATA{1'b0}};
			end
		endcase
	endgenerate

endmodule
