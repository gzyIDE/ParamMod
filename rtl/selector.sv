/*
* <selector.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module selector #(
	parameter bit BIT_MAP = `Disable,	// 0: index, 1: bit_map
	parameter int DATA = 5,				// width of single element
	parameter int IN = 64,				// # of input element
	parameter bit ACT = `Low,			// Active High/Low
	parameter bit MSB = `Disable,		// select from MSB
	// constant
	parameter int LOG2_IN = $clog2(IN),
	parameter int SEL_WIDTH = BIT_MAP ? IN : LOG2_IN // selector width
) (
	input wire [IN-1:0][DATA-1:0]	in,
	input wire [SEL_WIDTH-1:0]		sel,
	output wire						valid,
	output wire [IN-1:0]			pos,
	output wire [DATA-1:0]			out
);

	//***** internal parameters
	localparam bit ENABLE = ACT ? `Enable : `Enable_;
	localparam bit DISABLE = ACT ? `Disable : `Disable_;
	localparam EIN = 1 << LOG2_IN;		// align to 2^n
	localparam STAGE = LOG2_IN;
	localparam ELMS = EIN - 1;

	//***** Internal wires
	wire [DATA-1:0]				res [ELMS-1:0];
	wire [ELMS-1:0]				sel_res;



	//****** output
	assign out = res[ELMS-1];
	assign valid = sel_res[ELMS-1];



	//***** output position
	generate
		genvar gk;
		if ( BIT_MAP ) begin : IF_BIT
			if ( MSB ) begin : IF_MSB
				assign pos[IN-1] = sel[IN-1];
				for ( gk = IN-2; gk >= 0; gk = gk - 1 ) begin : LP_pos
					assign pos[gk] =
						ACT
							? !( |pos[IN-1:gk+1] ) && sel[gk]
							: !( &pos[IN-1:gk+1] ) || sel[gk];
				end
			end else begin : IF_LSB
				assign pos[0] = sel[0];
				for ( gk = 1; gk < IN; gk = gk + 1 ) begin : LP_pos
					assign pos[gk] =
						ACT
							? !( |pos[gk-1:0] ) && sel[gk]
							: !( &pos[gk-1:0] ) || sel[gk];
				end
			end
		end else begin : IF_IDX
			logic [IN-1:0]		out_l;
			assign out = out_l;

			always_comb begin
				out_l = {IN{DISABLE}};
				out_l[sel] = ENABLE;
			end
		end
	endgenerate



	//***** element select function
	generate
		genvar gi, gj;
		//*** Input Stage ( = stage 1 )
		for ( gi = 0; gi < EIN / 2; gi = gi + 1 ) begin : ST0

			if ( 2*gi+1 < IN ) begin : elm
				wire				sel1;
				wire [LOG2_IN-1:0]	pos1;
				wire				sel2;
				wire [LOG2_IN-1:0]	pos2;
				assign sel_res[gi] = sel1 || sel2;
				assign pos1 = gi * 2;
				assign pos2 = gi * 2 + 1;
				if ( BIT_MAP ) begin : bitmap
					assign sel1 = ( sel[gi*2] == ENABLE );
					assign sel2 = ( sel[gi*2+1] == ENABLE );
				end else begin : idx
					assign sel1 = ( sel == ( gi * 2 ) );
					assign sel2 = ( sel == ( gi * 2 + 1 ) );
				end

				sub_sel #(
					.DATA	( DATA ),
					.MSB	( MSB )
				) sub_sel (
					.in1	( in[gi*2] ),
					.in2	( in[gi*2+1] ),
					.sel1	( sel1 ),
					.sel2	( sel2 ),
					.out	( res[gi] )
				);
			end else if ( 2 * gi < IN ) begin : elmh
				//* one element is valid
				wire [LOG2_IN-1:0]	pos;
				assign pos = gi*2;
				assign res[gi] = {pos, in[gi*2]};
				assign sel_res[gi] =
					BIT_MAP
						? ( sel[gi*2] == ENABLE )
						: ( sel == (gi*2) );
			end else begin : zero
				assign res[gi] = {DATA{1'b0}};
				assign sel_res[gi] = DISABLE;
			end
		end

		//*** middle to output stages
		for ( gi = 2; gi <= STAGE; gi = gi + 1 ) begin : ST
			for ( gj = 0; gj < EIN >> gi; gj = gj + 1 ) begin : elm
				wire		sel1; 
				wire		sel2; 
				assign sel1 = sel_res[(gj*2)+(EIN-(EIN>>(gi-2)))];
				assign sel2 = sel_res[(gj*2+1)+(EIN-(EIN>>(gi-2)))];
				assign sel_res[gj+(EIN-(EIN>>(gi-1)))] = sel1 || sel2;

				sub_sel #(
					.DATA	( DATA ),
					.MSB	( MSB )
				) sub_cnt (
					.in1	( res[(gj*2)+(EIN-(EIN>>(gi-2)))] ),
					.in2	( res[(gj*2+1)+(EIN-(EIN>>(gi-2)))] ),
					.sel1	( sel1 ),
					.sel2	( sel2 ),
					.out	( res[gj+(EIN-(EIN>>(gi-1)))] )
				);
			end
		end
	endgenerate

endmodule

// simple 2:1 mux
module sub_sel #(
	parameter DATA = 8,
	parameter MSB = `Disable
)(
	input wire [DATA-1:0]		in1,
	input wire [DATA-1:0]		in2,
	input wire					sel1,
	input wire					sel2,
	output logic [DATA-1:0]		out
);


	generate
		if ( MSB ) begin : IF_MSB
			always_comb begin
				case ( {sel2, sel1} )
					2'b11, 2'b10 : out = in2;
					2'b01 : out = in1;
					default : out = {DATA{1'b0}};
				endcase
			end
		end else begin : IF_LSB
			always_comb begin
				case ( {sel2, sel1} )
					2'b11, 2'b01 : out = in1;
					2'b10 : out = in2;
					default : out = {DATA{1'b0}};
				endcase
			end
		end
	endgenerate

endmodule
