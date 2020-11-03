/*
* <bin_dec.v>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

// Binary Decoder
module bin_dec #(
	parameter IN = 4,
	parameter ACT = `High,
	// constant
	parameter OUT = 1 << IN
)(
	input wire [IN-1:0]		in,
	output wire [OUT-1:0]	out
);

	//***** internal parameter
	localparam ENABLE = ACT ? `Enable : `Enable_;
	localparam DISABLE = ACT ? `Disable : `Disable_;



	//***** Logic for Combinational logic
	logic [OUT-1:0]		out_l;



	//***** assign output
	assign out = out_l;



	//***** decode
	int i;
	always_comb begin
		for ( i = 0; i < OUT; i = i + 1 ) begin
			out_l[i] = ( i == in ) ? ENABLE : DISABLE;
		end
	end

endmodule
