/*
* <sel_minmax.sv>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"

module sel_max_test;
	parameter STEP = 10;
	parameter MINMAX_ = `High;
	parameter IN = 8;
	parameter DATA = 8;
	parameter ACT = `High;
	parameter OUT = $clog2(IN);

	reg [DATA*IN-1:0]		in;
	wire [OUT-1:0]			out_idx;
	wire [IN-1:0]			out_vec;
	wire [DATA-1:0]			out;

	sel_minmax #(
		.MINMAX_	( MINMAX_ ),
		.IN			( IN ),
		.DATA		( DATA ),
		.ACT		( ACT )
	) sel_max (
		.*
	);

	integer i;
	initial begin
		in = {DATA*IN{1'b0}};

		#(STEP);
		for ( i = 0; i < IN; i = i + 1 ) begin
			in[`Range(i,DATA)] = $random();
		end

		#(STEP);
	end

`ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("AC");
	end
`endif

endmodule
