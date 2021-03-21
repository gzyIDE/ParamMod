/*
* <cnt_bits.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module cnt_bits #(
	parameter IN = 128,				// Input Bit Width
	parameter ACT = `High,			// Active High or Low
	// constant
	parameter OUT = $clog2(IN) + 1	// Output bit width
)(
	input wire [IN-1:0]			in,
	output wire [OUT-1:0]		out
);

	//***** Internal Parameters
	localparam LOG2_IN = $clog2(IN);
	localparam EIN = 1 << LOG2_IN;		// align to 2^n
	localparam STAGE = LOG2_IN;
	localparam ELMS = EIN - 1;



	generate
		genvar gi, gj;
		if ( IN == 1 ) begin : nocnt
			//***** assign output
			assign out = ( in == ACT );
		end else begin : cnt
			//***** Internal Wires
			//*** Most of bits are not used (Removed on synthesis)
			wire [OUT-1:0]				res [ELMS-1:0];



			//***** assign output
			assign out = ( IN == 1 ) ? in : res[ELMS-1];



			//***** bit counter
			for ( gi = 0; gi < EIN / 2; gi = gi + 1 ) begin : ST0
				wire [1:0]		res_each;
				if ( 2*gi+1 < IN ) begin : valid
					sub_cnt #(
						.IN		( 1 )
					) sub_cnt (
						.in1	( ( in[gi*2] == ACT ) ),
						.in2	( ( in[gi*2+1] == ACT ) ),
						.out	( res_each )
					);
				end else if ( 2*gi < IN ) begin : half
					assign res_each = {1'b0, (in[gi*2] == ACT)};
				end else begin : zero
					assign res_each = 2'b00;
				end

				assign res[gi] = {{OUT-2{1'b0}}, res_each};
			end
			for ( gi = 2; gi <= STAGE; gi = gi + 1 ) begin : ST
				//*** stage 2 to stage STAGE
				for ( gj = 0; gj < EIN >> gi; gj = gj + 1 ) begin : elm
					wire [gi:0]		res_each;
					sub_cnt #(
						.IN		( gi )
					) sub_cnt (
						.in1	( res[(gj*2)+(EIN-(EIN>>(gi-2)))][gi-1:0] ),
						.in2	( res[(gj*2+1)+(EIN-(EIN>>(gi-2)))][gi-1:0] ),
						.out	( res_each )
					);
					assign res[gj+(EIN-(EIN>>(gi-1)))]
						= {{OUT-(gi+1){1'b0}}, res_each};
				end
			end
		end
	endgenerate

endmodule



// simple adder inside cnt_bits
module sub_cnt #(
	parameter IN = 1, 
	parameter OUT = IN + 1
)(
	input wire [IN-1:0]		in1,
	input wire [IN-1:0]		in2,
	output wire [OUT-1:0]	out
);

	assign out = in1 + in2;

endmodule
